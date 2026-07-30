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
use openh264::encoder::{
    BitRate, Encoder, EncoderConfig, FrameRate, IntraFramePeriod, QpRange, RateControlMode,
    UsageType,
};
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

/// Marks our top-level `uuid` box. Sixteen bytes, and readable in a hex
/// dump on purpose: "PERIHELIONRPLY01".
const SIDECAR_UUID: [u8; 16] = *b"PERIHELIONRPLY01";

/// Bits per pixel per frame. 0.15 is a generous-but-sane constant-ish
/// quality target for synthetic 60 Hz game footage, which is mostly flat
/// gradient (cheap) punctuated by thin high-contrast outlines (the part
/// that actually needs the bits).
const BITS_PER_PIXEL: f64 = 0.15;

/// Quantiser ceiling. Measured on real demo footage against the frames
/// the renderer actually produced (PSNR vs. the uncompressed source).
const DEFAULT_MAX_QP: u8 = 26;

/// Walk the top-level boxes of an ISO-BMFF file, calling `f` with the
/// type and body of each. Sizes are the 32-bit form unless the box says
/// otherwise (`1` = 64-bit largesize, `0` = extends to end of file).
fn for_each_box(buf: &[u8], mut f: impl FnMut(&[u8; 4], &[u8])) {
    let mut off = 0usize;
    while off + 8 <= buf.len() {
        let size32 = u32::from_be_bytes([buf[off], buf[off + 1], buf[off + 2], buf[off + 3]]);
        let mut kind = [0u8; 4];
        kind.copy_from_slice(&buf[off + 4..off + 8]);
        let (header, size) = match size32 {
            0 => (8usize, buf.len() - off),
            1 => {
                if off + 16 > buf.len() {
                    return;
                }
                let mut s = [0u8; 8];
                s.copy_from_slice(&buf[off + 8..off + 16]);
                (16usize, u64::from_be_bytes(s) as usize)
            }
            n => (8usize, n as usize),
        };
        if size < header || off + size > buf.len() {
            return;
        }
        f(&kind, &buf[off + header..off + size]);
        off += size;
    }
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
    /// Interleaved signed-16-bit little-endian PCM for the whole
    /// recording. minimp4 encodes audio in one pass at mux time (it wants
    /// the entire stream, not a running feed), so this accumulates.
    pcm: Vec<u8>,
    audio_rate: u32,
    audio_channels: u32,
    /// `(name, bytes)` blobs written as top-level `uuid` boxes.
    sidecars: Vec<(String, Vec<u8>)>,
}

