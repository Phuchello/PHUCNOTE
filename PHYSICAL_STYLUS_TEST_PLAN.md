# Physical stylus acceptance plan

**NOT EXECUTED:** only Android 15 `medium_tablet` / Pixel Tablet emulator is
connected. No Y700 Gen 4 or AP501U measurements, pressure levels, tilt support,
sampling-rate claims, 120-Hz run or physical pen-to-display latency are reported.
No root is needed. The emulator is about 60 Hz and uses software graphics.

## Setup and evidence

Use a disposable note, never an original user document. Record device/model,
Android/ZUI build, pen firmware if actually available, application versions,
screen orientation/resolution/DPI, measured refresh, battery/charging state,
temperature and screen protector. Disable unrelated recording/overlays for timing
runs; disclose any video/diagnostic overhead. Keep source data unchanged.

Reuse the existing Vietnamese toolbar overflow **Chẩn đoán bút Y700**. Start
capture, write, stop and export its local JSON. It records native MotionEvent
tool/device/pointer IDs, raw/historical pressure/tilt/orientation, contact size,
timestamps, cancel/multitouch, device MotionRanges, refresh changes, Choreographer,
window metrics, Flutter build/raster/total frames and buffer-drop counters. The
panel shows model/rate/count/frame summaries; full axes are in the exported JSON.
Do not interpret a missing MotionRange or constant axis as affirmative support.

For each pointer stream report actual observed pressure min/max/variation,
pressureMin/Max MotionRange and tool type. Separate hover/down/move/history/up and
exclude same-timestamp events when describing sample intervals. Compare Flutter
delivery with the native observer. Stable-pressure plateaus must be included.
Plot tilt/orientation only if actual data varies; no claimed nib tilt effect for
the current Flutter renderer. Review cancel and palm/finger traces individually.
Any dropped capture samples invalidate frequency and missing-input conclusions.

## Repeatable same-device protocol

1. Warm the device equally; keep refresh fixed where the device permits it.
   Measure the active mode rather than trusting a settings label. Run separate
   60/120-Hz trials only if the physical display actually offers both.
2. Use the benchmark's 15 patterns as a manual worksheet. Write three repetitions
   at the same document scale and visually matched widths/colors. Record actual
   input; synthetic traces are only a separate controlled geometry test.
3. For PHUCNOTE, compare current renderer, isolated Flutter candidate and native
   spike. Rotate run order across three repetitions. Keep prediction on/off as
   separately labeled native trials; do not combine it with another change.
4. Compare installed, supported **Android** competitor apps on this same device:
   Goodnotes, Notewise, Noteshelf 3, Flexcil and Concepts when available. Include
   Samsung Notes only if officially supported/working; mark it NOT AVAILABLE
   rather than sideloading an unsupported package. Record exact pen, stabilization,
   pressure and latency settings; identical slider values are not calibration.
5. Write five minutes of rapid lecture notes and five minutes of small Vietnamese
   handwriting; then a long curve/loop, full dense page, formulas and network
   arrows. Include single taps, very short accents and light/heavy/plateau input.
6. Rest the palm naturally; test left/right-hand positions, a finger arriving
   before/after stylus, touch cancel while pen is down, pen cancel, barrel/inverted
   eraser if the hardware supports them, pinch/pan and zoomed erasing. Count lost,
   spurious, duplicated or unexpectedly canceled strokes. Confirm undo/redo order.
7. Pan/zoom between and during strokes; toggle Zen, change orientation, fit A4,
   switch tools mid-gesture, save/reopen and background/resume. Compare both raw
   coordinates and final appearance. Predictions must never become saved data.
8. Capture no-root Perfetto (`sched gfx view input`), frame distributions, process
   PSS/RSS/native heap and consistent thermal state. Use fresh controlled phases
   for allocation measurement; do not confuse heap usage with cumulative bytes.

For pen-to-display latency, use an external high-frame-rate camera with the tip
and screen visible. Count tip movement to first visible ink, separately from
finalization; report camera quantization, rolling-shutter uncertainty, number of
samples and p50/p95/p99. Screen recording and geometry Stopwatches cannot measure
physical latency. Avoid unsupported precision if the camera is only 60 fps.

## Vietnamese visual rubric

Score blinded crops 1–5 for each criterion, with at least two readers; preserve
full-resolution originals and matching zoom/width. Do not rank competitors from
the synthetic diagram alone.

| Criterion | Required observations |
|---|---|
| Accent survival | Separate acute/grave/hook/tilde/dot; single taps stay visible |
| Compound diacritics | `ấ ề ễ ộ ữ` keep hat/horn/tone components distinguishable |
| Letter counters | Small `a e o g` loops remain open; no blobs or false joins |
| Corners and equations | Hat points, arrowheads, `x₂`, fractions and minus remain legible |
| Width and caps | Ballpoint stable; gel clean; fountain controlled variation, not triangular accents |
| Tip tracking | Visible endpoint trail/overshoot, jitter and lift-off jump recorded separately |
| Highlighter | Stable opacity; expected separate-stroke overlap; no accidental self-overlap blotch |
| Wet/dry/reopen | Same geometry/style/order without jump, drift or disappearing marks |

Acceptance requires zero lost/corrupted canonical samples/history in controlled
runs, no layout loss, and no unexplained wet/dry/reopen change. Performance targets
are in `INK_QUALITY_BENCHMARK_SPEC.md`; architecture adoption needs a reproducible
same-device benefit and a compatible completed-stroke representation. Until then,
all hardware and competitor parity gates remain **NOT EXECUTED**.
