# Atelier PDF — isolated Android functional POC

This app has its own package ID (`com.phucnote.pdf_functional_poc`), asset bundle,
Gradle project and MethodChannel. It does not depend on the production Flutter
app, read its storage, or save `.bfly` files. All ink and three scratch-note pages
are session-only. Finger input pans/pinches; stylus or mouse input writes.

From this directory, with the existing Flutter/Android toolchain on PATH:

```powershell
python tool/prepare_fixtures.py
flutter pub get --offline
flutter analyze
flutter test test/
adb -s emulator-5554 shell cmd window set-ignore-orientation-request false
flutter drive --driver=test_driver/driver.dart --target=integration_test/all_test.dart -d emulator-5554
flutter build apk --debug
```

Record and restore the emulator's original orientation policy after testing.
The current `medium_tablet` originally returned `true`; it must temporarily allow
orientation requests for full-screen portrait instead of tablet letterboxing.
Individual integration targets (`rendering_test.dart`, `ink_test.dart`,
`evidence_test.dart`) remain runnable for progressive checkpoint validation.
The host driver writes screenshots and compact JSON traces under
`../../artifacts/pdf-functional-poc/`. `tool/contact_sheet.py` uses desktop Pillow
to losslessly optimize captures and create the root contact sheet. No screenshot
is a pre-rendered page asset or a runtime dependency.

## Controlled drawing adapter

Three files are copied verbatim from the audited production baseline:
`core/models/stroke_point.dart`, `core/models/stroke_property.dart` and
`drawing/stroke_geometry.dart`. Their AGPL-3.0 headers remain intact; see the root
LICENSE. `test/ink_test.dart` verifies byte identity, preventing accidental
divergence. Avoid formatting those three copies independently. The only drawing
dependency is the same cached `perfect_freehand` 2.5.2+1 used by PHUCNOTE.
`InkSheet` is an example-only in-memory adapter with immutable stroke snapshots,
not a replacement production drawing controller.

`tool/prepare_fixtures.py` copies the three tracked source PDFs into ignored local
assets and verifies SHA-256 equality. Production's pubspec stays unchanged.
Optional `tool/convert_pptx.ps1` opens the tracked PPTX read-only in an already
installed PowerPoint and saves a separate PDF. `tool/check_conversion.py` uses
existing desktop pymupdf/python-pptx/Pillow to compare actual converted text,
tables, dimensions and embedded fonts. None of these desktop tools is needed by
the Android app; nothing installs a converter or renders PPTX natively.

See the root PDF_BACKEND_DECISION.md, PDF_COORDINATE_MAPPING_TESTS.md and
PDF_FUNCTIONAL_POC_REPORT.md for executed results and integration limits.
