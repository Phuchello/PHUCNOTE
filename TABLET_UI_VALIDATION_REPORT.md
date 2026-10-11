# Tablet UI and Zen Mode validation

Validated 2026-10-11 (Asia/Saigon) on `develop`, starting at
`8c5b664cbd72fedf4781820c78eeeb7f8e0d6951`.

## Changes

The toolbar keeps Pen, Highlighter, Eraser and Undo/Redo directly accessible
with 48-logical-pixel targets and selected-tool styling. Tablet layouts use
one 56-pixel-high row, capped at 720 pixels wide. Very narrow layouts use two
explicit rows; secondary settings use a scrollable Material menu. Color and
width selectors remain direct on tablet widths. Active A4 and stylus-only
modes have indicators and checked menu entries.

Zen hides the AppBar and toolbar. A safe-area Exit Zen button and Android Back
restore them. The same CanvasView state, controller, document, active stroke,
history, viewport and dirty state survive toggling. Autosave and lifecycle
protection remain active. Zen is screen-local and does not enter `.bfly` files.
Production changes are limited to HomeScreen and ToolbarWidget.

## Executed gates

| Gate | Result |
| --- | --- |
| `flutter analyze` | PASS: no issues |
| `flutter test test/` | PASS: 86 tests |
| Focused UI-01 through UI-10 | PASS: all 10; strengthened history assertion rerun |
| New Android tablet/Zen integration | PASS: 2 orientation scenarios |
| Existing Android integration suite | PASS: 17 app + 2 A4 + 2 landscape + 2 portrait |
| Normal debug APK, Android x64 emulator target | PASS: built and installed |
| Correct-package crash/ANR inspection | PASS: no PHUCNOTE crash, ANR or Flutter layout/runtime exception |

The baseline toolbar regression failed at 116 pixels high before the repair.
Tests exercise stylus tool selection, history, active gestures, zoom/pan,
menu/dialog interaction, A4 Fit-to-Width, Continuous Paper, autosave and saves.

## Inspected native screenshots

Existing Android 15 `medium_tablet`, density 320, reused without SDK setup.
Files are under `artifacts/tablet-ui-validation/`:

| Capture | Resolution | Finding |
| --- | --- | --- |
| `landscape_editor.png` | 2560×1600 | Single-row controls; distinct pen/highlighter ink |
| `portrait_editor.png` | 1600×2560 | All primary controls visible; A4 fits the width |
| `landscape_zen.png` | 2560×1600 | Expanded canvas; discoverable Exit Zen |
| `portrait_zen.png` | 1600×2560 | Readable page guides and ink; visible Exit Zen |
| `portrait_resumed.png` | 1600×2560 | Controls restored; additional handwriting saved |

Both orientations also have automated editor/Zen/resume captures. Logs are in
`scratch/tablet-ui-validation/`. Artifacts and logs remain local and Git-ignored.

Limitations: emulator and synthetic stylus input do not validate physical stylus
latency, pressure fidelity or ergonomics on an actual 8.8-inch device.
Blockers: none.
