# Vietnamese localization audit

## Coverage

Default and supported app locale is `vi-VN`. `lib/l10n/app_vi.arb` contains 105 messages, generated with Flutter gen-l10n through `l10n.yaml` into `lib/l10n/generated`. Existing flutter_localizations and intl dependencies are reused; no package or font installation.

Localized surfaces: document header/save state; all toolbar tools, palettes, widths and paper modes; A4 numbering; Fit to Width/reset; create, rename, open, clear and unsaved-change dialogs; save/load/list/delete feedback; Zen exit; Pen Studio presets, controls, preview, personal-preset validation and failures. Material dialogs, text selection and accessibility delegates also use Vietnamese. Canvas/preview semantics, mode badges and icon-only navigation have Vietnamese labels. Dates use local `dd/MM/yyyy HH:mm`, save time uses 24-hour `HH:mm`, and slider/file-size decimals use Vietnamese comma formatting.

Translation choices include Bút viết, Bút đánh dấu, Tẩy nét, Hoàn tác, Làm lại, Xưởng bút and Chế độ tập trung. The fountain description explicitly describes pressure-width variation with a round tip. Technical exceptions are mapped to localized UI messages, retaining dirty state/files/settings on failure.

## Deliberately preserved content

User titles, filenames and named personal presets remain exact, including English content. Built-in preset names, enum values, JSON keys, menu values and test keys remain internal identifiers; the UI maps them to localized labels. PHUCNOTE, A4, RGB and kB are identifiers/units. Existing documents with an English default title remain readable; newly created unnamed notes get Ghi chú mới. NoteStorage, BflySerializer, document models, stroke geometry and input/history/autosave algorithms are unchanged.

## Automated guard and evidence

`test/vietnamese_localization_test.dart` scans all UI sources, main, locale formatting and page-label rendering. Unknown alphabetic string literals fail; an explicit technical identifier allowlist is documented in the test. Direct text/tooltip/label literals are checked independently so an internal token cannot accidentally become English UI. The guard verifies injected English text/tooltip/error failures. Dynamic user content is intentionally outside translation.

Executed coverage and screenshot findings are recorded in UI_PREMIUM_VALIDATION_REPORT.md. The guard is a scoped source check, not a general Dart parser; review is still required when adding new UI surfaces. Current language scope is Vietnamese only. Physical screen/stylus performance is not inferred from emulator evidence.
