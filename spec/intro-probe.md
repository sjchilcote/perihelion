---
This specfile covers `game/tools/intro_probe.py`.

---

# The `TESTAMENT` introduction probe

This specfile records a visual probe, not release code. It tests 4 light effects on one external `TESTAMENT` image. Bright bands move across the window rows. Two lights move along the `fold-link` paths. A light patch has a sharp circular edge and does not move.

A beacon turns between two openings. The probe writes a mask and annotations for subsequent use. It sends the frames to FFmpeg for one video.

## Connected component labels — `_label_components`

### Goal

Return the connected components of all selected pixels in a mask.

### Invariants


- Pixels connect only across the same top, bottom, left, or right edge. Pixels that touch only at a corner do not connect.

- Each selected pixel occurs in one returned group.

- The input mask does not change.

### Verification


- Give the function different shapes, shapes that touch at an edge, and shapes that touch only at a corner. Check that the returned components use only the 4 edges.

- Give the function an empty mask. Check that it returns an empty list.

### Implementation

The function reads the height and width from `mask.shape` and finds the coordinates of all set pixels. It sets `visited` to a Boolean array of the same height and width. Each value is `False`.

For each selected pixel that is not in `visited`, the function starts a stack and marks the pixel in `visited`. It removes pixels from the stack and adds each one to the active group. It examines the 4 edge neighbors. It adds a neighbor only when it is in the mask limits, selected, and not in `visited`. The function adds each completed group to the result and returns the list. Each group contains `(y, x)` tuples.

`np.where` supplies candidate pixels one row at a time, from left to right. Thus each group starts with the first selected pixel not examined before. The stack controls the subsequent tuple sequence. The function pushes neighbors in this sequence: below, above, right, and left. The stack examines the last added neighbor first.

### Caveats


- The function has no type check. An input without a shape with two values or NumPy index operation can raise an error.

- The Python stack and one tuple for each selected pixel can use much memory for a large mask.

## Window extraction — `extract_windows`

### Goal

Find small warm light groups only in the 4 known window bands of the source image. Return a pixel mask and the center of each accepted group.

### Invariants


- A candidate pixel is in a set window band. Channel 0 is more than 195, and channel 1 is more than 165. Channel 2 is less than 165. Channel 0 minus channel 2 is more than 55.

- An accepted group has from `min_size` through `max_size` pixels. Its width is the highest x value minus the lowest x value plus one. Its height is the highest y value minus the lowest y value plus one. Its width and height are each at most `max_bbox` pixels.

- The default limits are 3, 80, and 16.

### Verification


- Run the function on `foldlink_d_fullres.png`. Check that the mask contains small lights in the 4 bands and does not select other warm marks.

- Supply groups at each dimension limit and each `max_bbox` limit. Check that limit values are accepted and larger values are rejected.

- For each accepted group, check its center against the arithmetic mean x and arithmetic mean y of its pixels.

### Implementation

The function sets all values in a Boolean mask of the image height and width to 0. It sets the slices from `WINDOW_BAND_RECTS` to 1. It changes the 3 color channels to signed 32-bit numbers before the subtraction test. It mixes the color test with the band mask and sends the result to `_label_components`.

For each group, the function first rejects a pixel count that is not in the set limits. It reads x values into one list and y values into a second list. Then it rejects a height or width above `max_bbox`. It copies each accepted pixel into a new Boolean mask. It adds the arithmetic mean of the x and y lists to `centers`. It returns the Boolean mask and center list.

### Caveats


- The 4 bands and all color limits fit one source image. A changed image can find no windows or can select other marks.

- Groups that touch only at a corner stay different.

- NumPy cuts each slice at the image limits with no console output.

## Polyline color sample — `polyline_avg_color`

### Goal

Find one typical RGB color from image samples around all points of a polyline. Each sample has the same width and height.

### Invariants


- Each sample is cut to the image limits.

