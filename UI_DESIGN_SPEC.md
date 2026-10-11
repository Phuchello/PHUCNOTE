# PHUCNOTE — Academic Premium

## Scope and audit

The requested baseline `b1c9752…` precedes the completed CP-10. This checkpoint
starts from clean `develop` at `ccf5d70…`, preserving its functional Pen Studio.
The current editor has scattered English strings, weak document/save hierarchy,
disconnected toolbar styling and an unlabeled close/delete entry in note browsing.
The canvas, stroke geometry, persistence, history and input architecture stay intact.

## Tokens

| Role | Light | Dark |
| --- | --- | --- |
| Primary / selected tool | `#254F7D` academic blue | `#AAC9EC` |
| Header identity | `#18324B` navy | `#E4EAF2` |
| Workspace / chrome | `#EDF1F5` | `#171D26` charcoal |
| Elevated toolbar / panel | `#FFFDF8` | `#202A36` slate |
| Selection container | `#DFEAF6` | `#314968` |
| Main text | `#1D2D3E` | `#E4EAF2` |
| Secondary text | `#5D6D7D` | `#B6C2D0` |
| Outline | `#CBD5DF` | `#485767` |
| Error | `#A63532` | `#FFB4AB` |
| Paper / preview | `#FAF7EF` warm ivory | same |

Paper and inter-page surroundings stay light in both themes so legacy dark ink
remains readable without recoloring strokes. Chrome and panels follow the theme.
No glass, gradients, decorative animation or copied competitor assets.

System Roboto with Unicode Vietnamese coverage; no downloaded font. Typography:
section title 20/28 semibold, document title 18/24 semibold, body 14/20, controls
14/20 medium, metadata 12/18. Line height and flexible text layouts leave room
for Vietnamese diacritics. Long user titles ellipsize without modification.

Spacing: 4, 8, 12, 16, 24dp. Radii: 10dp controls, 16dp menus, 20dp toolbar,
24dp panels. Subtle 1dp outline and 2dp toolbar elevation distinguish paper,
editor chrome and modal surfaces. Icons use Material outlined variants and the
same selected shape/color; disabled, pressed, focused and hovered states follow
Material. Active modes have translated semantic labels and checked menu items.

## Editor hierarchy and responsive behavior

The 64dp header grows with text scaling and presents document title above save state, with 48dp create/open
targets and a compact save button. Tool groups are writing (pen, highlighter,
eraser), history (undo/redo), then ink/configuration and other tools/focus mode.
Writing tools and history remain direct controls. The normal toolbar stays
56dp tall at tablet widths; the existing explicit two-row fallback is retained
below 360dp available width. Secondary menus scroll rather than wrapping the
toolbar. Tablet portrait and landscape use the same document/canvas instance.
Focus mode keeps a discoverable 48dp exit control and existing save protection.
System-bar icons follow the visible background: the header supplies its normal
style, and ivory paper uses dark icons in focus mode.

Menus show named swatches and actual thickness samples. Pen Studio shares
panel, slider, palette, preset and preview styling; only CP-10's working controls
are exposed. Preview ink continues through StrokeGeometry. Dialog bodies scroll
with keyboard/text scaling; actions wrap only inside modal panels. Snackbars use
short Vietnamese messages, theme colors and no raw technical exceptions.

Locale is explicitly `vi-VN`, with generated Flutter ARB localizations and
localized Material/selection semantics. Dates use local time, `dd/MM/yyyy HH:mm`
and 24-hour save times. Decimal values use Vietnamese comma formatting. User
titles, filenames, preset names and persisted technical keys are preserved.

## Reference interpretation

Our grouping and restrained property panels are design decisions informed by
[Goodnotes UI categories](https://support.goodnotes.com/hc/en-us/articles/13682253498767-Improved-User-Interface),
[Flexcil pen settings](https://support.flexcil.com/hc/en-us/articles/8164459936537-Pen-toolbar)
and [Notewise tool properties](https://help.notewise.dev/articles/0688324-how-to-customize-preset-colors-stroke-width-shapes-and-more).
[Goodnotes Android](https://www.goodnotes.com/android) and
[MyScript Notes](https://www.myscript.com/notes/) provide handwriting-workspace
context, without adopting their extra features. Localization follows
[Flutter's official ARB generation workflow](https://docs.flutter.dev/ui/internationalization).

Acceptance includes executed localization guards, unchanged behavioral
regressions, both orientations/themes, visible Vietnamese dialogs, touch targets
and inspected emulator screenshots. Physical stylus performance is outside an
emulator's validation capability.
