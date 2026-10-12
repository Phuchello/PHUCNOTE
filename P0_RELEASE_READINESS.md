# P0 release readiness

State: SOFTWARE IN PROGRESS; PHYSICAL ACCEPTANCE NOT EXECUTED. Nothing published or distributed.

Existing Android application ID: com.phucnote.phucnote. pubspec version: 0.1.0+1 (must verify actual resulting APK). Existing release Gradle configuration uses debug signing. Do not create/replace identity or inspect secrets. Local APK must be checked against existing signer; update requires matching signature and suitable version code.

APK build/path/size/SHA256/ABI/manifest/signature: PENDING. Analyze/full unit-widget suite/Android integration: PENDING. Android integration unavailable initially: adb devices -l lists no targets. No uninstall or data clear permitted.

Physical checklist: back up notes without deleting originals; confirm actual Y700 Gen4 model/OS and AP501U pairing; compare installed package signer/version before an in-place install; test fresh default and persisted finger opt-in, single-finger pan/pinch, palm/cancel, all pens/diacritics, eraser/undo/redo, save/reopen/document switch, A4/Zen/rotation, dense pages and 10-15 minutes of writing; collect native diagnostics/refresh timings and external high-speed video; request user quality rating. All currently NOT EXECUTED.
