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

---

## 4. Non-Functional Requirements (NFR)

- **NFR-PERF-01 (Touch-to-Ink Latency):** Sub-15ms perceived latency when running on Snapdragon 8 Gen 3 at 144Hz.
- **NFR-PERF-02 (Memory Overhead):** Baseline idle memory under 180MB RAM; large 100-page PDF documents capped under 450MB RAM via aggressive off-screen tile eviction.
- **NFR-SEC-01 (Data Integrity):** File saves must be atomic (write to temporary cache then swap) to eliminate file corruption during abrupt shutdowns.
- **NFR-SEC-02 (AI Privacy & Secret Safety):** Zero client telemetry; no shared API secrets compiled into the client APK; all user API keys encrypted with Android KeyStore; explicit user consent per transmission.
- **NFR-LEGAL-01 (License Compliance):** 100% AGPL-3.0 compliant source distribution; complete decoupling from Linwood Butterfly trademarks.
