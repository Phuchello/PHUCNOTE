# PhucNote — Project State

## Project Overview
- **Project Name:** PhucNote
- **Official Repository:** [https://github.com/Phuchello/PHUCNOTE](https://github.com/Phuchello/PHUCNOTE)
- **Base Project:** [Linwood Butterfly](https://github.com/LinwoodDev/Butterfly) (Flutter)
- **Upstream Tag:** `v2.6.0` (Commit: `1e4c86b`, Latest Stable Release)
- **Target Hardware:** Lenovo Legion Y700 Gen 4 (8.8-inch 2560×1600 144Hz/165Hz IPS display, Snapdragon 8 Gen 3)
- **Input Hardware:** Lenovo AP501U Active Stylus (4096 pressure levels, active digitizer, barrel buttons)
- **Target Platform:** Android ARM64 (`android-arm64`)
- **Development Environment:** Lenovo ThinkPad X250 (Ubuntu Linux 26.04 LTS, 8GB RAM, Intel Core i5-5200U) via Google Antigravity
- **License:** GNU Affero General Public License v3 (AGPL-3.0)
- **Objective:** Create a polished, free, offline-first handwriting note-taking application optimized for a compact Android tablet with an active stylus, preserving the upstream drawing engine and `.bfly` file format while adding continuous vertical paper, A4 notebook mode, custom paper templates, distraction-free mode, Android split-screen optimization, and a floating video study workflow.

---

## Current Status
- **Current Phase:** Phase 1 — Repository Audit & Architecture Assessment
- **Status:** Architecture audit, feasibility assessment, licensing compliance review, ThinkPad X250 hardware evaluation, official project documentation, and PHUC AI extension specifications completed.
- **Upstream Source Code Status:** Audited and preserved 100% intact at `/home/vo-trong-phuc/Projects/butterfly-upstream`. No premature code modifications made.
- **Current Checkpoint:** `CHECKPOINT-02-PHUCAI-SPECS`

---

## Architecture Summary
| Subsystem | Upstream Implementation | PhucNote Customization Plan |
| :--- | :--- | :--- |
| **Drawing Engine** | `ViewPainter` (baked viewport culling) + `ForegroundPainter` (active strokes) | **Preserve 100%**. Tune input polling and 144Hz vsync pipeline. |
| **Handwriting & Stroke** | `perfect_freehand` bezier smoothing with pressure & streamline | **Preserve 100%**. Calibrate pressure curve for Lenovo AP501U active stylus. |
| **Stylus & Palm Rejection** | `_ViewportInputCoordinator` + `EditorInputCubit.effectivePenOnlyInput` | Enforce automatic stylus-only inking; preserve two-finger pan/zoom navigation. |
| **Page Management** | Multi-page infinite 2D canvas with `Area` definitions | Add Continuous Vertical Paper mode and Standard A4 Notebook mode. |
| **PDF Handling** | `pdfrx` vector rasterizer + multi-layer annotation + vector PDF export | Preserve & optimize caching for multi-page PDF documents. |
| **Storage & Persistence** | `.bfly` ZIP container with JSON pages & SHA-512 hashed assets; `DocumentSaveCubit` autosave | Preserve `.bfly` spec with backward compatibility; add automated snapshot recovery. |
| **Window & Split-Screen** | Responsive Flutter layout + `android:configChanges` | Explicit `resizeableActivity`, tablet split-screen dynamic toolbar collapse, and floating video PiP. |
| **Themes & Aesthetics** | `flex_color_scheme` + light/dark texture backgrounds | Modern tablet-first minimalist UI, refined typography, and distraction-free writing mode. |
| **AI Learning Assistant ("PHUC AI")** | None (New decoupled module planned for Phase 5) | **Decoupled Extension**: Multimodal Gemini 1.5/2.0 API via BYOK encrypted in Android KeyStore; in-memory handwriting crop analysis; source-grounded PDF/notebook Q&A with citations; 1-tap NotebookLM course export bridge; explicit consent gate; 100% offline note core. Conditioned on prior validation of core handwriting. |

---

## Deliverables Generated in Official Repository
- [README.md](README.md): Project overview, features, hardware specifications, and links.
- [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md): Full PRD covering inking, canvas modes, PDF, video workflow, PHUC AI extension, and NFRs.
- [ARCHITECTURE.md](ARCHITECTURE.md): System architecture, comparison of fork vs. independent foundation, X250 host mitigations, inking pipeline, storage, and PHUC AI module design.
- [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md): Phased timeline, milestones, acceptance criteria, Phase 5 AI rollout rules, and git workflow.
- [LICENSE_AUDIT.md](LICENSE_AUDIT.md): Detailed AGPL-3.0 and branding compliance audit.
- [PROJECT_STATE.md](PROJECT_STATE.md): Active status, checkpoints, and hardware alignment.
- [TODO.md](TODO.md): Actionable task backlog across all five phases.
- [LICENSE](LICENSE): Full text of the GNU Affero General Public License v3.0.
