# PhucNote

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20ARM64-green.svg)]()
[![Target Device](https://img.shields.io/badge/Target-Lenovo%20Legion%20Y700%20Gen%204-purple.svg)]()
[![Stylus](https://img.shields.io/badge/Stylus-Lenovo%20AP501U-orange.svg)]()
[![Status](https://img.shields.io/badge/Status-Baseline%20Executable%20Setup-yellow.svg)]()

**PhucNote** is an offline-first handwriting note-taking application designed for compact Android tablets, built upon the foundation of [Linwood Butterfly](https://github.com/LinwoodDev/Butterfly).

> [!NOTE]
> **Project Status:** Currently in **Active Baseline Setup**. The repository contains the initial architecture specification, licensing audit, and baseline foundation. Executable Android ARM64 compilation and device verification on the physical Lenovo Legion Y700 Gen 4 are underway.

---

## Target Hardware Specifications (Verified)

| Component | Target Specification | Status |
| :--- | :--- | :--- |
| **Device** | Lenovo Legion Y700 Gen 4 (2024 / 2025 Edition) | Target Device |
| **Form Factor** | 8.8-inch Compact Tablet (16:10 aspect ratio) | Target |
| **Display** | 3040 × 1904 IPS LCD, Up to 165Hz Refresh Rate | Target |
| **SoC** | Qualcomm Snapdragon 8 Elite (ARM64-v8a) | Target |
| **Active Stylus** | Lenovo AP501U Active Stylus | Empirical verification required |
| **Host Development** | Lenovo ThinkPad X250 (Ubuntu Linux 26.04 LTS, Core i5-5200U, 8GB RAM) | Active Development Host |

*Stylus Note:* Stylus capabilities (pressure resolution, barrel button events, hover detection, and palm rejection dynamics) will be evaluated empirically via Android `MotionEvent` and Flutter `PointerEvent` diagnostics on physical hardware rather than unverified spec-sheet assumptions.

---

## Core Feature Roadmap & Status

| Feature Subsystem | Status | Description |
| :--- | :---: | :--- |
| **Drawing Engine & Inking Core** | **FOUNDATION IMPORT** | Preserves Butterfly's dual-painter architecture (`ViewPainter` + `ForegroundPainter`) and `perfect_freehand` smoothing. |
| **Active Stylus & Palm Rejection** | **FOUNDATION IMPORT** | Dedicated hardware stylus event handling (`PointerDeviceKind.stylus`), touch rejection, and empirical input diagnostics. |
| **Document Storage & Formats** | **FOUNDATION IMPORT** | Offline-first `.bfly` ZIP container storing JSON pages and content-addressed assets with atomic saving. |
| **Infinite 2D Canvas** | **FOUNDATION IMPORT** | Freeform pan, zoom, and coordinate transform navigation. |
| **Continuous Vertical Paper** | **PLANNED** | Downward-flowing sequential paper stream with automatic margin extension. |
| **Standard A4 Notebooks** | **PLANNED** | Constrained ISO A4 page boundary mode with carousel pagination. |
| **Custom Paper Templates** | **PLANNED** | Preconfigured ruled, grid, Cornell, dot matrix, and dark/light paper textures. |
| **PDF Annotation & Inversion** | **PLANNED** | On-demand viewport rendering via `pdfrx` with vector inking overlay and dark-mode color inversion. |
| **Tablet-First UI & Zen Mode** | **PLANNED** | Collapsible floating pill toolbar and 1-tap distraction-free writing mode for the 8.8" display. |
| **Floating Video Study Overlay** | **PLANNED** | Draggable picture-in-picture video player for concurrent lecture study and inking. |
| **PHUC ORGANIZER** | **PLANNED** | Academic workspaces, year/semester/course hierarchy, smart ingestion classifier, and research paper library. |
| **PHUC TRANSLATE** | **PLANNED** | English <-> Vietnamese scientific translation, formula/LaTeX masking, and local terminology glossaries. |
| **PHUC AI Assistant** | **PLANNED (POST-CORE)** | Decoupled multimodal learning assistant with dynamic model discovery and BYOK Android KeyStore security. |

---

## Extended Feature Backlog (Future Milestones)
- **Handwriting Search:** Stroke recognition and local full-text search across handwritten notes.
- **Quick Capture:** Fast-launch scratchpad widget directly from Android quick settings.
- **Mistake Notebook:** Dedicated categorization workflow for isolating and re-solving missed homework/exam problems.
- **Spaced Repetition:** Flashcard scheduling derived from marked note blocks and study cards.
- **Source-Linked Notes:** Deep bi-directional hyperlinks between canvas bounding boxes and source PDF coordinates.
- **Knowledge Graph:** Semantic node graph connecting notes, concepts, courses, and literature.
- **Research Comparison Matrix:** Multi-column analytical matrix comparing methodologies and results across academic papers.

---

## Project Documentation
- [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) — Comprehensive requirements and acceptance criteria.
- [ARCHITECTURE.md](ARCHITECTURE.md) — System architecture, inking pipeline, and hardware constraints.
- [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) — Phased milestone plan and branch workflow.
- [LICENSE_AUDIT.md](LICENSE_AUDIT.md) — AGPL-3.0 and CC BY-SA 4.0 branding compliance review.
- [PROJECT_STATE.md](PROJECT_STATE.md) — Active checkpoints, verified hardware specs, and milestone records.
- [TEST_REPORT.md](TEST_REPORT.md) — Physical device test suites and measured verification records.
- [TODO.md](TODO.md) — Actionable task backlog across all phases.

---

## License & Compliance
PhucNote is open-source software licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.  
All upstream Linwood Butterfly copyright notices and contributor credits are preserved. All Linwood branding, trademarks, and logos have been decoupled pursuant to the Linwood Branding License (CC BY-SA 4.0).
