# P0.2 regression and publication

Verified starting state: develop, clean, origin
`https://github.com/Phuchello/PHUCNOTE.git`, HEAD
`a02a78ec6bc4cf703c20a6da93341108fbb2f0ba`.

The production patch changes only `lib/drawing/canvas_controller.dart`:
pointer ID/kind ownership, timestamp ordering, explicit ownership release and
safe actual UP coordinate capture. No production cache, geometry, painter,
notification contract, UI, Android input path, storage, model or package changed.
The cache and A1/A2 candidates remain isolated because their full performance
gates failed. This checkpoint does not resolve production dense-cache thrashing.

## Executed matrix

PASS below means the specified software assertion passed. Candidate adoption
and physical acceptance are separate gates.

| ID | Result | Evidence / limits |
|---|---|---|
| INPUT-01 | PASS | Initiating ID/kind owns gesture; second/duplicate down and old timestamps rejected |
| INPUT-02 | PASS | Distinct actual UP location transformed into document coordinates; last axes retained |
| INPUT-03 | PASS | Identical terminal coordinate does not add a point |
| INPUT-04 | PASS | Unrelated touch cannot append or finish |
| INPUT-05 | PASS | Unrelated touch cancel preserves active stylus |
| INPUT-06 | PASS | Owned cancel discards provisional ink, preserves undoable erasure |
| INPUT-07 | PASS | Owned inverted-stylus erasing, cancellation, undo/redo |
| INPUT-08 | PASS | Finger owns accepted ink; two-finger navigation cancels it explicitly and resumes stylus input |
| CACHE-01 | PASS | 32 visible strokes; budgets/pixels, three desktop repetitions |
| CACHE-02 | PASS | 128 visible strokes; budgets/pixels, three desktop repetitions |
| CACHE-03 | PASS | 256 visible strokes; candidate working-set regression and exact pixels |
| CACHE-04 | PASS | 512 visible desktop strokes; profile page partly culled, disclosed |
| CACHE-05 | PASS | Mutation and mixed clear/undo/redo preserve ordering and invalidate stale paths |
| CACHE-06 | PASS | Identity/document clear prevents cross-document reuse |
| CACHE-07 | PASS | 128 entries / 20,000 points unchanged; long-stroke bypass; native Path bytes not precisely bounded by this logical budget |
| CACHE-08 | PASS | Exact RGBA comparison, four modes, all catalog patterns, Vietnamese paragraph and reopen |
| Cache adoption | FAIL | Small-page tails, frame p95/p99/jank and memory variability; stable production retained |
| WET-01 | PASS | 128-point ramp, canonical retention and full-width pixels |
| WET-02 | PASS | 512-point ramp and late pressure transition |
| WET-03 | PASS | 2048-point ramp and matched CPU distributions |
| WET-04 | PASS | 4096-point ramp/plateau and matched CPU distributions |
| WET-05 | PASS | Short Vietnamese accent marks, dots and all existing catalog patterns |
| WET-06 | PASS | Late pressure change matches unchanged fallback |
| WET-07 | PASS | Existing wet-prefix/completion/transforms/reopen pixel test; same terminal coordinate; distinct new UP intentionally extends input |
| A1 CPU/pixel gate | PASS | Long-prefix p95 improvement at least 22.6% desktop and 34.6% profile ramp; exact compatibility pixels |
| A1/A2 adoption | FAIL | Reversed/rotated frame and heap regressions; no production integration |
| SYSTEM-01 | PASS | Existing and new exact `.bfly` round trips; legacy format unchanged |
| SYSTEM-02 | PASS | Existing revision/autosave/concurrent-save/lifecycle tests; notifications unchanged |
| SYSTEM-03 | PASS | Existing A4 page boundaries, crossing, navigation and persistence tests |
| SYSTEM-04 | PASS | Captured stroke styles, presets, personal settings and Pen Studio regressions |
| SYSTEM-05 | PASS | Zen control restoration, strokes/history/viewport/save state |
| SYSTEM-06 | PASS | Portrait/landscape editor, Pen Studio, A4 and Zen screenshot regressions |
| SYSTEM-07 | PASS | No fatal/ANR match in retained final logcat/crash buffers for com.phucnote.phucnote; scoped to this emulator run |
| SYSTEM-08 | PASS | 147 unit/widget tests plus final 47/47 combined Android cases |
| Physical Y700 Gen 4 / AP501U | NOT EXECUTED | No physical target available; emulator is Pixel Tablet, Android 15, approximately 60 Hz |

## Commands and actual results

