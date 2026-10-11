# CP-10 — PHUC PEN STUDIO validation

Validated 2026-10-11 on `develop`, from baseline
`b1c9752b0256862c0f686367b4d1132e5fc2ed4c`.

Pen Studio provides Ballpoint, Gel Pen and Fountain Pen presets; continuous
width, opacity, thinning, smoothing and streamline sliders; RGB color input;
an interactive handwriting preview; preset reset; and named personal presets.
The existing toolbar retains 48dp targets. Quick width choices remain in
Drawing Options, which also exposes Studio on narrow layouts.

Fountain Pen uses perfect_freehand pressure-dependent width with a round tip.
Pairwise outline measurements distinguish all three presets. Controlled
pressure samples keep Ballpoint width uniform and increase Fountain width by
more than two document units. Dense-sample geometry and painted-pixel tests
verify parameter effects through the unchanged StrokeGeometry engine.

The baseline regression reproduced pointer-up style assignment overwriting a
stroke's initial color/width. Live and committed ink now share an immutable
pointer-down style; cancellation and document switching release that capture.

| Executed validation | Result |
| --- | --- |
| `flutter analyze --no-pub` | PASS; no issues |
| `flutter test test/ --no-pub` | PASS; 106 tests, including 20 CP-10 regressions |
| Android `app_test`, `a4_page_writing_test`, `tablet_ui_test` | PASS; 21 existing scenarios |
| Android `pen_studio_test` via screenshot driver | PASS; landscape and portrait, including native settings save/reload, exact stroke style, undo/redo, autosave and Zen |
| Android debug builds during integration runs | PASS |
| PHUCNOTE test-process runtime/crash logs and Android ANR record | No Flutter exception, overflow, package crash or ANR observed |

Reused Android 15 `medium_tablet` (`emulator-5554`). Inspected all four captures
under `artifacts/pen-studio-validation/`: `pen_studio_landscape.png`,
`pen_studio_portrait.png`, `pen_zen_landscape.png`, `pen_zen_portrait.png`.
Panel controls, preview ink and Exit Zen are readable. Portrait captures use
the integration binding's surface sizing. Existing app tests emit RawTooltip
hit-test warnings; their behavioral assertions pass.

All six style parameters already round-trip through `.bfly`; NoteStorage,
BflySerializer, document schema, coordinates and geometry engine are unchanged.
Legacy `.bfly`/`.tbfly` fixtures and disk reopen retain exact supported styles.
Personal presets use independent app-support settings with serialized writes,
flushed temporary-file replacement, validated names/parameters and visible
failure handling. Malformed settings disable personal writes and remain intact.

Execution logs: `scratch/pen-studio-validation/` (`before.log`, `tests.log`,
`analyze.log`, `android-regression.log`, `android-pen.log`, package/crash/ANR logs).

Limitations: no true nib geometry; physical stylus pressure/latency is unverified
by the emulator. No packages were added. Blockers: none.
