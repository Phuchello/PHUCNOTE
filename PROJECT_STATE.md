# PhucNote — Project State

## Project Overview
- **Project Name:** PhucNote
- **Official Repository:** [https://github.com/Phuchello/PHUCNOTE](https://github.com/Phuchello/PHUCNOTE)
- **Base Project:** [Linwood Butterfly](https://github.com/LinwoodDev/Butterfly) (Flutter)
- **Upstream Tag:** `v2.6.0` (Commit: `1e4c86b`, Latest Stable Release)
- **Target Hardware:** Lenovo Legion Y700 Gen 4 (8.8-inch 3040×1904 up to 165Hz IPS display, Snapdragon 8 Elite)
- **Input Hardware:** Lenovo AP501U Active Stylus (Empirical validation via Android MotionEvent/PointerEvent; no unverified pressure/button assumptions)
- **Target Platform:** Android ARM64 (`android-arm64`)
- **Development Environment:** Lenovo ThinkPad X250 (Ubuntu Linux 26.04 LTS, 8GB RAM, Intel Core i5-5200U) via Google Antigravity
- **License:** GNU Affero General Public License v3 (AGPL-3.0)
- **Objective:** Create a polished, free, offline-first handwriting note-taking application optimized for a compact Android tablet with an active stylus, preserving the upstream drawing engine and `.bfly` file format while adding continuous vertical paper, A4 notebook mode, custom paper templates, distraction-free mode, Android split-screen optimization, and a floating video study workflow.

---

## Current Status
- **Current Phase:** Phase 3 — Baseline Foundation Implementation (Executable Android Baseline Established)
- **Status:** Baseline Flutter application foundation imported, audited drawing engine preserved, `.bfly` ZIP serialization implemented and verified, full create/write/save/reopen lifecycle operational, Android ARM64 configured and successfully compiled into debug APK, all tests passing.
- **Upstream Source Code Status:** Audited and preserved 100% intact at `/home/vo-trong-phuc/Projects/butterfly-upstream`.
- **Current Checkpoint:** `CHECKPOINT-05-FOUNDATION-BASELINE`
- **Next Checkpoint:** `CHECKPOINT-06-STYLUS-TUNING`

---

## Architecture Summary
| Subsystem | Upstream Implementation | PhucNote Customization Plan |
| :--- | :--- | :--- |
| **Drawing Engine** | `ViewPainter` (baked viewport culling) + `ForegroundPainter` (active strokes) | **Preserve 100%**. Tune input polling and up to 165Hz vsync pipeline. |
| **Handwriting & Stroke** | `perfect_freehand` bezier smoothing with pressure & streamline | **Preserve 100%**. Calibrate pressure curve dynamically for Lenovo AP501U active stylus. |
| **Stylus & Palm Rejection** | `_ViewportInputCoordinator` + `EditorInputCubit.effectivePenOnlyInput` | Enforce automatic stylus-only inking; preserve two-finger pan/zoom navigation. Empirical testing of AP501U signals. |
| **Page Management** | Multi-page infinite 2D canvas with `Area` definitions | Add Continuous Vertical Paper mode and Standard A4 Notebook mode. |
| **PDF Handling** | `pdfrx` vector rasterizer + multi-layer annotation + vector PDF export | Preserve & optimize caching for multi-page PDF documents. |
| **Storage & Persistence** | `.bfly` ZIP container with JSON pages & SHA-512 hashed assets; `DocumentSaveCubit` autosave | Preserve `.bfly` spec with backward compatibility; add automated snapshot recovery. |
| **Window & Split-Screen** | Responsive Flutter layout + `android:configChanges` | Explicit `resizeableActivity`, tablet split-screen dynamic toolbar collapse, and floating video PiP. |
| **Themes & Aesthetics** | `flex_color_scheme` + light/dark texture backgrounds | Modern tablet-first minimalist UI, refined typography, and distraction-free writing mode. |
| **Academic Organization ("PHUC ORGANIZER")** | Generic file trees in `lw_file_system` | **Academic Workspace Engine**: Hierarchical academic calendar (`Workspace > Year > Semester > Course`), course dashboards, global FTS5 search (<100ms), smart classification with user confirmation, research paper workspace with DOI & BibTeX metadata. |
| **Scientific Translation ("PHUC TRANSLATE")** | None (New decoupled module) | **Scientific Translation Engine**: English <-> Vietnamese, Google ML Kit on-device engine (100% offline) + optional cloud academic mode, scientific integrity masking (formulas, LaTeX, citations `[1]`, units, DOIs), local terminology glossary for CS/engineering, and sandboxed MediaProjection screen translation evaluation. |
| **AI Learning Assistant ("PHUC AI")** | None (New decoupled module planned for Phase 6) | **Decoupled Extension**: Provider-independent multimodal AI with dynamic model discovery via BYOK encrypted in Android KeyStore; in-memory handwriting crop analysis; source-grounded PDF/notebook Q&A with citations; 1-tap NotebookLM course export bridge; explicit consent gate; 100% offline note core. Conditioned on prior validation of core handwriting. |

---

## Deliverables Generated in Official Repository
- [README.md](README.md): Project overview, features, hardware specifications, and links.
- [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md): Full PRD covering inking, canvas modes, PDF, video workflow, PHUC AI, PHUC ORGANIZER, PHUC TRANSLATE, and NFRs.
- [ARCHITECTURE.md](ARCHITECTURE.md): System architecture, comparison of fork vs. independent foundation, X250 host mitigations, inking pipeline, storage, PHUC AI, PHUC ORGANIZER, and PHUC TRANSLATE designs.
- [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md): Phased timeline, milestones, acceptance criteria, Phase 5 & 6 rollout rules, and git workflow.
- [LICENSE_AUDIT.md](LICENSE_AUDIT.md): Detailed AGPL-3.0 and branding compliance audit.
- [PROJECT_STATE.md](PROJECT_STATE.md): Active status, checkpoints, and hardware alignment.
- [TODO.md](TODO.md): Actionable task backlog across all six phases.
- [LICENSE](LICENSE): Full text of the GNU Affero General Public License v3.0.
