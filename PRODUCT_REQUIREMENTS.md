# PhucNote — Product Requirements Document (PRD)

**Project:** PhucNote  
**Version:** 1.0.0-Draft  
**Repository:** [https://github.com/Phuchello/PHUCNOTE](https://github.com/Phuchello/PHUCNOTE)  
**Target Device:** Lenovo Legion Y700 Gen 4 (8.8", 2560×1600, 144Hz/165Hz)  
**Input Device:** Lenovo AP501U Active Stylus  
**Platform:** Android ARM64  

---

## 1. Product Vision & Goals

PhucNote is built to deliver a premium, distraction-free digital paper experience on compact high-performance Android tablets. While mainstream proprietary note-taking applications often require subscriptions, cloud lock-in, and exhibit high handwriting latency on non-Samsung/non-iPad hardware, PhucNote provides:
- **Absolute Ownership & Privacy:** 100% offline-first operation with standard file exports.
- **Hardware-Specialized Inking:** Zero-lag handwriting tuned specifically for 144Hz/165Hz displays and active digitizers.
- **Academic & Professional Study Workflow:** Seamless PDF reading, multi-layer handwritten annotations, split-screen lecturing, and floating video playback.

---

## 2. Target Hardware Persona: Lenovo Legion Y700 Gen 4

| Attribute | Specification | Design Impact for PhucNote |
| :--- | :--- | :--- |
| **Display** | 8.8-inch IPS LCD, 2560×1600 (343 PPI), 16:10 | Dense pixel grid requires crisp vector anti-aliasing; UI scale must optimize for single-hand grip and active pen reach. |
| **Refresh Rate** | 144Hz / 165Hz High Refresh Rate | Drawing pipeline must keep frame execution under ~6.9ms (144Hz) / ~6.0ms (165Hz) to prevent ink trailing behind the stylus tip. |
| **SoC** | Qualcomm Snapdragon 8 Gen 3 | Powerful GPU (Adreno 750) and NPU enable fast off-screen raster caching and responsive PDF page rendering. |
| **Stylus** | Lenovo AP501U Active Stylus | 4096 pressure levels, active hover detection, fast tip response, and hardware barrel buttons. |
| **Portability** | ~350g compact gaming/work tablet | Ideal for one-handed portrait note-taking, split-screen landscape study, and lap writing. |

---

## 3. Core Functional Requirements

### 3.1 Low-Latency Handwriting & Stylus Subsystem
- **FR-INK-01 (Stroke Latency):** Writing strokes must be tracked on a dedicated foreground custom painter (`ForegroundPainter`) without triggering whole-canvas re-renders.
- **FR-INK-02 (Stylus Distinction):** Enforce strict pointer discrimination:
  - Stylus tip events (`PointerDeviceKind.stylus`) trigger pen inking.
  - Inverted stylus tail events (`PointerDeviceKind.invertedStylus`) trigger immediate stroke erasing.
  - Finger touch events (`PointerDeviceKind.touch`) are rejected for drawing when stylus mode is active.
- **FR-INK-03 (Palm Rejection):** Automatic Palm Rejection must activate immediately upon detecting stylus proximity or touch down. While resting the palm on the glass, zero accidental marks or stray vector points may be committed.
- **FR-INK-04 (Multi-Touch Navigation):** While palm rejection blocks single-finger drawing, two-finger gestures (pinch-to-zoom, two-finger pan, and rotation) must remain smoothly accessible.
- **FR-INK-05 (Pressure Calibration):** Map the 4096 pressure levels from the Lenovo AP501U stylus to an ergonomic logarithmic or smooth polynomial curve suitable for fountain pen, ballpoint pen, and highlighter tools.
- **FR-INK-06 (Hardware Button Actions):** Allow the user to assign stylus barrel buttons to:
  - Button 1: Toggle Eraser (hold or click).
  - Button 2: Toggle Lasso Selection or Pan Hand tool.

### 3.2 Canvas & Paper Modes
- **FR-CAN-01 (Infinite Vertical Paper Mode):**
  - Provide a continuous vertical writing stream where pages flow downwards seamlessly.
  - Auto-append vertical space as the stylus writes near the bottom margin.
  - Render subtle, non-intrusive page break markers for printing or exporting reference.
- **FR-CAN-02 (Infinite 2D Canvas Mode):**
  - Unbounded Cartesian plane in all directions with fluid camera transform (panning, continuous zooming from 10% to 5000%, and rotation).
- **FR-CAN-03 (Standard A4 Notebook Mode):**
  - Fixed-ratio sheets matching international ISO 216 A4 dimensions (210mm × 297mm).
  - Page navigation via bottom/side carousel, thumbnail grid, and swipe gestures.
- **FR-CAN-04 (Paper Template System):**
  - Preloaded templates in Light (Paper White, Warm Ivory) and Dark (Charcoal, Deep Black):
    - Plain Blank
    - Ruled / Lined (Narrow 5mm, Medium 7mm, Wide 9mm)
    - Quad Grid / Graph (3mm, 5mm)
    - Dot Grid (5mm spacing)
    - Cornell Notes (Header, Cue column, Notes body, Summary footer)
    - Engineering Hexagonal & Stave lines
  - Custom user template import via PNG, SVG, or PDF page background.

### 3.3 PDF Import, Annotation & Export
- **FR-PDF-01 (Import Workflow):** Import multi-page PDF documents and automatically lay them out as sequential notebook pages or canvas elements.
- **FR-PDF-02 (High-Resolution Rasterization):** Render PDF pages on-demand at the active viewport scale via `pdfrx`, maintaining crisp text without raster blur.
- **FR-PDF-03 (Multi-Layer Annotation):** User handwriting strokes are stored as non-destructive vector paths above the PDF background.
- **FR-PDF-04 (Dark Mode Inversion):** Provide a 1-tap option to invert PDF content colors for comfortable dark-mode reading without inverting the user's color annotations.
- **FR-PDF-05 (Vector PDF Export):** Export annotated documents back to PDF with high-fidelity vector paths, embedded fonts, and original PDF text clarity.

### 3.4 Tablet-First User Interface & Zen Mode
- **FR-UI-01 (Ergonomic Floating Toolbar):** Compact pill-shaped toolbar optimized for 8.8" tablet screens:
  - Can be docked to Top, Bottom, Left, or Right edge.
  - Automatically collapses to icon-only state during intensive writing.
- **FR-UI-02 (Distraction-Free Zen Mode):** Single tap or stylus edge-gesture hides all toolbars, system bars, and status icons, dedicating 100% of the display to handwriting.
- **FR-UI-03 (Android Split-Screen Optimization):**
  - App responds fluidly when docked in 50/50, 70/30, or 30/70 split-screen mode on Android 14+.
  - When window width is constrained below 600dp, the toolbar automatically switches to a compact stacked mode.

### 3.5 Video-Assisted Study Workflow
- **FR-VID-01 (Floating Video Player Overlay):**
  - In-app draggable, resizable floating video widget overlaying the canvas.
  - Supports local lecture videos (MP4, MKV) and online lecture streams (web/YouTube).
- **FR-VID-02 (Input Isolation):** Interacting with the video player (play, pause, seek, scrub) must not conflict with active stylus inking on the underlying canvas.
- **FR-VID-03 (Lecture Timestamps):** Optional ability to drop a "video timestamp bookmark" directly onto the note canvas that jumps the player to that lecture second.

### 3.6 Data Safety & Offline Storage
- **FR-DAT-01 (100% Offline):** Zero telemetry, zero external login requirement.
- **FR-DAT-02 (Autosave & Atomicity):** Debounced background autosave executed with thread-safe locking (`savingLock`).
- **FR-DAT-03 (Crash Recovery):** In-memory stroke journal flushed to persistent storage before application lifecycle pauses or terminates.
- **FR-DAT-04 (File Portability):** Documents saved in open, standard `.bfly` ZIP container with human-readable JSON page specifications.

### 3.7 PHUC AI — AI Learning Assistant Extension (Planned Module)
- **FR-AI-01 (Floating AI Chat Window):** Draggable, compact AI chat bubble/window that floats above the canvas, allowing students to converse with the AI tutor without switching applications or losing handwriting state.
- **FR-AI-02 (Resizable AI Side Panel):** Dockable side panel (dockable to right or left screen edge) supporting flexible split ratios (30/70, 50/50) on the 8.8" Legion Y700 display for in-depth reading, study summaries, and prompt dialogues alongside the note canvas.
- **FR-AI-03 (Handwriting Selection Q&A via Multimodal AI):**
  - Lasso-selected handwriting strokes can be captured directly via a context menu action ("Ask Phuc AI", "Solve Equation", "Explain Step").
  - The cropped handwriting vector bounding box is rasterized into an in-memory PNG and forwarded to multimodal Gemini models (e.g. Gemini 1.5/2.0 Flash) with zero disk leakage.
- **FR-AI-04 (Active PDF Q&A):** Query questions directly against the currently loaded PDF textbook/slides; the system extracts the relevant page text and vector visual context to answer student questions.
- **FR-AI-05 (Source-Grounded Notebook Q&A with Citations):**
  - Enable students to query across entire notebook collections or course materials.
  - Answers must provide clear source citations referencing specific notebook pages or PDF page numbers.
- **FR-AI-06 (Prebuilt Academic Study Actions):**
  - 1-tap quick actions: **Summarize Page**, **Explain Concept**, **Generate 5-Question Quiz**, **Create Flashcard Deck**, and **Extract Action Items**.
- **FR-AI-07 (Insert AI Responses to Canvas):**
  - 1-tap action to paste formatted AI answers, diagrams, or quiz questions directly into the note canvas as a Markdown text element, editable vector text, or sticky note.
- **FR-AI-08 (Gemini API Integration & BYOK Security):**
  - Direct integration with Google AI Studio / Gemini API (`google_generative_ai`).
  - **BYOK (Bring Your Own Key):** Users configure their own Google AI Studio API key. Keys are saved exclusively in encrypted Android hardware-backed storage (`flutter_secure_storage` via Android KeyStore).
  - **Zero Shared Secrets:** No master or bundled API keys are ever compiled into the APK.
- **FR-AI-09 (Investigation of External Gemini Notebook / NotebookLM Integration):**
  - *Investigation Finding:* Consumer NotebookLM does **not** provide a public developer API; third-party scraping scripts violate Google ToS and break unexpectedly. However, Google provides an official **Gemini Notebook Enterprise API** for Google Cloud/Workspace organizations.
  - *PhucNote Integration Strategy:*
    1. **Primary Integration:** Direct Gemini 1.5/2.0 API with multimodal vision and large context window grounding.
    2. **Consumer NotebookLM Bridge:** Formatted 1-tap export of clean course notes and extracted sources optimized for manual upload to NotebookLM or synced via Google Drive.
    3. **Enterprise Gemini Notebook Option:** Support optional Google Cloud Project credentials and OAuth2 service tokens for academic institutions with Gemini Enterprise licenses.
- **FR-AI-10 (Privacy, Consent & Offline Sovereignty):**
  - All core note-taking features remain 100% offline. AI is strictly opt-in.
  - A prominent, clear Consent Modal must be acknowledged before any note content, handwriting image, or PDF excerpt is transmitted over the network.
  - Granular privacy settings: allow users to inspect the exact prompt, text, or image payload before submission.
- **FR-AI-11 (Tablet Ergonomics & Video Study Coexistence):**
  - Compatible with the floating video study overlay: the AI chat panel and video player can dock side-by-side or stack ergonomically in both landscape and portrait orientations on the 8.8" tablet.
- **FR-AI-12 (Staged Rollout Constraint):** AI features must remain decoupled and will only be activated after the core inking engine, palm rejection, and `.bfly` file safety pass physical validation on the Legion Y700.

### 3.8 PHUC ORGANIZER — Academic & Research Workspace Management
- **FR-ORG-01 (Unlimited Academic Workspaces):** Isolated top-level environments (e.g., "Undergraduate Studies", "Grad School / Lab", "Personal Notes") with independent storage trees and tag taxonomies.
- **FR-ORG-02 (Academic Calendar Hierarchy):** Structured academic calendar hierarchy: `Workspace > Academic Year > Semester > Course > Notebook > Page`. Supports standard terms (Fall, Spring, Summer) and custom flexible terms.
- **FR-ORG-03 (Course-Based Notebooks):** Dedicated home notebook per course, organizing syllabus tracking, lecture slides, lab notes, and exam reviews in structured sections.
- **FR-ORG-04 (Nested Folders & Subfolders):** Arbitrary-depth folder nesting within courses (e.g., `Lectures / Week 03 / Lab Exercises`).
- **FR-ORG-05 (Multi-Tagging & Color Coding):** Multiple customizable tags per notebook and page (e.g., `#exam-prep`, `#midterm`, `#needs-review`, `#lab3`) with color tagging for fast visual filtering.
- **FR-ORG-06 (Course-Specific Academic Dashboard):**
  - Course overview showing upcoming milestones, syllabus notes, pinned references, and recent lecture note cards.
  - 1-tap quick action to "New Lecture Note" inheriting course templates and styling.
- **FR-ORG-07 (Global Multi-Attribute Search):**
  - Instant search across all notebooks within a workspace.
  - Queries search notebook titles, tags, typed text elements, metadata, and extracted PDF text with search latency < 100ms.
- **FR-ORG-08 (Favorites & Recents Shelf):** Fast-access shelf on the home screen for pinned documents and recently opened notebooks.
- **FR-ORG-09 (Semester Archiving):** Completed semesters can be archived into read-only freeze state, hiding them from the active dashboard while keeping all notes, vector strokes, and attachments searchable and fully intact.
- **FR-ORG-10 (Soft Delete & Trash Recovery):** Two-stage deletion: files moved to Trash Bin can be restored within 30 days or immediately purged.
- **FR-ORG-11 (Smart Classification Engine):**
  - Analyzes imported files (filename heuristics: e.g. `CS301_Lec05.pdf`, creation timestamps, and extracted first-page text).
  - Automatically suggests target workspace, semester, course, and folder.
  - Optional AI-assisted classification (heuristics first, optional Gemini categorization).
  - Requires explicit user confirmation dialog before moving any file, with 1-tap manual override.
- **FR-ORG-12 (Dedicated Research Workspace & Literature Library):**
  - Specialized workspace optimized for paper reading, thesis writing, and literature reviews.
  - Paper metadata fields: Title, Authors, Year, Journal/Conference, DOI, BibTeX citation key, Abstract.
  - Literature review note cards linked to the source PDF.
  - Bi-directional cross-document links between papers, review notes, and handwriting canvases.
  - Automatic citation generation in standard formats (IEEE, ACM, APA).

### 3.9 PHUC TRANSLATE — Scientific & Academic Translation Engine
- **FR-TRN-01 (Bilingual Target):** High-precision English <-> Vietnamese academic translation.
- **FR-TRN-02 (Granular Selection Translation):**
  - Translate selected words, phrases, or full paragraphs directly on the canvas or active PDF.
  - Stylus-driven selection: Lenovo AP501U stylus drag highlight over text or lasso rectangle over paragraph.
- **FR-TRN-03 (Side-by-Side & Popover Views):**
  - Floating translation card next to the selected text with 1-tap expandable side-by-side view.
  - Bilingual reading mode: parallel columns or interlinear translation cards that preserve document context.
- **FR-TRN-04 (Save Translation to Notes):**
  - 1-tap action to paste translation as a margin annotation, sticky note, or canvas Markdown block directly alongside the original text.
- **FR-TRN-05 (Bridge to Phuc AI):**
  - "Ask Phuc AI About This Translation" action in the translation popup for instant conceptual breakdown or deeper clarification.
- **FR-TRN-06 (Scientific Integrity Preservation):**
  - Strictly preserves:
    - Mathematical symbols, variables ($x, y, \theta$), equations, and scientific notation ($1.2 \times 10^{-4}$).
    - Citation indices ([1], [12-15]), DOIs, Figure/Table labels (Figure 2a, Table 1).
    - Units (ms, GHz, $\mu m$, MB/s, mW) and quantitative numerical findings.
  - Zero modification to the source PDF file.
  - Text-based PDF extraction prioritized; scanned PDF OCR evaluated separately.
- **FR-TRN-07 (Dual Translation Providers & Offline Mode):**
  - **On-Device Offline Engine (Primary Default):** Google ML Kit Translation (`google_mlkit_translation`), downloading English-Vietnamese offline models (~30MB) for 100% offline, privacy-first translation.
  - **Optional Academic Cloud Engine:** Google Gemini API with specialized academic translation system prompts preserving mathematical syntax and context.
  - Provider-independent architecture (`TranslationProvider` interface) with zero hardcoded shared API secrets (BYOK).
- **FR-TRN-08 (Customizable Scientific Terminology Glossary):**
  - Preloaded with vetted academic dictionaries in: Computer Networks, Operating Systems, Algorithms, Databases, Artificial Intelligence, and Digital Twin research.
  - User-configurable terminology preferences (e.g. override specific translations) stored locally in SQLite/JSON.
- **FR-TRN-09 (External Screen Translation Evaluation - MediaProjection):**
  - Technical evaluation of optional translation outside PhucNote using Android `MediaProjection`.
  - Requires explicit `FOREGROUND_SERVICE_MEDIA_PROJECTION` runtime permission and system user consent dialog.
  - Privacy safeguards: Automatically respects `FLAG_SECURE` to prevent capturing banking/auth apps; strictly on-device processing; zero background recording or streaming.
  - Unrestricted background screen capture is strictly forbidden.

---

## 4. Non-Functional Requirements & Measurable Acceptance Criteria

- **NFR-PERF-01 (Touch-to-Ink Latency):** Sub-15ms perceived latency when running on Snapdragon 8 Gen 3 at 144Hz.
- **NFR-PERF-02 (Memory Overhead):** Baseline idle memory under 180MB RAM; large 100-page PDF documents capped under 450MB RAM via aggressive off-screen tile eviction.
- **NFR-PERF-03 (Translation Responsiveness):** On-device ML Kit translation returns rendered Vietnamese text within 600ms for standard paragraphs (up to 200 words).
- **NFR-PERF-04 (Organizer Search Latency):** Global metadata and text search returns top 50 ranked results across 10,000 note entities in under 100ms.
- **NFR-SEC-01 (Data Integrity):** File saves must be atomic (write to temporary cache then swap) to eliminate file corruption during abrupt shutdowns.
- **NFR-SEC-02 (AI & Translation Privacy):** Zero client telemetry; no shared API secrets compiled into the client APK; all user API keys encrypted with Android KeyStore; explicit user consent per cloud transmission; ML Kit translation runs 100% on-device.
- **NFR-SEC-03 (Screen Translation Guardrails):** MediaProjection must enforce system consent modal, display ongoing notification, respect `FLAG_SECURE`, and never store raw screen frames to disk.
- **NFR-LEGAL-01 (License Compliance):** 100% AGPL-3.0 compliant source distribution; complete decoupling from Linwood Butterfly trademarks.