- The default distance from the sample center to an edge is 6 pixels.

- The result has 3 Python integers, with truncation of each channel arithmetic mean.

### Verification


- Use an image that has one color and points at the center and edges. Check that the function returns that color.

- Use known patches with different colors. Check the arithmetic mean across all sampled pixels. Do not use the arithmetic mean of the patch arithmetic means.

### Implementation

For each `(x, y)` point, the function selects a slice from `x - half_w` to but not through `x + half_w`. It uses the same range for y and limits the values to the image width and height. It changes each patch to rows of 3 channels. Then it calls `np.concatenate` on all rows and calculates the arithmetic mean on axis zero. It changes each channel mean to an integer and returns a tuple.

### Caveats


- An empty polyline causes `np.concatenate` to raise an error. Some points can select empty patches while other points select patches with pixels. Empty patches add no rows, and patches with pixels give the result. If all patches are empty, the arithmetic mean has no values. Its results are not numbers, and conversion to integers raises an error.

- The sample is 12 pixels wide with the default value, not 13 pixels. The named distance to an edge does not include the two end pixels.

- Long polylines or polylines with many close points can sample the same source pixels more than once. This gives those pixels more weight.

## Probe image preparation — `bake_sprite`

### Goal

Return an RGB copy with a second arc and a sharp circular light patch. Do not change the source array.

### Invariants


- The second arc uses the palette from the arithmetic mean of the first arc. Its edge is 60 channel levels less bright and does not go below zero.

- The arc has a less bright outer line, a color fill, curved segment connections, and filled circular ends.

- The light patch changes only pixels at or in radius 34 from `(1030, 275)`. Its brightness does not decrease with distance.

- The returned array uses unsigned 8-bit RGB values.

### Verification


- Compare the input before and after the call. Check that it does not change.

- Examine the second arc, which has 5 points. Check its 30-pixel fill and 34-pixel outer line. Check that each end circle has a radius of 15 pixels.

- Examine the horizontal line through `(1030, 275)`. Check that the pixel at x=1064 changes and the pixel at x=1065 does not. These points are 34 and 35 pixels from the patch center. Check that all output channels stay from 0 through 255.

### Implementation

The function copies `rgb` into a Pillow image. It calls `polyline_avg_color(rgb, ARC_A_POLYLINE)` to calculate `surf_color`. It subtracts 60 from each channel for `dark_edge` and limits the result to zero.

It draws `ARC_B_POLYLINE` first with the less bright color and width 34, then with the surface color and width 30. The two lines request curved segment connections. It draws a filled circle of radius 15 at the first and last points.

The function changes the image to a floating-point NumPy array and calculates a full coordinate grid. It selects each pixel with a squared distance no more than the squared radius. It mixes 55 percent of that pixel with 55 percent of `(255, 214, 150)`. It limits the channels, multiplies them by 1.65, and limits them again. It returns the full image as unsigned 8-bit values.

### Caveats


- The first mix weights total 1.10, not 1.0. The subsequent multiply operation frequently limits channels at 255.

- The second arc is a probe image change. The source image did not contain a clear second arc after 4 image-model tries.

- `AIRLOCK_LEFT` and `AIRLOCK_RADIUS` record the stated shape source, but this function does not use them. The output is a circle with the independently set radius 34.

## Starfield layer data — `make_starfield_layer`

### Goal

Return position, dimension, and brightness arrays for one layer of points of light in a rectangle. Use a seeded NumPy random Generator.

### Invariants


- Each returned array has `n_stars` values.

- Positions use an equal random distribution from zero through the layer width and height. Dimensions and brightness values use their supplied ranges.

- Random state comes only from the supplied NumPy random Generator.

### Verification


- Use two NumPy random Generator objects with the same seed and equal inputs. Check that all 4 returned arrays are equal.

- Check the length and numeric range of each array.

### Implementation

