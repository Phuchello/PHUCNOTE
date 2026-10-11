# Ink engine A/B results

**Decision: A — optimize the existing Flutter engine, with candidates still
isolated. Physical acceptance is NOT EXECUTED.** No production editor, schema,
coordinates, settings or original notes were changed. All seven requested
deliverables and reproducible candidate sources are retained.

## Environment and baseline

2026-10-11, Windows / existing SDKs. Requested baseline `1087b5e` is an ancestor
of actual clean starting `develop` HEAD `daedb6971073b0aeb9347f7e567458d274337e4a`.
The previous committed-cache/diagnostics checkpoint was retained, not reimplemented.
Baseline `flutter test test/`: **123 PASS**; analyze: **no issues**.

Flutter 3.47.7 / Dart 3.13.5 / perfect_freehand 2.5.2+1. Android AGP 9.1.0,
Kotlin 2.4.0, JDK 17, existing SDK 36. Android 15 `medium_tablet`, x86_64
Pixel Tablet emulator, 2560×1600 / density 320, software graphics. Actual refresh
**60.000003814697266 Hz**, budget 16.667 ms. No 120-Hz or higher-refresh physical
run. No Y700/AP501U or competing-app parity measurements.

Targets were written in `INK_QUALITY_BENCHMARK_SPEC.md` before measurements.
The fixtures contain all 15 requested patterns with synthetic timestamps,
pressure/tilt and provenance. Stylized Vietnamese/formula marks are not captured
human handwriting. Each raw JSON/timing distribution and inspected PNG is under
`artifacts/ink-engine/`; CPU milliseconds never mean pen-to-display latency.

## A1: incremental preprocessing, unchanged geometry

The full legacy outline and path conversion remain. Only append preprocessing
and repeated-prefix reuse change. Exact processed-point values and bounds are
checked at every catalog prefix for all three pens, including duplicates,
stationary input and late pressure changes. Selected wet prefixes, transforms,
undo/redo and `.bfly` reopen compare identical pixels. Canonical coordinates and
properties are retained. The algorithm still performs a full O(n) outline pass.

Desktop test-engine measurements (CPU, not release app performance):

| Samples | Baseline geometry p95, two runs (ms) | A1 append+geometry p95 (ms) |
|---|---|---|
| 128 | .146 / .097 | .120 / .066 |
| 512 | .283 / .228 | .215 / .173 |
| 2048 | 1.275 / 1.046 | 1.051 / .661 |
| 4096 | 2.923 / 3.041 | 1.648 / 1.505 |

4096-point p95 decreases about **43.6% / 50.5%**. One 2048-point desktop run
misses the 20% target (17.6% decrease); do not hide it. Cumulative baseline CPU
at 512/2048/4096 in repeat 1: 64.204 / 981.323 / 4726.808 ms; A1: 45.466 /
626.761 / 2795.336 ms. The coefficient improves; quadratic cumulative outline
work remains. Native Path/mesh allocations are not bounded by this timing result.

Matched alternating-order profile microbenchmarks on the emulator:

| Samples | Baseline p95 (ms) | A1 combined p95 (ms) |
|---|---|---|
| 128 | .055 / .051 | .046 / .049 |
| 512 | 1.220 / 1.410 | .173 / .221 |
| 2048 | 1.962 / 1.896 | 1.277 / 1.324 |

Long-prefix p95 decreases **34.9% / 30.2%**. Small-prefix benefit is smaller;
initial profile microbenchmarks also contained 128-point regressions. All raw
values are retained; no tuning was performed to chase the favorable run.

## A2: repaint-only shell and actual frames

The same fixed 32-stroke dry page, 1024-point wet trace, four samples per paint,
wet-layer pan/zoom and 30 unchanged-input wet transforms run in baseline, A1 and A2.
The dry painter stays at identity: this is synthetic wet-layer viewport work,
not synchronized editor/dry-page pan/zoom acceptance. A1 changes only
geometry. A2 adds repaint-only wiring to the isolated shell. Builds **287 → 287
→ 1**, paints 287 each; this does not count production HomeScreen/toolbar builds.
Controller-only input processing is separately recorded in the JSON.

Final profile run, p50 / p95 / p99 in ms:

