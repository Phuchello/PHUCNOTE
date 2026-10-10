# PhucNote

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20ARM64-green.svg)]()
[![Target Device](https://img.shields.io/badge/Target-Lenovo%20Legion%20Y700%20Gen%204-purple.svg)]()
[![Stylus](https://img.shields.io/badge/Stylus-Lenovo%20AP501U%20Active%20Pen-orange.svg)]()

**PhucNote** is an offline-first, tablet-optimized handwriting and note-taking application designed for Android devices, engineered specifically for compact tablets paired with an active stylus.

---

## Highlights

- **Low-Latency Inking:** Calibrated for high-refresh-rate displays (144Hz / 165Hz) with continuous Bezier stroke smoothing powered by `perfect_freehand`.
- **Active Stylus & Palm Rejection:** Dedicated hardware stylus handling tuned for the **Lenovo AP501U stylus**, featuring automatic touch palm rejection and barrel button tool-switching.
- **Multiple Canvas Modes:**
  - **Infinite Vertical Paper:** Continuous vertical document flow for lecture notes and study journaling.
  - **Infinite 2D Canvas:** Unbounded two-dimensional plane for mind-mapping and freeform sketching.
  - **Standard A4 Notebooks:** Fixed-page pagination mimicking traditional paper notebooks.
- **Custom Paper Templates:** Preconfigured ruled, quad grid, Cornell notes, dot grid, and engineering layouts across light and dark color schemes.
- **PDF Annotation & Inversion:** Import multi-page PDF documents, annotate with vector strokes, invert colors for night reading, and export vector-accurate PDFs.
- **Video-Assisted Study Workflow:** Floating, draggable lecture video overlay allowing simultaneous video watching and uninterrupted handwritten note-taking.
- **Tablet-First UI & Split Screen:** Adaptive layout with collapsible pill toolbars, 1-tap distraction-free Zen writing mode, and split-screen multitasking.
- **100% Offline-First & Private:** Local `.bfly` document archives, zero telemetry, zero mandatory cloud accounts, and synchronized autosave.

---

## Target Hardware Specifications

| Component | Target Specification |
| :--- | :--- |
| **Device** | Lenovo Legion Y700 Gen 4 (2024 / 2025 Edition) |
| **Form Factor** | 8.8-inch Compact Tablet (16:10 aspect ratio) |
| **Display** | 2560 × 1600 IPS LCD, 144Hz / 165Hz Refresh Rate |
| **SoC** | Qualcomm Snapdragon 8 Gen 3 (ARM64-v8a) |
| **Active Stylus** | Lenovo AP501U (4096 pressure levels, hover detection, barrel buttons) |
| **Host Development** | Lenovo ThinkPad X250 (Ubuntu Linux) via Google Antigravity |

---

## Architectural Heritage & Upstream Foundation

PhucNote builds upon the proven vector inking and archive architecture of **[Linwood Butterfly](https://github.com/LinwoodDev/Butterfly)** (v2.6.0 stable), preserving the drawing engine, viewport caching mechanism, and `.bfly` file format while completely revamping the user interface, tablet ergonomics, stylus response curves, and study workflows.

For complete architectural details and legal evaluations, refer to:
- [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md)
- [LICENSE_AUDIT.md](LICENSE_AUDIT.md)
- [PROJECT_STATE.md](PROJECT_STATE.md)
- [TODO.md](TODO.md)

---

## License & Compliance

PhucNote is free and open-source software licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.  
All upstream Linwood Butterfly copyright notices and contributor credits are preserved. All Linwood branding, trademarks, and logos have been decoupled and replaced with unique PhucNote assets pursuant to the Linwood Branding License (CC BY-SA 4.0).