The function calls `rng.uniform` 4 times. It samples x positions from 0 to `w` and y positions from 0 to `h`. It samples dimensions from the expanded `size_range` and brightness values from the expanded `bright_range`. It returns the 4 arrays in that sequence.

Each result is a NumPy floating-point array. `rng.uniform` usually selects values from a range that includes only its low limit. The range does not include its high limit. In unusual conditions, floating-point rounding can give the high value.

### Caveats


- The function does not check the inputs. A negative `n_stars` causes NumPy to raise `ValueError` for a negative dimension. A range with its high value below its low value causes `Generator.uniform` to raise `ValueError`. A zero width or height fills a position array with zero. A negative width or height causes `Generator.uniform` to raise `ValueError`. A subsequent draw call raises an error when it applies modulo with a zero dimension.

## Starfield layer draw — `draw_starfield_layer`

### Goal

Draw one layer of points of light that moves on a Pygame surface. It wraps at the requested offset and uses the requested tint. Its parallax movement shows its depth.

### Invariants


- The two offset values wrap by the layer width or height.

- A dimension at most 1.0 draws one pixel. A larger dimension draws a circle with an integer radius of one pixel or more.

- Each RGB channel is its tint channel multiplied by the point brightness. The result is an integer.

### Verification


- Draw one known light point with offsets of zero, one full layer, and more than one full layer. Check that the positions wrap to the same pixels.

- Test dimensions on the two sides of 1.0. Check the pixel and circle paths.

- Give arrays with different lengths. Check that the draw operation stops at the shortest array because `zip` controls the loop.

### Implementation

The function changes each offset with modulo. For each tuple from the 4 point arrays, it subtracts the offset and applies modulo to each position. It multiplies tint by brightness and changes the channels to integers. For a dimension at most 1.0, it sets one pixel at the integer coordinates. For a larger value, it draws a circle. The radius is the larger of one and the integer part of the dimension.

### Caveats


- The function does not limit colors. Brightness or tint inputs that put a channel out of the Pygame color range can raise an error.

- Different input lengths do not raise an error. Light points after the shortest array are ignored with no console output.

- A zero width or height causes a division by zero error in modulo.

## Polyline position — `polyline_point`

### Goal

Use linear interpolation to find a point along a polyline. Give each segment equal phase time.

### Invariants


- The function limits `u` to the range from 0 through 1, with the two end values.

- Zero selects the first point and one selects the last point.

- Each segment receives the same part of the phase, without relation to its geometric length.

### Verification


- Test values below zero, at zero, between segment boundaries, at one, and above one.

- Use segments with different lengths. Check that phase 0.5 selects the boundary in a line with two segments. It does not select 0.5 of the path distance.

### Implementation

The function sets `n` to one less than the point count and limits `u`. It multiplies `u` by `n`. The integer part selects the segment, but the last value selects segment `n - 1`. The fractional part is the interpolation value. The function calculates a linear interpolation for x and y between the selected pair and returns a tuple.

### Caveats


- An empty polyline raises `IndexError`. A polyline with one point returns that point for each finite `u`. This occurs because the two selected endpoints refer to the same element. The function does not check the two inputs.

- The function name does not mean constant travel speed. It gives equal phase time to each segment. Thus geometric speed changes when adjacent segments have different lengths.

## Signed angle difference — `angdiff`

### Goal

Return the shortest signed difference from angle `b` to angle `a`, in degrees.

### Invariants


- The result can equal -180 degrees but is always less than 180 degrees.

- Values that are different by full turns have the same result.

### Verification


- Check the result for equal angles and the two sequences of a small difference across zero. Also check differences of full turns and a 180-degree difference.

### Implementation

The function adds 180 to `a - b`, applies modulo 360, subtracts 180, and returns the result.

### Caveats


- An opposite direction always returns -180, not 180.

- The function accepts values that let it calculate and apply modulo. It has no unit check.

## Probe render and command — `main`

### Goal

