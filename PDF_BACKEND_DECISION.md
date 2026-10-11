# PDF POC backend decision

Checkpoint A, 2026-10-11. Baseline `1087b5ebf9dd51128fe5da98a9375229938a8550`;
installed Flutter 3.47.7, Dart 3.13.5, Java 17, existing Android 15 tablet AVD.

| Candidate | Compatibility / lifecycle | Zoom / memory | Licensing / size |
| --- | --- | --- | --- |
| Android PdfRenderer through an example-only MethodChannel | API 21+; serialize open/render/close on one worker; close each page, descriptor and renderer | Application controls bitmap dimensions, demand rendering, viewport and bounded decoded cache | Android platform implementation; no bundled PDF engine; measure example bridge separately |
| pdfrx 2.6.5 / PDFium | Published source requires Dart ^3.13 and Flutter >=3.47, compatible with installed SDK constraints; not build-tested here | Rich viewer and PDFium engine/cache; would require a separate dependency/binary validation | MIT wrapper, PDFium notices and native binaries; size not measured because not installed |
| pdfx 2.11.0 | Dart >=3.3; Android uses native PdfRenderer, rather than being a second PDFium candidate | Viewer/image rendering and platform lifecycle abstraction | MIT; not build-tested or installed |

Selected **Android PdfRenderer**, solely inside `examples/pdf_functional_poc/`,
with package ID `com.phucnote.pdf_functional_poc`. No production bridge, plugin,
asset additions or state framework. Flutter renders decoded native bitmaps plus
an independent ink layer through the same page transform. Raster zoom is real;
resolution increases are bounded, so deep zoom has a deliberate quality limit.

Use a documented source snapshot of PHUCNOTE's immutable StrokePoint,
StrokeProperty and StrokeGeometry, retaining license headers. This avoids a
transitive dependency on the production app's PNG asset bundle. Snapshot
equivalence is checked in tests; the production controller/storage are untouched.

Root Document Lab assets remain historical visual prototypes: the existing APK
contains 11 PNG entries totaling **2,600,751 bytes**, measured from its ZIP index.
The POC declares only original PDF fixture bytes. No additional prototype PNGs
enter root assets. Removing historical preview assets is deferred because its
capture suite depends on them; production asset cleanup needs a dedicated scope.

Executed outcome: the isolated Android app builds and passes real rendering,
navigation, transforms, ink and split tests. APK ZIP comparison adds **zero new
native .so libraries**; common Flutter .so bytes match the scaffold. Whole debug
APK delta is 29,640,320 bytes, including UI, localization, test plugin and PDFs;
this is not an isolated Kotlin bridge-size estimate. The bridge's DEX cost has
not been measured separately. Android-only support and untrusted-PDF process
isolation remain production decisions; this POC opens trusted fixture bytes.

Sources checked on 2026-10-11:
[Android renderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer),
[pdfrx source constraints](https://github.com/espresso3389/pdfrx/blob/master/packages/pdfrx/pubspec.yaml),
[pdfrx versions/license](https://pub.dev/packages/pdfrx/versions),
[pdfx versions](https://pub.dev/packages/pdfx/versions),
[pdfx native Android source](https://github.com/ScerIO/packages.flutter/blob/main/packages/pdfx/android/src/main/kotlin/io/scer/pdfx/PdfxPlugin.kt).
