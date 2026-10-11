# Y700 Gen 4 / AP501U diagnostics

Checkpoint status: **PROVISIONAL — physical hardware NOT EXECUTED**.
Starting clean develop commit: `e83969c4e8a528aa54d19e46288af6a8b4c08ccf`.
Only `medium_tablet` / Pixel_Tablet / Android 15 was connected. See
`artifacts/y700-gen4-ink/connected-devices.txt` and `emulator-display.txt`.
No AP501U pressure levels, tilt capability, sampling rate or latency are asserted.

## Using the Vietnamese diagnostic mode

Open drawing options → **Chẩn đoán bút Y700** → **Bắt đầu đo**. The dialog closes;
write in the existing editor. Reopen the item, select **Dừng đo**, then **Xuất JSON**.
The export path is displayed and copied to the clipboard. JSON stays in app-local
support storage under `stylus_diagnostics/`; it is never part of `.bfly`.
Backgrounding the app stops capture. Controls, Zen, and the document controller
are retained. Capture is opt-in and adds instrumentation overhead.

Native observation happens before forwarding the unchanged MotionEvent to Flutter:

- Build model/device/manufacturer, Android version/SDK/build identifier.
- Two explicitly named ZUI property probes; absent values mean UNKNOWN.
- Current `Display.refreshRate`, and rate changes during capture.
- Input device/source/tool type/pointer ID/action/index/buttons/flags.
- Event and receipt uptime in milliseconds, raw pixel positions, pressure,
  tilt/orientation, contact size, historical samples and cancellations.
- Device/source-specific MotionRange min/max/flat/fuzz/resolution, or null.
- Choreographer vsync timestamps and Android window FrameMetrics.
- Flutter build/raster/total timings, percentile summaries and per-pointer deltas.

Raw OS tool types distinguish finger/stylus/eraser without identifying a stylus
model. A reported zero tilt with no motion range does not establish tilt support.
Finger/contact data supports inspection; software cannot certify palm rejection.
MotionEvent history and axes follow the
[Android API](https://developer.android.com/reference/android/view/MotionEvent).
Ranges are device reports, not an AP501U calibration claim
([MotionRange](https://developer.android.com/reference/android/view/InputDevice.MotionRange)).

## Limits and interpretation

Each raw native sample/vsync/window-frame buffer and Flutter-frame buffer retains
at most 10,000 entries. Dropped counters are exported. Refresh changes are capped
at 1,000 entries. Split long physical sessions into capture chunks; an overflowing
buffer cannot establish complete-event fidelity. Export may briefly pause UI.
Millisecond event timestamps have limited resolution; simultaneous samples are
counted separately and not converted into a fictional hardware sampling rate.

For a single observed refresh rate, budget = `1000 / Hz` ms. Jank here means build
OR raster exceeds that budget. Mixed refresh rates produce no single-budget jank
count. Flutter totalSpan includes pipeline waiting, not physical pen latency
([FrameTiming](https://api.flutter.dev/flutter/dart-ui/FrameTiming-class.html)).
Choreographer scheduling gaps and native window timings are separate observations;
neither proves physical scanout or pen-to-display latency. No gaming touch-rate
number is used. No assumption of 165 application FPS is made.

## Reproduction and physical handoff

Reuse the existing Flutter/Android SDK. Commands from the repository root:

```powershell
flutter drive --profile -d emulator-5554 --driver=test_driver/y700_ink_driver.dart --target=integration_test/y700_ink_profile_test.dart --dart-define=INK_PHASE=optimized
$env:PHUCNOTE_NATIVE_CAPTURE='1'
flutter drive -d emulator-5554 --driver=test_driver/y700_ink_driver.dart --target=integration_test/y700_regression_test.dart
```

The driver injects ADB **touchscreen**, not stylus, only for the diagnostic smoke
test after its logcat readiness signal. `PHUCNOTE_TEST_DEVICE` selects the matching ADB serial when explicitly running
that test elsewhere. Diagnostic JSON and screenshots identify this provenance.
Native cancellation/history collection is implemented; physical batched stylus
history and palm cancellations remain NOT EXECUTED.

On the physical target, confirm its actual model/build and AP501U pairing, run a
profile build, export diagnostic chunks, and pull the reported file with ADB
`run-as com.phucnote.phucnote` on a debuggable build. Retain original JSON.
Collect no-root Perfetto (`sched gfx view input`) and external high-speed video
alongside the five-minute writing tests. An emulator Perfetto recording is supplied
solely as evidence that this capture path was exercised.

Executed emulator smoke capture: 175 native touch samples, 19 Flutter frame
timings, 902 vsync callbacks, no buffer drops. ZUI probes returned null; historical
samples/cancellations were zero. JSON and the diagnostic report screenshot are
in `artifacts/y700-gen4-ink/`. This does not execute any physical acceptance gate.