Render a 13-second, 1280 by 720 test video with 60 frames each second and 4 light effects. Write a window mask and `fold-link` annotation record adjacent to the source image. Print progress and output locations to the console.

### Invariants


- The command sets `SDL_VIDEODRIVER` to `dummy` only when the environment does not set it.

- The output has 780 RGB frames and no audio. FFmpeg writes H.264 video with `yuv420p` output and CRF 18. It can replace the output file.

- Seed 1337 sets all 3 layers of points of light.

- The source image is `media/concepts/testament_exterior_v3/foldlink/foldlink_d_fullres.png`. The video is `media/concepts/testament_exterior_v3/testament_intro_probe.mp4`.

- The command also writes `window_mask.png` and `foldlink_annotations.json` in the source image directory.

- The constants in source coordinates are `APERTURE_A = (735, 245)`, `APERTURE_B = (730, 400)`, `HUB_CENTER = (700, 270)`, and `RING_CENTER = (680, 380)`.

- `ARC_A_POLYLINE` is `[(752, 233), (800, 238), (850, 258), (900, 300), (938, 350), (963, 412)]`. `ARC_B_POLYLINE` is `[(722, 393), (690, 372), (662, 335), (645, 290), (636, 250)]`. `ARC_PLATE_HALF_WIDTH` is 15.

- `WINDOW_BAND_RECTS` is `[(280, 65, 650, 120), (790, 65, 1010, 165), (140, 635, 760, 685), (990, 540, 1260, 650)]`. Each tuple is `(x0, y0, x1, y1)`. The slice does not include each high limit.

- The recorded source shape has `AIRLOCK_LEFT = (245, 605)` and `AIRLOCK_RADIUS = 42`. The applied patch uses `SUNBEAM_CENTER = (1030, 275)`, `SUNBEAM_RADIUS = 34`, `SUNBEAM_COLOR = (255, 214, 150)`, and `SUNBEAM_BOOST = 1.65`.

- The beacon has radius 520 and period 6.0 seconds. Its fold tolerance is 9.0 degrees, and its moved offset is 205.0 degrees.

### Verification


- Run `SDL_VIDEODRIVER=dummy uv run python game/tools/intro_probe.py`. Check the source image, window count, annotation path, frame progress, and last video path. The progress frames are 0, 120, 240, 360, 480, 600, and 720.

- Check that the mask is an 8-bit image. Accepted window pixels must have color (255, 255, 255). All other pixels must have color (0, 0, 0).

- Parse the JSON and check the image path from the repository and the source dimensions. Check the openings, arcs, source note, arc width, light values, bands, count, and circle center.

- Examine the video. Check that the 3 point depths move at clearly different rates. Check that 6 warm brightness bands move across the windows around the circle. Check that one paired light moves to the first point of the first arc near opening A. Check that the other light moves from the first point of the second arc near `APERTURE_B` with the same phase.

- Check that the sharp circular patch does not move. Check that the beacon turns from the hub and goes into opening A when the two directions almost align. Check that you can see it again from `APERTURE_B` in a direction that does not continue the first line.

- Use a media probe to check the 1280 by 720 dimensions and the rate of 60 frames each second. Check that the video lasts about 13 seconds and uses H.264 video and `yuv420p`, with no audio.

### Implementation

At module read, the code finds the repository from the script path and calculates all input and output paths. It sets the screen and time values. It also sets the image annotations, window rectangles, light values, circle geometry, and beacon geometry. Pygame starts before file reads. The code calls `np.random.default_rng(SEED)` for the random Generator.

The function prints `loading sprite: {SPRITE_PATH}` and opens the source image through Pillow. It changes the image to RGB and then to a NumPy array. It records width and height. It calls `extract_windows` and prints `windows detected: {count}`. It writes the Boolean mask multiplied by 255 to `window_mask.png`. It calls `bake_sprite` for the output copy.

