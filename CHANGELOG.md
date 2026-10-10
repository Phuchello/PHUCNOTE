# PhucNote — Changelog

All notable changes to the PhucNote project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]
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