| Metric | Baseline | A1 | A2 |
|---|---|---|---|
| Active geometry | .347 / 2.539 / 4.796 | .210 / .884 / 1.678 | .179 / .420 / 1.790 |
| Flutter build | 1.353 / 4.176 / 6.999 | .919 / 2.080 / 2.943 | .804 / 1.907 / 2.685 |
| Flutter raster | 17.613 / 43.042 / 51.301 | 12.424 / 16.453 / 25.002 | 12.495 / 16.184 / 20.161 |
| Flutter totalSpan | 47.104 / 74.719 / 83.126 | 35.549 / 59.866 / 62.810 | 35.804 / 56.154 / 64.444 |
| Build OR raster > budget | 160/286 | 14/286 | 11/286 |

**First profile run is retained, including its regressions:** build p95
3.314 / 15.812 / 4.508; raster p95 42.465 / 145.089 / 56.465; totalSpan p95
70.964 / 282.736 / 101.153 for baseline/A1/A2. Jank was 138/288, 168/287,
116/287. Its A1 active-geometry p95 worsened 1.997 → 2.921 ms. The second run
corrected unavailable VM instrumentation, not the engine; both results are
published. Fixed phase order, software rendering, host contention, warm-up and
instrumentation can confound comparisons. The frame nonregression target is
**not reproducibly satisfied**. Keep A1/A2 out of production pending device runs.

Dart heap snapshots after replay: 9,309,984 / 9,529,408 / 11,163,344 bytes;
process PSS: 113,575 / 129,754 / 132,791 KB. These sequential snapshots include
the harness and GC state, not isolated retained-ink bytes or an allocation win.
Host VM calls succeeded, but selected-class allocation counters were unavailable
in this profile capture. `flutter_allocations_raw.json` preserves original
responses; `flutter_allocations.json` clarifies heap-only status without changing
measured values. Native/GPU allocations are outside Dart heap counters.

## Existing dry cache capacity audit

25 viewport paint recordings, discard first 5; all strokes visible, 128 points
each. This measures the **existing** cache, not a new production optimization.

| Visible strokes | Uncached p50 / p95 / p99 (ms) | Cached p50 / p95 / p99 (ms) |
|---|---|---|
| 32 | 1.981 / 3.058 / 3.145 | .224 / .358 / .394 |
| 128 | 7.236 / 11.999 / 26.620 | .411 / .668 / .712 |
| 256 | 13.933 / 15.337 / 16.152 | 18.304 / 31.751 / 35.056 |

Above the 128-entry capacity, sequential access thrashes and the cached variant
is slower. No arbitrary capacity increase was made. Profile spatial/bounds cost
and native memory on a real dense page before another cache change.

## B: stable native spike

`examples/ink_engine_native_spike/` is a separate package/process,
`com.phucnote.ink_spike`. AndroidX Ink 1.0.0 builds and launches with existing
SDKs. V1 marker/pressure brushes, real InProgressStrokesView, history, prediction,
native dry handoff, direct authoring cancellation and idle pause/resume are
exercised with synthetic MotionEvents. **Smoke PASS**, 128 real-input samples retained, 94 historical
samples supplied, 120 provisional predicted samples offered; completed count 1,
cancelled gesture not committed, resumes 2 / pauses 1.

Cancellation calls `cancelStroke` directly with the initiating DOWN event; it
does not dispatch through the ACTION_CANCEL handler. ACTION_UP currently finishes
without checking FLAG_CANCELED. Multitouch ownership, canceled-up handling and
backgrounding during an active stroke remain unvalidated. The runner backgrounds
the activity only after smoke completion, so its lifecycle result is idle-only.

**Exact native-input fidelity FAIL:** max coordinate discrepancy **0.00048828125
px** versus the already-float MotionEvent inputs. Pressure, tilt and timestamp
maximum errors are zero. The root cause inside the native stack was not
established. Original benchmark JSON remains canonical and unchanged; native
inputs are exported separately. This is a measured compatibility limit, not
permission to replace `.bfly` coordinates.

Native debug-only CPU microbenchmark, full-prefix / incremental shape p95:
128: 2.3236 / .2764 ms; 512: 6.5116 / .3255; 2048: 12.3764 / .2112;
4096: 25.9691 / .2682. The native full-prefix comparator uses its own pressure
brush and no explicit warm-up/order reversal; it is **not Flutter baseline**.
JNI/brush/build-mode differences prevent cross-engine ranking. Raw window frame
metrics, ART allocation counters and native heap are retained. ART cumulative
bytes allocated are 4,014,864 / 6,177,552 / 14,828,400 / 32,080,752 after those
lengths; these include mixed microbenchmark/harness work. Native heap snapshots
are GC-dependent, not peak memory. Final PSS 42,075 KB is a fresh cached-geometry
smoke process, **not** a comparable full-benchmark memory win.

