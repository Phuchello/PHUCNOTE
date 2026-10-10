# PhucNote — Changelog

All notable changes to the PhucNote project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.1.1] - 2026-10-10
### Fixed & Improved (P0 Audit Remediation)
- **Data Safety Engine:**
  - Implemented atomic file saving in `NoteStorage` via temporary file writing (`.tmp_<timestamp>`), storage buffer flush, and atomic rename, eliminating partial or corrupted writes.
  - Added crash recovery with automatic `.bak` backup copy retention and graceful fallback loading.
  - Implemented reliable 1500ms debounced autosave upon stroke completion.
  - Added `WidgetsBindingObserver` lifecycle flushing on `AppLifecycleState.paused`, `inactive`, `detached`, and `hidden`.
  - Added switch guards and unsaved modification warning dialogs when creating notes, opening notes, or exiting the application via `PopScope`.
  - Validated with actual disk file save/load/crash-recovery test suite (`test/note_storage_data_safety_test.dart`).
- **Stylus Input & Software Palm Rejection:**
  - Implemented framework-level `PointerDeviceKind.stylus` discrimination and configurable stylus-only mode.
  - Gated touch input away from inking in stylus-only mode while preserving smooth finger viewport panning.
  - Added software palm rejection heuristics: rejecting touch events while active stylus is on screen, and filtering abnormal contact area touches.
  - Added automatic eraser routing for inverted stylus tip events (`PointerDeviceKind.invertedStylus`).
  - Added dedicated test suite (`test/stylus_input_test.dart`) and explicit documentation disclaiming hardware palm rejection until physical on-device empirical validation.
- **Action-History Undo / Redo Engine:**
  - Replaced simplistic last-stroke popping with a complete Command/Action pattern (`CanvasAction`).
  - Added full support for `AddStrokeAction`, `EraseStrokesAction` (with original z-order index restoration), and `ClearCanvasAction`.
  - Verified mixed action sequences (`test/canvas_action_history_test.dart`).
- **Linwood Butterfly v2.6.0 Interoperability:**
  - Audited real Butterfly v2.6.0 document schema and verified interoperability against actual upstream fixtures (`document_v1.bfly` and `study.tbfly`).
  - Enhanced `BflySerializer` to handle `.bfly` ZIP containers (`META-INF/butterfly.json`, `BFLY/info.json`, `BFLY/pages/0.Main.json`), multi-page `.tbfly` documents, and legacy JSON files.
  - Verified full round-trip preservation of strokes, pressure, and properties (`test/butterfly_interop_test.dart`).
- **Architecture Accuracy:**
  - Documented that PHUCNOTE's drawing engine is an independent, lightweight custom Flutter implementation reproducing Butterfly's inking mathematics (`perfect_freehand` + bezier interpolation), rather than importing Butterfly's monorepo `Renderer`/`Bloc` dependencies.

## [0.1.0] - 2026-10-10
### Added
- First executable PHUCNOTE Android application baseline foundation:
  - Audited core drawing smoothing engine preserved (`perfect_freehand` with quadratic bezier interpolation).
  - High-performance dual `RepaintBoundary` rendering (`PhucNoteViewPainter` for rasterized canvas + `PhucNoteForegroundPainter` for 120-165Hz active inking).
  - Linwood Butterfly `.bfly` ZIP archive container format serializer (`BflySerializer`) with full round-trip fidelity.
  - Local document persistence engine (`NoteStorage`) supporting note creation, storage, reopening, and deletion.
  - Tablet-first handwriting UI (`HomeScreen`, `CanvasView`, `ToolbarWidget`) with Pen, Highlighter, Eraser, color palette, stroke widths, and paper templates.
  - Android ARM64 (`android-arm64`) configuration with hardware acceleration, split-screen multitasking (`resizeableActivity`), and ThinkPad X250 host memory limits.
  - Passing test suites across models, `.bfly` serialization, inking logic, undo/redo, eraser, and widget smoke tests (10/10 passed).
  - Successfully compiled and verified debug APK (`build/app/outputs/flutter-apk/app-debug.apk`, 78MB, `arm64-v8a`).
- Checkpoint: `CHECKPOINT-05-FOUNDATION-BASELINE`.

