# P0 release readiness

State: BOUNDED P0 SOFTWARE GATES COMPLETE, INDEPENDENT AUDIT PASS (deleg_bbcbf973). PHYSICAL ACCEPTANCE NOT EXECUTED. Local build only; nothing published or distributed. Checkpoint remote SHA is recorded post-commit in local artifacts/p0/push_p07.json and .git/p0-push-records/p07.json; never embed a commit's own hash into itself.

Branch: p0/autonomous-20261012. P06 source checkpoint: 3a790b966571b37641a479254ac7ad15251b6799 (normally pushed and verified). P07 adds only test fixtures/aggregation and reports; production unchanged from P06. Every subsequent agy -p explicitly uses --model gemini-3.8-flash-high, including APK recovery; unavailable means BLOCKED, no fallback.

## Executed software gates

- Complete unit/widget suite: p07-final-full exit0,167 passed,0 failed,3 opt-in benchmarks skipped. P06 CPU matrix executed separately with P06_MEASURE=true.
- flutter analyze --no-pub: p07-final-analyze2 exit0, no issues. Full suite rerun after import-only cleanup and APK build.
- Android debug integration drive: p07-integration-final exit0,59 named cases; runner reports60 including teardown. Explicit synthetic touch/stylus, owning-pointer/cancel/up adversaries, one-finger pan/no ink, pinch, settings races/restore errors, save/autosave/undo/redo, A4/Zen/portrait/landscape and native diagnostics. Android PASS precedes redundant-import deletion only; final analyzer/full gate cover final source.
- Historical .bfly read/save/reopen and60 mixed-pen stroke workflow covered by complete suite. Original presets restored; schema/serialization/geometry unchanged. Short Vietnamese marks and actual renderer PNG retained, synthetic only.
-54 Android screenshots captured; four representative page2/portrait/Zen/diagnostic images inspected with visible ink. Not54 manual visual approvals. Portrait retains an options tooltip; no physical quality inference.
- Native observer/export and no-root6-second Perfetto actually executed: Pixel Tablet emulator,103 touch events/samples, toolType1 only,2222459-byte trace. Explicit ADB-injected touchscreen provenance, not AP501U. No physical latency/pressure/palm certification.

Compact evidence: artifacts/p0/p07_validation_summary.json. Raw successful/failed logs, screenshots, native JSON, Perfetto and public APK signer/manifest outputs are LOCAL ONLY under C:/Users/lyle3/Music/Phucnote/artifacts/p0/p07_local_evidence. Do not stage raw directory or APK.

## Actual ARM64 artifact

Path: C:\Users\lyle3\Music\Phucnote\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
Size: 21285165 bytes.
SHA256: b0bcf472a35e3f6d04d28b3a3d634476e41217e09fe5e5de7f647976eaadab23
Application ID: com.phucnote.phucnote.
Manifest versionName:0.1.0; versionCode:2001 (pubspec0.1.0+1, ARM64 split ABI offset). minSdk24; targetSdk36.
ABI: arm64-v8a ONLY; all three native libraries ELF machine183/AArch64.
Signature: apksigner verify exit0; APK v2 scheme verified, one existing Android Debug signer.
Certificate SHA256: 48d4f7c0bc4715d29c207e571e3c84485c0ba50403ca4ee08d219c6a43bd6ebf, exact match to saved pre-program APK signer. No key created/read/changed. NOT production distribution signing; unknown physical installed signer still needs comparison.

Antigravity-authored command executed by Hermes with selected cached toolchain:
flutter build apk --release --pub -t lib/main.dart --target-platform android-arm64 --split-per-abi
p07-arm64-build2 exit0. Initial --no-pub release failed: debug-generated registrant retained dev-only IntegrationTestPlugin. Installed Flutter source confirmed --no-pub skips platform regeneration. Offline locked pub get and cached --pub release build regenerated release registrant without that plugin. Tracked pubspec/lock/native/signing/production unchanged; no SDK/toolchain installation or manual generated Java edits. ARM64 release runtime NOT EXECUTED on x86_64 emulator; target runtime remains a physical gate.

## Y700 Gen4/AP501U safe install and physical checklist — NOT EXECUTED

1. Export/back up notes/settings without removing originals. Confirm target model/OS/ARM64 and AP501U pairing/firmware. Only emulator-5554 currently connected, NOT Lenovo hardware.
2. Identify physical serial with adb devices -l; use explicit -s SERIAL. Compare installed com.phucnote.phucnote version/public signer against this artifact: versionCode must permit update and signer must match. Incompatible -> STOP. No uninstall, data clear, downgrade, new key or changed application ID.
3. After those checks, user in-place install: adb -s SERIAL install -r "C:\Users\lyle3\Music\Phucnote\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk". Never use -d to force downgrade. Read back installed version/signature and launch actual app. No physical installation executed here.
4. Verify truly new-user default without clearing existing data: stylus writes, one finger pans with ZERO ink, two fingers zoom/pan. Existing saved finger opt-in remains false across upgrade/restart/notebook switch/rotation; intentional touch opt-in writes. Do not reset saved users to new-user true.
5. Write Vietnamese words/all tones/đ/ă/â/ê/ô/ơ/ư, isolated dots/formulas/corners/loops/rapid lifts with Ballpoint/Gel/Fountain. Compare live/committed and reopened historical .bfly ink; capture pressure range/tilt/event timestamps, never assume hardware specs. Original numbers remain production; rejected candidate image is forensic only.
6. Exercise resting palm/second finger/cancels/eraser/inverted stylus if reported/quick pen switch/edge navigation/Undo-Redo/save feedback/autosave/reopen/document switch/A4/Zen/rotation. Check no lost strokes, unwanted ink or navigation, or notes lost.
7. Measure32/128/256/512 visible strokes and128/512/2048/4096+ point traces with actual mixed-pen writing/pan/zoom. Capture diagnostics and refresh separately from sampling. External high-speed video for pen/display evaluation; CPU/emulator results are not that latency.
8. Run10–15 minutes of real writing, save/restart/reopen and confirm stability. Ask user quality rating (prior2/10). Pressure/tilt/sample timing/palm/beauty/responsiveness/stability/commercial comparisons remain NOT EXECUTED until physical evidence and user judgment.

## Remaining limitations / stop boundary

P04 tuning REJECTED by repeated frame regressions; exact original presets restored, fresh-controller Ballpoint alignment retained. P06 produced no dense-page performance improvement:128-entry cache thrashes at256/512 and emulator densest phases fully janky. Post-phase class allocation deltas unavailable; no memory PASS. No premium/physical P0/165Hz/360Hz claim. After final independent audit and normal verified branch push, remaining gate requires absent hardware; no endless emulator tuning or unapproved release action.
