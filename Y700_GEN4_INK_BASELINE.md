# Ink baseline

Baseline production source: clean develop
`e83969c4e8a528aa54d19e46288af6a8b4c08ccf`.
Flutter 3.47.7 / Dart 3.13.5 / perfect_freehand 2.5.2+1.
Hardware target Y700 Gen 4 + AP501U: **NOT EXECUTED**.

Measured environment: existing Android 15 medium_tablet emulator, Pixel_Tablet,
2560×1600, density 320, observed active refresh **60.000004 Hz**. Emulator selected
software gfxstream/SwiftShader after its host Vulkan query failed. These timings
are synthetic regression evidence, not Y700 throughput or pen latency.

## Reproducible workload

`integration_test/support/y700_trace.dart` creates 120 strokes × 128 points,
distributed over three existing pen presets. Eighty one-pixel pan frames are
replayed; the first ten direct paint recordings warm up. Each frame additionally
records a painter into a PictureRecorder to isolate paint CPU work. A 240-move
stylus-kind Flutter replay then measures active geometry and schedules frames.
The replay retains every point and commits one extra stroke.

No physical stylus events were generated. The harness deliberately adds direct
paint/geometry work beyond normal editor use. Frame percentiles include both
phases and initial workload frames; they are not a steady-state latency test.
`baseline.json` contains the exact committed trace, presets, 324 frame records and
CPU distributions. Before/after run logs and screenshots are retained.

| Baseline metric (ms) | p50 | p95 | p99 |
|---|---:|---:|---:|
| Direct committed paint CPU, 70 recordings | 20.134 | 32.704 | 92.055 |
| Active geometry CPU, 240 prefixes | 0.168 | 0.599 | 0.787 |
| Flutter build | 6.843 | 33.527 | 49.344 |
| Flutter raster | 41.476 | 58.553 | 82.439 |
| Flutter totalSpan | 74.913 | 99.349 | 158.660 |

At observed 60.000004 Hz, budget = 16.6666656 ms. Build OR raster over-budget:
**323 / 324 (99.69%)**. This emulator workload fails a smooth-frame gate.
Physical display timing/latency, ten-minute handwriting quality and palm tests
are NOT EXECUTED.

## Confirmed source findings

1. Every committed repaint rebuilt all visible perfect_freehand paths. Pan, zoom,
   paper changes and new commits repeated work for unchanged ink.
2. CanvasView forwarded a touch cancellation to `cancelActivePoints` while a
   stylus was down, losing the stylus gesture. Both tracked-before-stylus and
   ignored-after-stylus cases failed the new regression before correction.
3. Active geometry still regenerates each prefix; notifications also rebuild
   listeners. No change was made without evidence that safe batching is needed.
4. Capture clamps pressure to 0.1–1.0. Geometry switches to simulated pressure
   when samples differ by no more than 0.01. A constant real-pressure plateau is
   therefore indistinguishable from a simulated-pressure source in saved data.
   Calibration must await actual MotionRange and AP501U traces.
5. Single-point dots use half nominal width; the current saved style has no
   source/simulation flag or separate taper settings. Changing interpretation
   globally would change old strokes. No schema or legacy geometry was changed.