#[pymethods]
impl VideoRecorder {
    /// Open a recording. `width` and `height` must both be even — H.264
    /// chroma is subsampled by two, and an odd dimension is a silent
    /// corruption rather than an error further down.
    /// Open a recording. `bitrate` defaults to a size-and-rate-derived
    /// target; pass one to override.
    ///
    /// EVERY non-default below is load-bearing, because openh264's
    /// defaults are tuned for a video call, not for archiving synthetic
    /// 60 Hz game footage:
    ///
    /// * `bitrate` — the default is **120 kbit/s**. At 1280x720x60 that
    ///   is about a hundredth of what this content wants, and it spends
    ///   the shortfall on exactly the wrong things: smooth dark gradients
    ///   band into visible steps and the thin bright outlines that carry
    ///   the game's whole visual vocabulary smear.
    /// * `max_frame_rate` — the default is 0 Hz, i.e. rate control is
    ///   never told how often frames arrive and budgets them blind.
    /// * `intra_frame_period` — the default is 0, meaning NO periodic
    ///   keyframes: one IDR at frame zero and nothing after it, so every
    ///   seek decodes from the start of the file and scrubbing a clip
    ///   smears. Two seconds is the usual archive compromise.
    /// * `skip_frames` — on by default. The encoder is allowed to drop
    ///   frames to hit its target, which silently desynchronises a
    ///   capture from the tick stream it is supposed to document.
    /// * `usage_type` — the default assumes camera footage. This is
    ///   synthetic render: flat fills, hard edges, no sensor noise. (The
    ///   non-real-time types read better on paper and the vendored
    ///   encoder rejects them outright — `Invalid usage type = 2`.)
    /// * `qp` — the real quality knob here. In `RC_QUALITY_MODE` with
    ///   frame skipping off the encoder says outright that it will not
    ///   honour a bitrate target ("bitrate can't be controlled ... without
    ///   enabling skip frame"), and the default ceiling of 51 is the
    ///   worst quantiser H.264 has. Capping it is what actually buys the
    ///   gradients and outlines their bits.
    #[new]
    #[pyo3(signature = (path, width, height, fps=60, bitrate=None, max_qp=DEFAULT_MAX_QP))]
    fn new(
        path: &str,
        width: u32,
        height: u32,
        fps: u32,
        bitrate: Option<u32>,
        max_qp: u8,
    ) -> PyResult<Self> {
        if max_qp > 51 {
            return Err(PyValueError::new_err(format!(
                "VideoRecorder: max_qp must be 0..=51, got {max_qp}"
            )));
        }
        if width == 0 || height == 0 || width % 2 != 0 || height % 2 != 0 {
            return Err(PyValueError::new_err(format!(
                "VideoRecorder: width/height must be positive and even, got {width}x{height}"
            )));
        }
        if fps == 0 {
            return Err(PyValueError::new_err("VideoRecorder: fps must be > 0"));
        }
        let bps = bitrate.unwrap_or_else(|| {
            (f64::from(width) * f64::from(height) * f64::from(fps) * BITS_PER_PIXEL) as u32
        });
        let config = EncoderConfig::new()
            .bitrate(BitRate::from_bps(bps))
            .max_frame_rate(FrameRate::from_hz(fps as f32))
            .intra_frame_period(IntraFramePeriod::from_num_frames(fps * 2))
            .rate_control_mode(RateControlMode::Quality)
            .usage_type(UsageType::ScreenContentRealTime)
            .qp(QpRange::new(0, max_qp))
            .skip_frames(false);
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
            pcm: Vec::new(),
            audio_rate: 0,
            audio_channels: 0,
            sidecars: Vec::new(),
        })
    }

    /// Give the recording a soundtrack: interleaved signed-16-bit
    /// little-endian PCM covering the whole clip. Call before `finish`.
    ///
    /// This is a set, not a feed, because the muxer's audio path encodes
    /// in one pass over the complete stream — pretending to stream it
    /// would just be this buffer with extra steps.
    #[pyo3(signature = (pcm, sample_rate=44100, channels=2))]
    fn set_audio(&mut self, pcm: Vec<u8>, sample_rate: u32, channels: u32) -> PyResult<()> {
        if channels != 1 && channels != 2 {
            return Err(PyValueError::new_err(format!(
                "VideoRecorder.set_audio: channels must be 1 or 2, got {channels}"
            )));
        }
        if sample_rate == 0 {
            return Err(PyValueError::new_err(
                "VideoRecorder.set_audio: sample_rate must be > 0",
            ));
        }
        let frame = 2 * channels as usize;
        if pcm.len() % frame != 0 {
            return Err(PyValueError::new_err(format!(
                "VideoRecorder.set_audio: {} bytes is not a whole number of \
                 {channels}-channel i16 samples",
                pcm.len()
            )));
        }
        self.pcm = pcm;
        self.audio_rate = sample_rate;
        self.audio_channels = channels;
        Ok(())
    }

    /// Attach an arbitrary named blob to the file.
    ///
    /// It rides along as a top-level `uuid` box, which is ISO-BMFF's own
    /// extension point: every player walks the top-level boxes and skips
    /// the types it does not know, so the file stays an ordinary .mp4 that
    /// opens anywhere, while carrying enough of the run to rebuild the
    /// scene it shows. Compression is the caller's business — keeping it
    /// out here is what lets the engine stay dependency-free.
    fn set_sidecar(&mut self, name: &str, data: Vec<u8>) -> PyResult<()> {
        if name.is_empty() || name.len() > 255 {
            return Err(PyValueError::new_err(
                "VideoRecorder.set_sidecar: name must be 1..=255 bytes",
            ));
        }
        self.sidecars.retain(|(n, _)| n != name);
        self.sidecars.push((name.to_string(), data));
        Ok(())
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
        // An empty bitstream means the encoder declined to emit this
        // frame. With `skip_frames(false)` that should be unreachable —
        // and it must never be papered over: the old code dropped the
        // NAL while still counting the frame, so the muxed clip came out
        // shorter than the tick stream it claimed to document and
        // everything after the gap slid earlier in time. A capture that
        // quietly disagrees with its own frame count is the sort of
        // instrument defect that makes a judge measure the wrong tick.
        if nal.is_empty() {
            return Err(PyValueError::new_err(format!(
                "VideoRecorder.add_frame: encoder emitted no data for frame {} \
                 — refusing to write a clip that is shorter than its input",
                self.frames
            )));
        }
        self.nals.push(nal);
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
        let pcm = std::mem::take(&mut self.pcm);
        let sidecars = std::mem::take(&mut self.sidecars);
        let (w, h, fps) = (self.width as i32, self.height as i32, self.fps);
        let (rate, channels) = (self.audio_rate, self.audio_channels);
        py.allow_threads(move || -> PyResult<()> {
            let mut muxer = Mp4Muxer::new(Cursor::new(Vec::<u8>::new()));
            muxer.init_video(w, h, false, "perihelion");
            if pcm.is_empty() {
                for nal in &nals {
                    muxer.write_video_with_fps(nal, fps);
                }
            } else {
                // The audio path wants the whole elementary stream in one
                // slice, so the per-frame access units are concatenated
                // (they are already Annex B, start codes and all).
                muxer.init_audio(128_000, rate, channels);
                let stream: Vec<u8> = nals.concat();
                muxer.write_video_with_audio(&stream, fps, &pcm);
            }
            // close() hands back a reference to the writer it has been
            // filling, header rewrite and all
            let mut bytes: Vec<u8> = muxer.close().get_ref().clone();
            for (name, data) in &sidecars {
                let body_len = 4 + name.len() + 8 + data.len();
                let size = 8 + 16 + body_len;
                let size32: u32 = size.try_into().map_err(|_| {
                    PyValueError::new_err(format!(
                        "VideoRecorder: sidecar {name:?} is too large for one box ({size} bytes)"
                    ))
                })?;
                bytes.extend_from_slice(&size32.to_be_bytes());
                bytes.extend_from_slice(b"uuid");
                bytes.extend_from_slice(&SIDECAR_UUID);
                bytes.extend_from_slice(&(name.len() as u32).to_be_bytes());
                bytes.extend_from_slice(name.as_bytes());
                bytes.extend_from_slice(&(data.len() as u64).to_be_bytes());
                bytes.extend_from_slice(data);
            }
            if let Some(dir) = path.parent() {
                std::fs::create_dir_all(dir).map_err(enc_err("create output directory"))?;
            }
            let mut file = File::create(&path).map_err(enc_err("create output file"))?;
            file.write_all(&bytes).map_err(enc_err("write output file"))?;
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

/// Every sidecar blob in `path`, as `(name, bytes)`, in write order.
///
/// The counterpart to [`VideoRecorder::set_sidecar`]: this is what makes
/// a recording a replay rather than a picture of one.
#[pyfunction]
pub fn read_sidecars(py: Python<'_>, path: &str) -> PyResult<Vec<(String, Vec<u8>)>> {
    let path = PathBuf::from(path);
    py.allow_threads(move || {
        let buf = std::fs::read(&path).map_err(enc_err("read file"))?;
        let mut found = Vec::new();
        for_each_box(&buf, |kind, body| {
            if kind != b"uuid" || body.len() < 16 + 4 || body[..16] != SIDECAR_UUID {
                return;
            }
            let body = &body[16..];
            let nlen = u32::from_be_bytes([body[0], body[1], body[2], body[3]]) as usize;
            if body.len() < 4 + nlen + 8 {
                return;
            }
            let name = match std::str::from_utf8(&body[4..4 + nlen]) {
                Ok(s) => s.to_string(),
                Err(_) => return,
            };
            let rest = &body[4 + nlen..];
            let mut dl = [0u8; 8];
            dl.copy_from_slice(&rest[..8]);
            let dlen = u64::from_be_bytes(dl) as usize;
            if rest.len() < 8 + dlen {
                return;
            }
            found.push((name, rest[8..8 + dlen].to_vec()));
        });
        Ok(found)
    })
}