The JSON record has these keys at the outer JSON level: `sprite`, `sprite_size`, `fold_link`, `sunbeam`, `beacon`, `window_band_rects`, `window_centers_found`, and `ring_center_for_phase`. Their sequence is the sequence in this list. `sprite` is the path string from the repository. `sprite_size` is `[width, height]`.

`fold_link` has `aperture_a`, `aperture_b`, `arc_a_polyline`, `arc_b_polyline`, `arc_b_source`, and `plate_half_width_px`. JSON changes all coordinate tuples to arrays. `arc_b_source` records that 4 image-model tries did not give a clear second arc. It records that this path and arc are probe-only image changes. `plate_half_width_px` is 15.

`sunbeam` has `center`, `radius`, `key_color`, and `shape_source`. The first 3 values come from the applied patch constants. `shape_source` records `circular, radius matched to the left airlock wheel-door`. It also records that the patch moves to a different frame connection with low brightness and no opening. The circular shape comes from `AIRLOCK_LEFT`, but the radius does not. The recorded `AIRLOCK_RADIUS` is 42, and the set `SUNBEAM_RADIUS` is 34.

`beacon` has `hub_center`, `radius_px`, `period_s`, `fold_tolerance_deg`, and `displaced_offset_deg`. `window_band_rects` contains the 4 rectangles. `window_centers_found` contains the accepted group count. `ring_center_for_phase` contains `RING_CENTER`. The code writes the record as JSON with 2-space indentation and no last newline. It then prints the annotation path.

The source image fits in 86 percent of the two screen dimensions. The smaller width or height scale is used. The displayed dimensions use their integer parts. `pygame.transform.smoothscale` scales the display image. The code puts it at equal integer distances from the screen edges. A local conversion changes source image points to screen positions with the floating-point scale.

The far layer of points of light has 220 points, dimensions 0.6 through 1.2, brightness 0.25 through 0.55, speed `(3, 1)`, and tint `(150, 160, 200)`. The middle layer has 120 points, dimensions 1.0 through 1.8, brightness 0.4 through 0.75, speed `(9, 3)`, and tint `(180, 190, 220)`. The near layer has 50 points, dimensions 1.4 through 2.6, brightness 0.6 through 1.0, speed `(20, 7)`, and tint `(210, 215, 255)`.

The function calls `OUT_VIDEO.parent.mkdir(parents=True, exist_ok=True)`. It starts the `ffmpeg` executable with `-y -f rawvideo -pix_fmt rgb24 -s 1280x720 -r 60 -i - -an -c:v libx264 -pix_fmt yuv420p -crf 18`, followed by the output path. It supplies frames through stdin and discards FFmpeg stdout and stderr. It calls `pygame.Surface((SCREEN_W, SCREEN_H))` for the surface in memory.

For each frame, time is the frame number divided by 60. The function clears the surface to `(0, 0, 0)`. It draws the far, middle, and near layers of points of light in that sequence. It then puts the prepared sprite on the points of light and draws effects 1, 2, and 4 in that sequence. Effect 3 is part of the prepared sprite.

For the first effect, each found window uses its angle around source `RING_CENTER`. The phase moves at 0.12 cycles each second. A cosine calculates 6 bright bands around the circle. Brightness is 0.15 or more. The light color is brightness times `(255, 220, 120)`.

Each light is a circle at the found center. Its radius is two or the integer part of 3 times the image scale.

For effect 2, a 3.2-second phase restarts after each period. The first arc light starts at `(963, 412)` and moves rearward to `(752, 233)`, near opening A. The second arc light starts at `(722, 393)` near `APERTURE_B` and moves forward to `(636, 250)`. The modulo phase is always less than one. Each light restarts before its destination endpoint. The two lights do not touch the correct opening coordinates.

The function returns the two lights to their start positions together after each phase. It draws a `(255, 245, 210)` circle at each point. Its radius is the larger value of 4 and the integer part of 9 times scale. An inner `(255, 255, 255)` circle uses the larger value of two and the outer radius divided by two.