Existing Flutter 3.47.7 / Dart 3.13.5, perfect_freehand 2.5.2+1, JDK 17,
existing Android SDK/Gradle cache and `medium_tablet` emulator-5554 were reused.
Flutter executable and environment paths are recorded in `environment.txt`.
`--no-pub` avoids unrelated dependency/setup work.

| Gate | Result | Raw evidence under artifacts/p02-ink-hardening/ |
|---|---|---|
| `flutter analyze --no-pub` | PASS, no issues | analyze.log; initial two lint findings retained in analyze-initial.log |
| `flutter test --no-pub test/ --reporter expanded` | PASS, 147 tests; 2 measurement-only cases skipped | unit-tests.log |
| Explicit `--dart-define=P02_MEASURE=true` cache and wet tests | PASS | cache-desktop.log, wet-desktop.log; both skipped cases actually executed here |
| Cache profile replay, 3 matched repetitions | PASS functional; FAIL adoption | cache-profile.log, cache-profile/ |
| Wet profile replay, 3 independent matched launches | PASS functional; FAIL adoption | wet-profile-r0/r1/r2.log and directories |
| First combined Android regression | FAIL: 46/47 cases passed; native capture observed zero events | android-regression.log, regression/android_diagnostics.pftrace |
| Focused native diagnostic recheck after fresh log buffer | PASS, one case; 83 ADB touch events | diagnostics-recheck.log and directory; correct-package live focus recorded |
| Final combined Android regression | PASS, 47/47 cases (framework +48 includes teardown); 86 ADB touch events | android-regression-final.log, regression-final/ |
| Normal-main debug ARM64 APK | PASS, production lib/main.dart; 124,191,960 bytes | build-arm64.log, apk-details.txt with SHA256/native entries |

The initial Android failure was an external ADB/native-capture observation,
not a failed pointer regression. Its cause is not conclusively established.
The focused recheck and final complete 47-case suite passed with a fresh log buffer; the original failure and
no-root Perfetto trace are preserved rather than relabeled PASS. No assertion
was relaxed and no native production observer was modified.
The APK contains only the ARM64 Flutter runtime; the existing dartjni plugin
also bundles other ABI library entries. An initially stricter all-library-ABI
check rejected those entries; the requested Flutter ARM64 target was verified
directly. No Android packaging change was made. The APK is a local build
artifact, excluded from Git; its SHA256 is retained in `apk-details.txt`.

Reproduce Android regression with:

```powershell
$env:INK_OUTPUT_DIRECTORY='artifacts/p02-ink-hardening/regression-final'
adb -s emulator-5554 logcat -c
flutter drive --no-pub --debug -d emulator-5554 --driver=test_driver/ink_engine_regression_driver.dart --target=integration_test/p02_regression_test.dart
```

Cache profile uses `INK_PHASE_COUNT=24`, `INK_OUTPUT_DIRECTORY` set to its
evidence directory and target `integration_test/p02_cache_profile_test.dart`
with `test_driver/ink_engine_driver.dart`, `--profile`. Wet profile uses the same
driver, target `integration_test/ink_engine_testbed_test.dart`, `--profile`,
`--dart-define=P02_MODE=true` and `--dart-define=P02_REPEAT=0`, `1`, `2`, each in
a separate launch/output directory. Warm-up/order/workload limitations and all
p50/p95/p99, raw frame values, CPU samples, cache counters and memory captures
are retained in the two performance reports and JSON evidence.

## Visual inspection and compatibility

Actually inspected: both four-mode catalog atlases and Vietnamese paragraph
PNGs; selected baseline/candidate cache screenshots at 32/256/512; all three
final-run wet replay screenshots; portrait/landscape Pen Studio, Zen and A4
screenshots from the first combined regression. Geometry remained visually
consistent and exact-pixel checks passed. The testbed titles differ by phase;
they are not a whole-screen golden equality claim. Existing fountain blobs,
simulated pressure on plateaus and highlighter overlap darkening are retained.
No pen beautification or physical latency improvement is claimed.
The final combined run's native diagnostic report and resumed portrait/landscape
handwriting screenshots were also inspected; save status and restored controls
were visible. Screenshot files are real emulator captures, not mockups.

Historical stroke coordinates/styles, original note files and `.bfly` schema
were not modified. Only newly captured distinct UP positions intentionally
extend a stroke; same-position releases preserve its points. Test fixtures now
release at their actual last coordinate, avoiding artificial origin tails.

Remaining blockers: stable production cache still thrashes above its working
set capacity; emulator frame/memory results do not support cache/A1/A2 adoption;
physical palm rejection, pressure, missing events, pen-to-display latency and
120/165-Hz acceptance are NOT EXECUTED. Missing release ownership needs explicit
cancel/navigation/document reset. No PDF/AI/OCR/new pen or UI work started.