The later smoke reused the measured geometry results to diagnose precision and
test idle lifecycle without rerunning CPU work. The final smoke also verifies
preview rendering with matching 2.5× Canvas and renderer transform metadata;
its actual screenshot was inspected. Exact-fidelity failures and logs are
retained. No native `.bfly` transfer, PlatformView/channel overhead, API 23–32
lifecycle certification, physical stylus/palm or camera latency run was done.
See stable [setup](https://developer.android.com/develop/ui/views/touch-and-input/stylus-input/ink-api-setup),
[authoring source](https://dl.google.com/dl/android/maven2/androidx/ink/ink-authoring-android/1.0.0/ink-authoring-android-1.0.0-sources.jar)
and the audit's integration analysis.

## Pen quality review

`PEN_RENDERING_VISUAL_COMPARISON.png` was rendered with the actual engine and
inspected. Historical and A1 columns retain identical shapes. Ballpoint is a
conservative uniform-width small-writing reference; gel is fuller; fountain
varies circular width. All three are parameter presets of one algorithm, with
measurably different geometry, not three invented engines or a physical nib.

The real-pressure / completed-tip / gamma / taper trial changes historical
appearance. Short fountain accents and formula marks become conspicuously
triangular/heavy; **reject this combined trial**. A separate real-pressure plus
completed-tip trial changes 12 / 442 / 632 alpha pixels for Ballpoint/Gel/Fountain on a 600×180
synthetic curve. This is a difference count, not a quality score. Sparse-corner
smoothing can legitimately change no pixels; the corrected dense-input probe
exercises its spacing threshold. Highlighter crossing darkens at separate-stroke
overlap, with no observed accidental blotch in this sample. No calligraphy trial.

## Commands, safety and final verification

Use the existing Flutter executable under
`C:/Users/lyle3/.codex/visualizations/2026/10/10/01a12533-6d39-7542-8205-9c33fb77fb75/p0-toolchain/flutter/bin/`.
Android SDK/JDK/Gradle cache are under repository `scratch/toolchain/`.

```powershell
flutter test --no-pub test/ink_engine_benchmark_test.dart --dart-define=INK_MEASURE=true --reporter expanded
flutter drive --no-pub --profile -d emulator-5554 --driver=test_driver/ink_engine_driver.dart --target=integration_test/ink_engine_testbed_test.dart
./tool/ink_benchmark/run_native_spike.ps1
flutter drive --no-pub --debug -d emulator-5554 --driver=test_driver/ink_engine_regression_driver.dart --target=integration_test/y700_regression_test.dart
flutter test --no-pub test/ --reporter expanded
flutter analyze --no-pub
```

Focused tests: **6 PASS**. Final full suite: **129 PASS**. Final analyze:
**PASS, no issues**. Existing Android wrapper: **34 test cases PASS** (the final
`+35` includes tearDownAll), covering storage/autosave/history/A4, portrait and
landscape toolbar/Pen Studio/Zen, Vietnamese UI and native diagnostics.
Isolated Flutter profile replay: **1 test case PASS** in each of two runs.
Native build and functional smoke: **PASS**; native exact-input fidelity:
**FAIL**, recorded separately. No physical gate is marked passed.
Production debug ARM64 APK build: **PASS**, output
`build/app/outputs/flutter-apk/app-debug.apk` (not installed on the x86_64
emulator). Correct-package crash/ANR inspection: empty crash buffer and no
matching PHUCNOTE/native-spike crash/ANR markers after the final suite.
Instrumentation/import/API probe mistakes were corrected in isolated harnesses;
no production repair or visual-parameter tuning was performed. Prior checkpoint
artifacts are preserved; new regression evidence uses its own folder.

Physical Y700/AP501U, 120 Hz, same-device competitors, camera latency, production
A1/A2 integration and compatible native brush persistence remain **NOT EXECUTED
or blocked**. The roadmap explains the next bounded evidence gates.
