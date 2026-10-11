# Ink quality benchmark specification

Recorded before measurements, 2026-10-11. Requested baseline `1087b5e` is an
ancestor of the clean starting checkout `daedb6971073b0aeb9347f7e567458d274337e4a`.
The intervening PDF experiment and committed-path cache are retained. Production
editor, document geometry and `.bfly` schema are frozen for this checkpoint.

## Predeclared gates

- Candidate A1: append-only incremental perfect_freehand preprocessing, keeping
  the existing full outline and path construction. Target: at least 20% lower
  long-stroke geometry p95, with exact processed points and identical rendered
  pixels at tested prefixes and completion. No claim of constant-time outlines.
- Candidate A2: repaint-only testbed shell, after A1 is measured independently.
  Target: fewer widget builds, no worsening of build/raster p95 by more than 10%
  in comparable runs. This shell is not a production editor replacement.
- Premium behavior experiments: explicit real pressure, a pressure curve, short
  taper and completed-end options are session-only. A change in historical pixels
  is a compatibility failure for production adoption, even if it looks attractive.
- Native B: stable AndroidX Ink isolated package. Gate: compile, launch, retain
  completed ink and raw synthetic inputs, cancellation/lifecycle smoke checks.
  Native superiority requires the same physical input and comparable build modes;
  emulator microbenchmarks cannot select B over A.
- Frame budgets: 16.667 ms at 60 Hz; 8.333 ms at 120 Hz. Report actual observed
  refresh separately. A computed 120-Hz budget is not a measured 120-Hz run.
- No dropped raw samples, changed coordinates/styles, duplicate history or schema
  changes. Retain all failures and distributions, not just favorable averages.

## Inputs

`tool/ink_benchmark/traces.dart` is the source of deterministic traces. Each
sample carries global x/y, monotonic microsecond timestamp, normalized synthetic
pressure, tilt in radians and explicit synthetic tool provenance. These are
stylized test marks, not captured human writing or AP501U calibration.

| ID | Input | Purpose |
|---|---|---|
| 01 | Single-point dots | Pressure-independent legacy dot and round cap |
| 02 | Fine strokes | Small-mark survival |
| 03 | Long continuous curves | Prefix work scaling |
| 04 | Rapid zigzags | Corner smoothing and velocity sensitivity |
| 05 | Tight loops | Joins and blob inspection |
| 06 | Sharp corners | Corner displacement |
| 07 | Slow handwriting motifs | Low-speed starts and ends |
| 08 | Fast lecture motifs | Timestamp-sensitive comparison |
| 09 | Vietnamese `Tiếng Việt` motifs and separate accents | Hat, acute, dot separation |
| 10 | Formula `x₂ + y² = 1` components | Small subscript/superscript |
| 11 | Topology nodes and arrows | Sharp direction changes |
| 12 | Light-to-heavy pressure ramp | Width response |
| 13 | Sudden pressure changes and plateau | Pressure-mode discontinuity |
| 14 | Dense page | Committed cache capacity / thrashing |
| 15 | Pan/zoom transforms between and during strokes | Coordinates and width |

Replay lengths: 128, 512, 2048 and 4096 samples. Densities: 32, 128 and 256
strokes. Preserve pressure plateaus, duplicates, stationary inputs, very short
prefixes and late pressure variation. Test all three existing presets and the
existing highlighter. No calligraphy experiment until writing pens pass physical
quality review.

## Measurements and reproducibility

Keep input/controller cost, preprocessing, outline/path generation, paint
recording, Flutter build, raster and total frame spans separate. Record raw
timings plus nearest-rank p50/p95/p99, count and maximum. Warm up before timing;
alternate A/B order. Retained-point counts are allocation proxies, not bytes.
Use VM allocation/heap counters if supported and Android PSS/RSS snapshots;
explicitly report unsupported allocation instrumentation.

Synthetic event timing and CPU durations never mean physical pen-to-display
latency. Frame jank counts build OR raster over the observed refresh budget.
Report transform-only and active-stroke phases separately. Count testbed widget
builds and geometry invocations. Store trace, parameters, environment, screenshots
and commands under `artifacts/ink-engine/`; comparison image is
`PEN_RENDERING_VISUAL_COMPARISON.png`. Inspect actual images after rendering.

Focused commands will be recorded with results in `INK_ENGINE_A_B_RESULTS.md`.
Run unchanged baseline tests first, then focused tests, full `flutter test test/`,
`flutter analyze`, profile emulator replay and relevant existing Android
regressions. Physical Y700/AP501U and competing apps are separate NOT EXECUTED
gates until a real device is connected.
