# PhucNote — Task Backlog (TODO)

## Phase 1 — Repository Audit & Architecture Assessment
- [x] Clone and inspect latest stable Linwood Butterfly release (`v2.6.0`, commit `1e4c86b`).
- [x] Audit drawing engine, canvas culling, and stroke rendering (`perfect_freehand`, `ViewPainter`, `ForegroundPainter`).
- [x] Audit page management, areas, and paper background systems (`DocumentPage`, `Area`, `SurfaceTexture`).
- [x] Audit PDF import (`pdfrx`), rendering, multi-layer annotation, and PDF export (`PdfExportAction`).
- [x] Audit storage engine, `.bfly` archive specification, autosave, and session state.
- [x] Assess Android split-screen configuration (`AndroidManifest.xml`, responsive Flutter views).
- [x] Audit stylus detection, pressure curve, barrel buttons, and palm rejection logic.
- [x] Review AGPL-3.0 compliance rules and Linwood branding separation requirements (`LICENSE_AUDIT.md`).
- [x] Evaluate Lenovo ThinkPad X250 hardware constraints (Core i5-5200U, 8GB RAM) and establish build mitigations.
- [x] Compare forking upstream vs. importing and maintaining source independently (`ARCHITECTURE.md`).
- [x] Design target PHUCNOTE system architecture and subsystem boundaries (`ARCHITECTURE.md`).
- [x] Initialize official PHUCNOTE deliverables:
  - [x] `README.md`
  - [x] `PRODUCT_REQUIREMENTS.md`
  - [x] `ARCHITECTURE.md`
  - [x] `DEVELOPMENT_ROADMAP.md`
  - [x] `LICENSE_AUDIT.md`
  - [x] `PROJECT_STATE.md`
  - [x] `TODO.md`
  - [x] `LICENSE` (AGPL-3.0)

## Phase 2 — Product Design & UI/UX Blueprint
- [ ] Design modern tablet-first UI for compact 8.8" 16:10 / 16:9 displays (Lenovo Legion Y700 Gen 4).
- [ ] Design floating pill pen palette and auto-docking gestures.
- [ ] Define distraction-free Zen writing mode with collapsible floating tools.
- [ ] Design continuous vertical paper mode and A4 notebook layout specifications.
- [ ] Specify custom paper template library (Ruled, Quad Grid, Cornell, Dotted, Blank in Light & Dark).
- [ ] Design floating video study overlay widget (YouTube / local video lecture player).
- [ ] Define high-contrast and eye-care dark and light themes.

## Phase 3 — Incremental Implementation
- [x] **Step 3.1: Clean Baseline Import & Branding Decoupling** (`CHECKPOINT-05-FOUNDATION-BASELINE`)
  - [x] Set up clean PhucNote develop branch.
  - [x] Establish independent Flutter foundation preserving audited Butterfly drawing pipeline and `.bfly` ZIP container format.
  - [x] Replace Linwood Butterfly branding, app name (`PhucNote`), and package identifier (`com.phucnote.app`).
  - [x] Maintain AGPL-3.0 attribution headers, upstream contributor credits, and source-code availability notices.
  - [x] Configure Android ARM64 target and host-constrained Gradle heap settings.
  - [x] Implement basic note lifecycle (create, write, save, reopen) with passing test suite and clean analysis.
  - [x] **P0 Data Safety Remediation:**
    - [x] Implement atomic file saving (`.tmp_<timestamp>` write + buffer flush + atomic rename).
    - [x] Implement crash recovery with `.bak` backup copy retention and fallback load.
    - [x] Implement reliable 1500ms debounced autosave upon stroke completion.
    - [x] Implement `WidgetsBindingObserver` lifecycle flush on pause/inactive/detached.
    - [x] Implement document switch guards, unsaved modification warnings, and `PopScope` exit protection.
    - [x] Verify on real files with `test/note_storage_data_safety_test.dart`.
  - [x] **P0 Stylus Input Remediation:**
    - [x] Implement framework-level `PointerDeviceKind.stylus` discrimination and configurable stylus-only inking.
    - [x] Gate touch input away from inking in stylus-only mode while preserving smooth finger viewport panning.
    - [x] Add software palm rejection heuristics (active pen contact rejection + contact area filtering).
    - [x] Add automatic eraser routing for inverted stylus tip events (`PointerDeviceKind.invertedStylus`).
    - [x] Verify with `test/stylus_input_test.dart` and disclaim hardware palm rejection until physical-device test.
  - [x] **P0 Undo/Redo Remediation:**
    - [x] Implement Command-pattern action-history engine (`CanvasAction`, `AddStrokeAction`, `EraseStrokesAction`, `ClearCanvasAction`).
    - [x] Verify mixed action sequences and original z-order index restoration with `test/canvas_action_history_test.dart`.
  - [x] **P0 Linwood Butterfly Compatibility Remediation:**
    - [x] Audit real Butterfly v2.6.0 document schema and fixture structure.
    - [x] Verify interoperability against actual upstream fixtures (`document_v1.bfly` and `study.tbfly`).
    - [x] Verify `.bfly` ZIP export hierarchy against Butterfly specification (`test/butterfly_interop_test.dart`).
  - [x] **Architecture Accuracy Remediation:**
    - [x] Document that drawing engine is an independent, lightweight custom implementation reproducing Butterfly's inking mathematics (`perfect_freehand` + bezier interpolation).
- [ ] **Step 3.2: Stylus & Low-Latency Tuning**
  - [ ] Verify active stylus event priority and palm rejection defaults for Lenovo AP501U stylus.
  - [ ] Calibrate pressure sensitivity presets for active styluses.
  - [ ] Optimize up to 165Hz screen refresh rate handling on Android.
