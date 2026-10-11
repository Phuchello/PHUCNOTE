# Ink optimization results

**PROVISIONALLY VALIDATED; physical acceptance NOT EXECUTED.**

One measured performance improvement: a CanvasView-owned LRU cache for committed
paths and bounds, limited to 128 entries / 20,000 stored points. Offscreen strokes
are still culled before geometry generation. Snapshots of immutable StrokePoint
objects detect edits to mutable point lists; object identity prevents stale paths
when IDs are reused. Large strokes bypass the cache. Switching documents clears
it; undo/redo retains exact stroke objects, styles, coordinates and ordering.

One correctness repair: a touch up/cancel cannot finish or cancel an active stylus
gesture. Existing genuine stylus cancellation remains unchanged. Two failing
pre-fix widget regressions now retain the entire stylus stroke and undo/redo.
This is synthetic pointer evidence, not physical palm certification.

## Same emulator, same trace, profile builds

| Metric (ms) | Before p50/p95/p99 | After p50/p95/p99 |
|---|---|---|
| Committed paint CPU | 20.134 / 32.704 / 92.055 | 0.929 / 1.570 / 2.509 |
| Active geometry CPU (unchanged implementation) | 0.168 / 0.599 / 0.787 | 0.170 / 0.553 / 1.390 |
| Flutter build | 6.843 / 33.527 / 49.344 | 5.191 / 20.986 / 23.210 |
| Flutter raster | 41.476 / 58.553 / 82.439 | 42.765 / 50.796 / 83.571 |
| Flutter totalSpan | 74.913 / 99.349 / 158.660 | 74.156 / 91.975 / 159.200 |

Committed paint p50 decreased **95.39%**; p95 decreased **95.20%**.
Build OR raster over the observed 16.6666656-ms budget: **323/324 → 322/324**.
Software rasterization remains slow. Total frame p50 is essentially unchanged;
active geometry p99 worsened in this single run. No physical responsiveness
improvement is claimed. No repeated tuning was performed to chase noise.
Raw distributions/frames/trace are `baseline.json` and `optimized.json`.
The optimization measurement preceded diagnostic-mode wiring; diagnostic overhead
is excluded from that isolated comparison.

## Architecture comparison and decision

[AndroidX releases](https://developer.android.com/jetpack/androidx/releases/ink)
confirm Ink **1.0.0 stable**, released December 17, 2025. No alpha dependency or
native Ink package was added. Its authoring path uses Jetpack graphics for low
latency ([official guide](https://developer.android.com/develop/ui/views/touch-and-input/stylus-input/about-ink-api)).

| Criterion | Flutter + perfect_freehand | Jetpack Ink 1.0.0 |
|---|---|---|
| Y700 visible responsiveness/frame stability | NOT EXECUTED | NOT EXECUTED |
| Same-device Vietnamese/pressure/palm quality | NOT EXECUTED | NOT EXECUTED |
| Same-device CPU/memory and long strokes | NOT EXECUTED | NOT EXECUTED |
| Current trace geometry | Measured; unchanged after caching | No native trace run |
| Undo/autosave/A4/.bfly integration | Existing implementation under regression tests | Requires adapter and fidelity checks |
| Integration risk (engineering inference) | Small bounded cache; existing renderer retained | Input ownership, coordinate/viewport, completion and persistence seams |

No isolated native testbed was added without the target needed for a fair
comparison. Architecture superiority remains unmeasured. Retain Flutter; adoption
of native/hybrid rendering is blocked until comparable physical input/video/frame
traces demonstrate an advantage. A CPU-only result is insufficient.

## Acceptance evidence and remaining gates

Cached/uncached pixels and `.bfly` reopen equality are asserted for all three pens;
mutable point invalidation, identity, eviction and point budgets are covered.
Executed gates (2026-10-11):

- `flutter analyze`: **PASS, no issues** (`artifacts/y700-gen4-ink/analyze.log`).
- `flutter test test/`: **123 PASS**, including legacy `.bfly`, undo/redo,
  autosave, A4, Zen, pen style capture and new cache/cancellation tests
  (`artifacts/y700-gen4-ink/unit-tests.log`).
- Android full regression wrapper: **34 test cases PASS** (31 existing + native
  diagnostic UI/export + 2 synthetic cancellation cases). The framework's final
  `+35` also counts `tearDownAll`; it is not an extra product test
  (`artifacts/y700-gen4-ink/android-regression.log`).
- Native observer: actual Android ADB touchscreen events, 175 retained samples,
  19 Flutter timings, 902 Choreographer callbacks, zero sample drops. Historical
  samples and native cancellations were both zero, not evidence of stylus support.
  `diagnostics.json`, `diagnostics_report.png` and a 1,780,356-byte no-root
  `android_diagnostics.pftrace` are retained. Start/stop/export used the real
  Vietnamese panel; document revision and dirty state remained unchanged.
- Inspected real emulator images: dense ink, diagnostic panel, Pen Studio in both
  orientations and portrait Zen. No visible overflow in these images; existing
  orientation/Zen/A4 assertions passed. Other full-suite screenshots are retained
  locally; representative images are committed with this report.
- Debug ARM64 APK build: **PASS** (`artifacts/y700-gen4-ink/build-arm64.log`), output
  `build/app/outputs/flutter-apk/app-debug.apk`. No physical install is claimed.
- Correct-package crash/ANR inspection after the final suite: no crash-buffer
  entries and no matching `com.phucnote.phucnote` crash/ANR markers. Snapshot files
  are retained. Debug-suite PSS/RSS was 358,933/482,344 KB during a visual test;
  this is not a before/after cache or native-engine memory comparison.

The first native harness attempt was interrupted while coordinating screenshots;
Android sends screenshot callbacks after test completion. Logcat signalling and
live ADB injection corrected the test orchestration. Only the successful final
suite above is counted as PASS. Emulator background launches also disconnected
before the first install; the existing AVD was kept in a live terminal session.
No SDK was installed or replaced.

Missing physical gates: five-minute rapid notes, five-minute small Vietnamese,
pressure/tilt calibration, long loops/diagrams, palm contact, zoomed ink,
pen-display video and functioning Notewise/Flexcil/Lenovo-app comparison.
No Samsung Notes availability assumption is made. No physical missing/spurious
stroke or long-stroke quality PASS is declared.

Compatibility blocker: explicit hardware-pressure interpretation and new taper
semantics cannot be distinguished for old/new strokes by current persisted style.
These subfeatures are stopped; no migration or silent reinterpretation is used.
NoteStorage, BflySerializer, saved coordinates and StrokeGeometry are unchanged.
The separate PDF experiment and prior research remain untouched.
