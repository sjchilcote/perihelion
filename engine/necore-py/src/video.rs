//! Capture encode — a real video codec in the engine.
//!
//! Before this, "recording" meant one PNG per frame plus an ffmpeg
//! invocation afterwards: thousands of files per session, a second pass
//! over all of them, and every tool that wanted a video had to know the
//! ffmpeg incantation. The frames were also the only artifact, so a
//! capture that was never assembled left a directory of stills nobody
//! could play.
//!
//! [`VideoRecorder`] takes RGB frames and writes a playable .mp4 as it
//! goes. H.264 through openh264's vendored encoder, muxed by minimp4.
//! The encode runs with the GIL released, so a recording cannot steal
//! main-loop time — the same rule [`super::platform::write_png`] already
//! follows.
//!
//! The recorder owns no timing. It writes the frames it is given at the
//! declared frame rate, so the caller decides what a frame means (see
//! the sim-clock record path: the app records on the sim's clock and
//! `--fps` is only a meter).

use minimp4::Mp4Muxer;
use openh264::encoder::{Encoder, EncoderConfig};
use openh264::formats::{RgbSliceU8, YUVBuffer};
use openh264::OpenH264API;
use pyo3::exceptions::PyValueError;
use pyo3::prelude::*;
use std::fs::File;
use std::io::{Cursor, Write};
use std::path::PathBuf;

fn enc_err<E: std::fmt::Display>(what: &str) -> impl FnOnce(E) -> PyErr + '_ {
    move |e| PyValueError::new_err(format!("VideoRecorder: {what}: {e}"))
}

/// An open recording. Frames in, one .mp4 out.
///
/// The muxer needs `Write + Seek` and rewrites its header on close, so
/// the stream is built in memory and flushed to disk by `finish`. A
/// 14400-tick capture at 1280x720 is a few tens of megabytes of H.264 —
/// small enough to hold, and it keeps a half-written file off disk if a
/// capture dies part way (gate run 64 truncated four captures at ~1700
/// of 2880 frames, and a partial PNG directory looks exactly like a
/// complete one).
#[pyclass]
pub struct VideoRecorder {
    encoder: Option<Encoder>,
    /// Encoded access units, one per frame. The muxer is NOT held here:
    /// minimp4 wraps raw C pointers and is not `Send`, and a `#[pyclass]`
    /// must be. Building it inside `finish` keeps it on one thread and
    /// costs nothing — muxing is a header rewrite over data we already
    /// have, not a second encode.
    nals: Vec<Vec<u8>>,
    open: bool,
    path: PathBuf,
    width: u32,
    height: u32,
    fps: u32,
    frames: u64,
}

#[pymethods]
impl VideoRecorder {
    /// Open a recording. `width` and `height` must both be even — H.264
    /// chroma is subsampled by two, and an odd dimension is a silent
    /// corruption rather than an error further down.
    #[new]
    #[pyo3(signature = (path, width, height, fps=60))]
    fn new(path: &str, width: u32, height: u32, fps: u32) -> PyResult<Self> {
        if width == 0 || height == 0 || width % 2 != 0 || height % 2 != 0 {
            return Err(PyValueError::new_err(format!(
                "VideoRecorder: width/height must be positive and even, got {width}x{height}"
            )));
        }
        if fps == 0 {
            return Err(PyValueError::new_err("VideoRecorder: fps must be > 0"));
        }
        let config = EncoderConfig::new();
        let encoder = Encoder::with_api_config(OpenH264API::from_source(), config)
            .map_err(enc_err("encoder init"))?;
        Ok(Self {
            encoder: Some(encoder),
            nals: Vec::new(),
            open: true,
            path: PathBuf::from(path),
            width,
            height,
            fps,
            frames: 0,
        })
    }

    /// Encode one RGB24 frame. `rgb` is `width * height * 3` bytes.
    fn add_frame(&mut self, py: Python<'_>, rgb: Vec<u8>) -> PyResult<()> {
        let want = (self.width as usize) * (self.height as usize) * 3;
        if rgb.len() != want {
            return Err(PyValueError::new_err(format!(
                "VideoRecorder.add_frame: expected {want} bytes for {}x{}, got {}",
                self.width,
                self.height,
                rgb.len()
            )));
        }
        let (w, h) = (self.width as usize, self.height as usize);
        let encoder = self
            .encoder
            .as_mut()
            .ok_or_else(|| PyValueError::new_err("VideoRecorder: already finished"))?;
        let nal = py.allow_threads(|| -> PyResult<Vec<u8>> {
            let yuv = YUVBuffer::from_rgb8_source(RgbSliceU8::new(&rgb, (w, h)));
            let bitstream = encoder.encode(&yuv).map_err(enc_err("encode"))?;
            Ok(bitstream.to_vec())
        })?;
        if !nal.is_empty() {
            self.nals.push(nal);
        }
        self.frames += 1;
        Ok(())
    }

    /// Close the stream and write the file. Safe to call more than once.
    fn finish(&mut self, py: Python<'_>) -> PyResult<()> {
        if !self.open {
            return Ok(());
        }
        self.open = false;
        self.encoder = None;
        let path = self.path.clone();
        let nals = std::mem::take(&mut self.nals);
        let (w, h, fps) = (self.width as i32, self.height as i32, self.fps);
        py.allow_threads(move || -> PyResult<()> {
            let mut muxer = Mp4Muxer::new(Cursor::new(Vec::<u8>::new()));
            muxer.init_video(w, h, false, "perihelion");
            for nal in &nals {
                muxer.write_video_with_fps(nal, fps);
            }
            // close() hands back a reference to the writer it has been
            // filling, header rewrite and all
            let bytes: &[u8] = muxer.close().get_ref();
            if let Some(dir) = path.parent() {
                std::fs::create_dir_all(dir).map_err(enc_err("create output directory"))?;
            }
            let mut file = File::create(&path).map_err(enc_err("create output file"))?;
            file.write_all(bytes).map_err(enc_err("write output file"))?;
            file.flush().map_err(enc_err("flush output file"))?;
            Ok(())
        })
    }

    /// The number of frames encoded so far.
    #[getter]
    fn frames(&self) -> u64 {
        self.frames
    }

    #[getter]
    fn width(&self) -> u32 {
        self.width
    }

    #[getter]
    fn height(&self) -> u32 {
        self.height
    }

    #[getter]
    fn fps(&self) -> u32 {
        self.fps
    }

    /// Context-manager support, so a capture cannot leave the file
    /// unwritten when the caller raises part way through.
    fn __enter__(slf: PyRef<'_, Self>) -> PyRef<'_, Self> {
        slf
    }

    #[pyo3(signature = (_exc_type=None, _exc=None, _tb=None))]
    fn __exit__(
        &mut self,
        py: Python<'_>,
        _exc_type: Option<PyObject>,
        _exc: Option<PyObject>,
        _tb: Option<PyObject>,
    ) -> PyResult<bool> {
        self.finish(py)?;
        Ok(false)
    }
}