- [ ] **Step 3.3: Notebook & Continuous Vertical Paper Modes**
  - [ ] Implement Continuous Vertical Paper view (seamless vertical scrolling across pages).
  - [ ] Implement Standard A4 Notebook mode with bounded page boundaries.
  - [ ] Add custom paper template presets (Cornell, Engineering Grid, Lined Dark/Light).
- [ ] **Step 3.4: Tablet UI & Distraction-Free Experience**
  - [ ] Implement Zen/Distraction-Free mode (single tap to hide all toolbars, full-screen canvas).
  - [ ] Optimize responsive layouts for split-screen multi-tasking (portrait and landscape split).
- [ ] **Step 3.5: Floating Video Study Workflow**
  - [ ] Implement floating draggable video player overlay for lecture study.
  - [ ] Ensure simultaneous video playback and uninterrupted stylus note-taking.
- [ ] **Step 3.6: PDF Import & Export Enhancements**
  - [ ] Streamline PDF document import as background pages or continuous notebook.
  - [ ] Optimize memory caching for large multi-page PDF documents.
  - [ ] Ensure faithful PDF export with high-resolution vector strokes.

## Phase 4 — Validation & Build Verification
- [ ] Configure Flutter / Android ARM64 build environment (`flutter build apk --target-platform android-arm64`).
- [ ] Test handwriting responsiveness and stroke latency.
- [ ] Test palm rejection behavior with Lenovo AP501U active stylus vs finger input.
- [ ] Test split-screen layout transitions (50/50 split with browser / video app).
- [ ] Test large PDF import, annotation, and export fidelity.
- [ ] Test autosave resilience against crash, kill, and low-memory scenarios.
- [ ] Verify 100% offline functionality without network dependencies.

## Phase 5 — Academic Modules: PHUC ORGANIZER & PHUC TRANSLATE
- [x] Design offline academic hierarchy schema and metadata specification (`academic_catalog.db`).
- [x] Design smart classification pipeline (filename heuristics & first-page PDF extraction).
- [x] Design scientific integrity protection rules (formula, LaTeX, and citation masking).
- [x] Audit Google ML Kit on-device translation and domain glossary architecture.
- [x] Evaluate Android MediaProjection technical requirements and privacy guardrails.
- [ ] Create `lib/features/organizer` module boundary and SQLite catalog schema.
- [ ] Implement Workspace, Academic Year, Semester, and Course hierarchy views.
- [ ] Implement multi-tagging and color-tagging registry with tag filter chips.
- [ ] Implement Global FTS5 search across note titles, tags, and indexed PDF text (< 100ms latency).
- [ ] Implement Semester Archiving (read-only freeze) and Soft Delete (30-day trash bin).
- [ ] Build Smart Classification ingestion engine with interactive confirmation routing dialog.
- [ ] Build Research Workspace with BibTeX metadata cards, DOI indexing, and PDF coordinate deep-links.
- [ ] Create `lib/features/translate` module boundary and `TranslationProvider` abstraction.
- [ ] Implement stylus highlight selection on canvas text and `pdfrx` PDF text streams.
- [ ] Implement Scientific Integrity Sanitizer (protecting `$math$`, `[citations]`, units, DOIs).
- [ ] Integrate Google ML Kit on-device translation (`google_mlkit_translation`, 100% offline).
- [ ] Integrate optional cloud academic translation provider with BYOK KeyStore credentials.
- [ ] Implement local SQLite scientific glossary editor (Networking, OS, Algorithms, DB, AI, Digital Twin).
- [ ] Build bilingual UI modes: side-by-side split view, interlinear cards, and 1-tap margin export.
- [ ] Build sandboxed Android MediaProjection screen translation service with system permission gating.

## Phase 6 — PHUC AI Learning Assistant Extension (Post-Validation)
- [x] Investigate and document official Gemini Notebook / NotebookLM API capabilities and constraints (`PRODUCT_REQUIREMENTS.md`, `ARCHITECTURE.md`).
- [ ] Create decoupled module structure (`lib/features/phuc_ai`).
- [ ] Implement BYOK (Bring Your Own Key) secure storage via `flutter_secure_storage` with Android KeyStore backing.
- [ ] Implement in-memory lasso selection crop rasterizer for multimodal handwriting vision queries.
- [ ] Implement document & PDF text retrieval engine with structured page and line citations.
- [ ] Build 1-tap study actions: Summarize Page, Explain Concept, Generate Quiz, Create Flashcards.
- [ ] Implement 1-tap "Insert AI Answer to Canvas" as Markdown/vector element.
- [ ] Build Floating AI Chat Window and Collapsible Side Panel optimized for 8.8" tablet.
- [ ] Build 1-tap "Export to NotebookLM" course bridge and optional Gemini Notebook Enterprise adapter.
- [ ] Implement prominent User Consent Dialog and payload inspection before network transmission.
- [ ] Verify zero latency impact on 165Hz background inking thread during active AI streaming.

## Extended Feature Backlog (Post-Phase 6)
- [ ] **Handwriting Search:** Stroke recognition and local full-text search across handwritten notes.
- [ ] **Quick Capture:** Fast-launch scratchpad widget directly from Android quick settings.
- [ ] **Mistake Notebook:** Dedicated categorization workflow for isolating and re-solving missed homework/exam problems.
- [ ] **Spaced Repetition:** Flashcard scheduling derived from marked note blocks and study cards.
- [ ] **Source-Linked Notes:** Deep bi-directional hyperlinks between canvas bounding boxes and source PDF coordinates.
- [ ] **Knowledge Graph:** Semantic node graph connecting notes, concepts, courses, and literature.
- [ ] **Research Comparison Matrix:** Multi-column analytical matrix comparing methodologies and results across academic papers.