Effect 3 is the circular patch that `bake_sprite` puts into the prepared image. It does not move and does not have frame-loop animation.

For effect 4, the beacon turns once in 6 seconds. Its angle continues above 360 degrees, and trigonometric functions give the direction again. The function compares it with the screen angle from the hub to opening A. The usual line has color `(255, 250, 225)`. When the difference is more than the closed 9-degree tolerance, this line starts at the hub. Its length is 520 source pixels multiplied by the display scale.

A `(255, 255, 255)` circle marks its far end.

When the difference is in the closed 9-degree tolerance, the first line ends at opening A. A `(255, 255, 255)` circle marks that opening. A second line starts at `APERTURE_B` and extends for 140 source pixels multiplied by the display scale. It uses the set screen angle to opening A plus 205 degrees. A `(255, 255, 255)` circle marks `APERTURE_B`. No circle marks the far end of the second line.

The function changes the surface to RGB bytes and writes each frame to FFmpeg stdin. Before the loop, it prints `rendering 780 frames...`. For frame numbers divisible by 120, it prints `  frame {frame_i}/780 (t={time:.1f}s)`. After the loop, it closes stdin, waits for FFmpeg, and prints `wrote {OUT_VIDEO}`. File execution calls `main`. Import does not call it.

### Caveats


- The docstring states that the light patch has the opening shape, but the implementation draws a circle. It does not read the recorded `AIRLOCK_LEFT` position or `AIRLOCK_RADIUS` when it draws that circle.

- Defect: the JSON `shape_source` records `radius matched to the left airlock wheel-door`. This text does not agree with the values. The recorded circle radius is 42, but the patch radius is 34. Only the circular shape agrees.

- `ring_center_screen` is calculated but not used.

- Defect: the command does not test the FFmpeg return code, and it discards FFmpeg stderr. FFmpeg can read the frame stream and then return a result other than zero. In this condition, the Python process continues to print `wrote` and returns zero. An encoder that closes the pipe before the stream ends can cause a `BrokenPipeError` and a nonzero Python result.

- Defect: an FFmpeg start failure, missing source image, image error, write failure, or broken pipe raises an error. Files or directories can change before that error. The function has no cleanup path and does not call `pygame.quit`.

- Defect: the code writes `window_mask.png` before it calls `OUT_VIDEO.parent.mkdir`. The source image directory must be there before the run.

- The script replaces all 3 outputs. FFmpeg also replaces a previous video because the command includes `-y`.

- The prepared arc and light patch are only in memory. The mask and JSON are the only image-data artifacts for subsequent use.

- Effect 3 is constant because it is put into the prepared image. The loop has animation code only for effects 1, 2, and 4.

- The output operation has no event loop, interactive control, or interval between frames. Frame output runs as fast as the process and FFmpeg let it run.

- The scaled image uses an RGB surface. RGB conversion removes transparency from the source.

- Decision open (see `spec/open-questions.md`, item `PROBE-LIGHT-SHAPE`): Must the sharp light patch stay circular? Or must it use the opening shape and the recorded `AIRLOCK_LEFT` and `AIRLOCK_RADIUS` values?

- Decision open (see `spec/open-questions.md`, item `PROBE-EFFECT-THREE`): Must effect 3 stay constant, or must it have animation?

- Decision open (see `spec/open-questions.md`, item `PROBE-OVERWRITE`): Must the command replace all 3 output files without a user check?

- Decision open (see `spec/open-questions.md`, item `PROBE-FFMPEG-FAILURE`): Must an FFmpeg failure give an error that the user can see? Must it also give a nonzero process result and no `wrote` text?

- Decision open (see `spec/open-questions.md`, item `PROBE-SECOND-ARC`): Is the second arc in this probe an accepted visual direction? Or is it temporary image work that a new image must replace?
