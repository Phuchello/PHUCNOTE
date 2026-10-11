# Academic Premium / Vietnamese UI validation

Validated on 11 October 2026, on `develop` from clean
`ccf5d70b2e7e56d21fadc9ee4683e3bc9fd5558a`. The requested older baseline
`b1c9752…` is retained in history; completed CP-10 functionality is preserved.

## Delivered scope

Academic blue/navy and ivory light surfaces, charcoal/slate dark chrome,
consistent typography, grouped responsive toolbar, selected-tool states,
48dp primary controls, named color swatches and thickness samples. Header,
menus, dialogs and the existing functional Pen Studio share reusable styling.
The entire app UI defaults to `vi-VN`, using 105 ARB messages and generated
Flutter localizations, Vietnamese dates/decimals, tooltips and semantics.
User titles, filenames and personal preset names are preserved.

Confirmed visual corrections: a black swatch remains distinguishable on dark
chrome; the paper-menu heading has readable contrast; dark-theme Zen uses dark
system-bar icons on ivory paper. New documents do not inherit a previous save
indicator. List/load/delete/save failures give Vietnamese feedback without raw
exceptions. Failed saves retain dirty state; failed operations retain files.

NoteStorage, BflySerializer, document schemas, stroke coordinates/geometry,
drawing actions, controller, palm rejection and autosave algorithms are unchanged.

## Executed quality gates

| Command / check | Final result |
| --- | --- |
| `flutter analyze --no-pub` | PASS, no issues |
| `flutter test test/ --no-pub --reporter expanded` | PASS, 114 tests |
| Focused localization/tablet regressions | PASS, 18 tests, included above |
| `flutter drive --no-pub -d emulator-5554 --driver test_driver/ui_premium_driver.dart --target integration_test/ui_premium_regression_test.dart` | PASS, 31 scenarios; framework teardown adds the final counter entry |
| `flutter build apk --debug --no-pub` | PASS; normal APK installed and launched |

The combined Android run covers all 17 existing app cases, A4, tablet/Zen,
Pen Studio, landscape/portrait visual suites, and four new theme/orientation
scenarios. Assertions retain exact stroke JSON, history, viewport, save/reopen,
failed-save dirty state and A4 fit checks. The localization guard also rejects
injected English UI/error literals. Widget coverage includes 1.3 text scaling
and measured control/heading contrast. No Flutter layout overflow was observed.

Initial integration-harness issues were corrected and the complete suite rerun:
binding initialization precedes grouped suites, screenshot conversion occurs
once per scenario, and portrait checks use the actual viewport. Existing
behavioral assertions were retained; settings I/O has a bounded five-second wait.

## Screenshot and runtime evidence

Reused Android 15 `medium_tablet`, `emulator-5554`; no SDK installation.
`artifacts/ui-premium-validation/` contains 62 real PNGs: 36 new acceptance
captures, 16 existing-regression captures, and 10 native APK captures. Images
were visually inspected for Vietnamese diacritics, menu/dialog readability,
paper/ink separation, toolbar access and Zen. Scrolling content may extend
beyond the visible panel; it remains reachable rather than overflowing.

Native screenshots cover both themes in 2560×1600 landscape and 1600×2560
portrait, editor and Zen, plus resumed handwriting/undo/redo. Two strokes remain
after undo and three after redo. A4 numbering and Fit to Width remain aligned.
`screenshots-manifest.json` records dimensions and SHA-256 hashes. Artifacts and
logs remain local under the repository's existing ignore rules; the committed
driver regenerates integration screenshot evidence.

Correct-package log inspection used integration PID 14772 and normal-app PID
15047 for `com.phucnote.phucnote`: no Flutter errors, overflow or fatal crash;
the crash buffer has no package match and Android reports no ANR since boot.
Final command/log evidence is in `scratch/ui-premium-validation/`. The normal
APK is `build/app/outputs/flutter-apk/app-debug.apk`.

## Limits / blockers

No remaining implementation blocker. Physical 8.8-inch screen readability,
stylus latency and pressure hardware are not validated by an emulator. Paper
stays ivory in dark mode to preserve legacy ink visibility. The localization
guard is scoped source analysis, not a general Dart parser. No new pen algorithm,
document migration or unrelated feature was added.
