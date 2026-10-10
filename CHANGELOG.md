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

