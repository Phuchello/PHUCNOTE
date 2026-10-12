# PHUCNOTE P0 autonomous software plan

Authorization: Prompt/PHUCNOTE_P0_AUTONOMOUS.txt (read completely). Lead/auditor: Codex; implementer: Antigravity CLI; orchestration: Hermes. User rating remains 2/10. No physical quality certification.

Base: develop at 640be788f008809421b1788e957207dbc86950d5. Integration branch: p0/autonomous-20261012. Original untracked Prompt/ is user work: never stage, edit or remove it. Serial workers only. No merges, migration, signing changes, release distribution or destructive actions. Local reviewed commits authorized; remote push optional after privacy scan.

Existing toolchain: Flutter 3.47.7 / Dart 3.13.5 at C:/Users/lyle3/.codex/visualizations/2026/10/10/01a12533-6d39-7542-8205-9c33fb77fb75/p0-toolchain/flutter/bin/flutter.bat; Java scratch/toolchain/jdk-17.0.20.1+1; Android SDK scratch/toolchain/android-sdk; Gradle scratch/toolchain/gradle. Use existing caches; no SDK installation. Initial adb devices -l: no connected devices. Existing release build signs with debug configuration; do not create/change keys.

Models discovered from agy 1.3.3: gemini-3.1-pro-high for complex input/persistence/geometry work; gemini-3.8-flash-high for bounded tests/reporting. Exact IDs were returned by agy models. Never enable permission bypass automatically.

## Checkpoints and measurable gates

1. P0.3 stylus-first default and app-local preference: default true; explicit false round-trips; load before user interaction; no .bfly preference changes. Real CanvasView events demonstrate single touch pans with zero strokes, stylus commits a stroke, pinch transforms with zero strokes. Adversarial ownership/cancel/ordering coverage; restart/document switch/orientation preserve choice. TDD, focused tests, full regression suite, independent diff audit.
2. P0.4 pen quality: retain historical geometry/schema exactly. Improve only new preset parameters unless a safe nonpersisted rendering defect can be corrected without changing historical output. Identical seeded Vietnamese diacritic/dot/corner/loop/pressure traces rendered before/after to actual PNGs; inspect pixels and images. Ballpoint/Gel/Fountain distinct, opaque where required, controlled fountain variation. No hardware pressure assumptions, migrations or schema additions. If compatibility requires schema modification, stop that work for approval.
3. P0.5 workflow: bounded regressions for palm-before-stylus, gesture transitions, stale contacts, pen/eraser changes during stroke, lifecycle/document switching/autosave, A4/Zen/orientation. Small reproduced fixes only; preserve style-at-down and undo history.
4. P0.6 performance: review existing rejected A1/A2/cache evidence. Do not merge rejected candidates. Repeat matched 32/128/256/512-stroke and 128/512/2048/4096-point measurements with raw distributions/fidelity. Profile/jank/memory require actual runnable Android target; absent target is NOT EXECUTED. Bounded alternative only with independently reproducible gains and no frame/memory regression; otherwise reject and disclose remaining thrash.
5. P0.7 analyze and complete unit/widget suite, old/new .bfly round-trips and adversarial workflows, Android integration if target available. Build local ARM64 APK using existing identity; verify manifest, ABI, signer, file size/SHA256. No uninstall/data clear. Physical Y700/AP501U pressure/tilt/timing/palm/beauty/latency/stability/competitor/user evaluation remain separate.

## Approved first worker task: P0.3 RED tests

Task P03-RED: Add minimal failing tests before production changes. Allowed NEW files: test/p03_stylus_first_test.dart and test/p03_input_preferences_test.dart; app-only test helpers under test/support only if strictly necessary. Existing source is read-only in this task. Reuse test/support/localized_app.dart and existing interaction helpers after reading them. Do not alter existing tests or production files yet.

Required assertions: CanvasController default stylusOnlyMode true; actual CanvasView touch down/move/up pans and commits ZERO strokes; actual stylus down/move/up commits one stroke; two touch pointers zoom/pan with zero strokes; planned app-local input preference store absent file defaults true, explicit false survives separate store instance and no .bfly write. Prefer implement the existing-behavior test slices first; if store API is absent, describe its intended contract rather than making the entire test suite uncompilable. Report exact written files and commands/results. Use strict vertical RED/GREEN cycles during later implementation. No commit/push, no arbitrary shell, no dependency/signing changes, no permission changes.

Codex runs RED independently if headless command permission prevents worker tests. Worker must report this honestly, not bypass permissions. Maximum two repair cycles per root cause; then bounded escalation/stop.