## [0.0.1] - 2026-10-10
### Added
- Phase 1 Upstream Repository Audit completed for Linwood Butterfly v2.6.0.
- Comprehensive Architectural Audit Report covering:
  - Canvas & drawing pipeline (`_ViewportCanvas`, `ViewPainter`, `ForegroundPainter`, `perfect_freehand`).
  - Page management, Area presets (A4, A3, Letter), and paper templates (`SurfaceTexture`, `PatternTexture`).
  - PDF pipeline (`pdfrx`, multi-layer vector annotation, PDF inversion, PDF export).
  - Storage engine (`.bfly` ZIP package format, JSON page files, SHA-512 asset indexing, synchronized autosave).
  - Android split-screen configuration (`AndroidManifest.xml`, responsive windowing).
  - Active stylus input pipeline (`PointerDeviceKind.stylus`, `penOnlyInput`, barrel button bindings).
- Feasibility Assessment for Lenovo Legion Y700 Gen 4 target hardware.
- Implementation Plan and Risk Register.
- Initial project tracking framework (`PROJECT_STATE.md`, `TODO.md`, `TEST_REPORT.md`, `CHANGELOG.md`).
- PHUC AI Learning Assistant Extension specifications and architecture design:
  - Multimodal Gemini 1.5/2.0 API integration with in-memory handwriting lasso crop analysis.
  - Source-grounded notebook & active PDF Q&A with coordinate citations.
  - BYOK (Bring Your Own Key) security via hardware-backed Android KeyStore.
  - Explicit user privacy consent gate; 100% offline core note-taking preservation.
  - Official investigation of Gemini Notebook Enterprise vs. Consumer NotebookLM API.
  - Floating AI chat window and collapsible dockable side panel optimized for 8.8" display.
- PHUC ORGANIZER Academic & Research Workspace module specification and architecture:
  - Academic calendar hierarchy (`Workspace > Year > Semester > Course`), course dashboards, and color tags.
  - Smart classification engine with filename heuristics, first-page PDF extraction, and user confirmation modal.
  - Global FTS5 search across note titles, tags, and indexed PDF text (< 100ms latency).
  - Research Workspace with BibTeX metadata cards, DOI indexing, and bidirectional PDF coordinate deep-links.
  - Semester Archiving (read-only freeze) and Soft Delete (30-day trash bin).
- PHUC TRANSLATE Scientific & Academic Translation module specification and architecture:
  - English <-> Vietnamese academic translation with Google ML Kit on-device engine (100% offline).
  - Optional cloud academic translation with BYOK hardware KeyStore credentials.
  - Scientific integrity protection engine: masking formulas, LaTeX, citations `[1]`, units, and DOIs.
  - Local SQLite scientific glossary editor for Computer Networks, OS, Algorithms, DB, AI, and Digital Twins.
  - Sandboxed Android MediaProjection screen translation evaluation with strict privacy guardrails.

### Changed
- Corrected Lenovo Legion Y700 Gen 4 target hardware specifications across all documentation:
  - SoC: Qualcomm Snapdragon 8 Elite (ARM64-v8a).
  - Display: 3040 × 1904 resolution (16:10 aspect ratio), up to 165Hz refresh rate, 8.8 inches.
- Replaced speculative stylus specs with empirical validation requirement: Lenovo AP501U pressure resolution, barrel buttons, hover, and palm rejection dynamics will be verified via Android `MotionEvent` and Flutter `PointerEvent` diagnostic testing on physical hardware.
- Decoupled AI architecture from fixed model identifiers: replaced deprecated Gemini 1.5/2.0 references with a provider-independent `AiProvider` architecture featuring dynamic model discovery at runtime.
- Formalized implementation status taxonomy across docs: explicitly distinguishing FOUNDATION IMPORT, PLANNED, IMPLEMENTED, TESTED, and VERIFIED ON DEVICE.
- Documented extended feature backlog: Handwriting search, Quick Capture, Mistake Notebook, Spaced Repetition, Source-linked Notes, Knowledge Graph, and Research Comparison Matrix.
- Checkpoint: `CHECKPOINT-04-POST-AUDIT-CORRECTIONS`.



