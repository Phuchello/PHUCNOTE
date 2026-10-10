# PhucNote — System Architecture & Design Specification

**Project:** PhucNote  
**Repository:** [https://github.com/Phuchello/PHUCNOTE](https://github.com/Phuchello/PHUCNOTE)  
**Target Hardware:** Lenovo Legion Y700 Gen 4 (Snapdragon 8 Gen 3, 144Hz/165Hz, Android ARM64)  
**Input Hardware:** Lenovo AP501U Active Stylus (4096 pressure levels, active digitizer)  
**Development Host:** Lenovo ThinkPad X250 (Ubuntu Linux, 8GB RAM, Core i5-5200U)  

---

## 1. High-Level Architectural Overview

PhucNote is built on Flutter with a layered, reactive BLoC/Cubit architecture. It maintains strict separation between hardware input capture, transient in-progress stroke rendering, viewport culling, and atomic document persistence.

```mermaid
flowchart TD
    subgraph Hardware_Layer["Hardware & OS Layer (Android ARM64 / Legion Y700)"]
        HW1[Qualcomm Snapdragon 8 Gen 3 / Adreno 750]
        HW2[Lenovo AP501U Active Stylus\n4096 Pressure Levels + Barrel Buttons]
        HW3[144Hz / 165Hz 2.5K IPS Screen]
        HW4[Android 14+ WindowManager\nSplit-Screen & Freeform]
    end

    subgraph Input_Coordinator["Input & Gesture Coordinator"]
        IN1[_ViewportInputCoordinator]
        IN2{PointerDeviceKind}
        IN3[Stylus Tip & Tail Inverted]
        IN4[Touch Gestures\nTwo-Finger Pan & Pinch Zoom]
        IN5[Palm Filter\nSingle-Finger Touch Rejected]
    end

    subgraph Engine_Core["Preserved Drawing Core (Butterfly Foundation)"]
        DC1[ForegroundPainter\nReal-Time Vector Ribbon]
        DC2[perfect_freehand\nOutline Bezier Calculation]
        DC3[ViewPainter\nViewport Culling & Image Baking]
        DC4[TransformCubit & CameraTransform]
    end

    subgraph Extended_Features["PhucNote Custom Subsystems"]
        EX1[Continuous Vertical Paper Coordinator]
        EX2[A4 Fixed Notebook Layout Manager]
        EX3[Floating Video Study Overlay Widget]
        EX4[Distraction-Free Zen Mode Controller]
        EX5[Paper Template Engine\nCornell / Grid / Ruled]
    end

    subgraph Document_Storage["Document & Offline Storage"]
        DS1[DocumentBloc & NoteData]
        DS2[pdfrx On-Demand PDF Rasterizer]
        DS3[DocumentSaveCubit & savingLock]
        DS4[.bfly Container\nZIP + JSON Pages + SHA-512 Assets]
    end

    HW2 --> IN1
    IN1 --> IN2
    IN2 -->|Stylus| IN3
    IN2 -->|Touch| IN4
    IN2 -->|Palm| IN5
    IN3 --> DC1
    DC1 --> DC2
    DC2 --> DC3
    IN4 --> DC4
    DC4 --> DC3

    DC3 --> EX1
    DC3 --> EX2
    HW4 --> EX4
    HW4 --> EX3

    EX1 --> DS1
    EX2 --> DS1
    DS1 --> DS2
    DS1 --> DS3
    DS3 --> DS4
```

---

## 2. Strategic Strategy: Upstream Fork vs. Independent Core Foundation

To establish the official repository at [Phuchello/PHUCNOTE](https://github.com/Phuchello/PHUCNOTE), we conducted a technical trade-off evaluation:

### Option A: Direct Git Remote Fork of Butterfly
- **Mechanism:** Maintain `LinwoodDev/Butterfly` as git upstream remote and layer commits on top.
- **Drawbacks:**
  - Carries upstream git history (~10,000+ commits), legacy build scripts for macOS DMG, Windows MSIX, Snapcraft, and Web workers.
  - Frequent breakage from upstream internal package refactoring (`dart_pkgs`, `Swamp`, `material_leap`).
  - Difficult to strip proprietary Linwood branding and trademarks cleanly without merge conflicts.

### Option B: Independent Clean-Slate Repository with Audited Foundation (Selected)
- **Mechanism:** Initialize `Phuchello/PHUCNOTE` as an independent repository. Import and vendor the audited drawing engine, models, and `.bfly` serializer. Build a focused, tablet-first UI and dedicated Android modules directly on top.
- **Advantages:**
  - **Zero Legacy Bloat:** Strips non-Android desktop artifacts, shrinking repository size and build times.
  - **Full Architectural Autonomy:** Clean slate to implement the Continuous Vertical Paper and Floating Video Study workflows without fighting desktop layout constraints.
  - **Pristine AGPL-3.0 Compliance:** Distinct product identity under custom branding while crediting Linwood under AGPL-3.0.
  - **Optimized for ThinkPad X250:** Compact codebase enables fast compilation within 8GB RAM constraints.

---

## 3. ThinkPad X250 Development Host Constraints & Mitigations

The development host is a **Lenovo ThinkPad X250** running Ubuntu Linux:
- **Processor:** Intel Core i5-5200U @ 2.20GHz (2 physical cores, 4 threads).
- **RAM:** 8 GB DDR3L (~7.1 GiB usable, ~3.0 GiB available).
- **Storage:** 120GB SSD (~55 GB available).
- **Compilation Constraints:**
  - Full Android Gradle builds combined with Dart `build_runner` code generation can easily exceed 4GB memory, inducing heavy swap trashing and thermal throttling.
- **Host Mitigations:**
  1. Constrain Gradle daemon memory in `gradle.properties`:
     ```properties
     org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:+UseParallelGC
     org.gradle.parallel=false
     org.gradle.vfs.watch=false
     ```
  2. Minimize concurrent build threads (`--max-workers=2`).
  3. Pre-generate Freezed and JSON serializable classes during milestones rather than running continuous file watchers.
  4. Perform incremental builds focused on `android-arm64` APK artifacts.

---

## 4. Subsystem Design Specifications

### 4.1 Inking & Latency Pipeline
- **Foreground Fast Path:** Ongoing strokes are gathered in `PenHandler` and immediately pushed to `ForegroundPainter`. They bypass the main canvas tree and render directly to the active hardware-accelerated Skia/Impeller canvas.
- **Smoothing & Outline Construction:**
  - Points are collected as `PathPoint(x, y, pressure, tilt)`.
  - Fed into `freehand.getStroke()` with `streamline` (0.45) and `smoothing` (0.55) to eliminate hand tremor while maintaining sharp corners.
  - Outlines are joined with quadratic Bezier curves and filled with `Paint(isAntiAlias: true)`.
- **Viewport Baking:** Once the stylus lifts (`onPointerUp`), after a debounce timer, strokes are baked into an off-screen bitmap tile (`cameraViewport.image`). During subsequent panning or zooming, only the lightweight raster tile is transformed until high-res settling occurs.

### 4.2 Stylus & Palm Rejection (Lenovo AP501U)
- The AP501U active digitizer transmits distinct hardware signals:
  - Stylus proximity triggers hover events before the tip touches the glass.
  - The digitizer reports `PointerDeviceKind.stylus` with hardware pressure (0 to 4096).
  - Barrel buttons report button bitmasks (`kSecondaryMouseButton`, etc.).
- **Rejection Logic:**
  ```dart
  if (penOnlyInputActive && event.kind == PointerDeviceKind.touch) {
    if (activePointerCount == 1) {
      // Discard single-finger touch as palm contact
      return;
    }
  }
  ```
  Two-finger touches are recognized by the gesture recognizer as navigation events (`TransformCubit.moveConstrained` and `zoomConstrained`).

### 4.3 Canvas Modes Architecture
1. **Infinite 2D Canvas:** Utilizes Butterfly's native `CameraTransform` coordinate space ($[x, y, \text{scale}, \text{rotation}]$).
2. **Infinite Vertical Paper:**
   - Pages are stacked sequentially along the $Y$ axis: $\text{Page}_n.y = \text{Page}_{n-1}.y + \text{PageHeight} + \text{Margin}$.
   - Horizontal scrolling is constrained to the paper width, providing a stable, notebook-like column.
   - Touching near the bottom boundary triggers dynamic page expansion.
3. **Standard A4 Notebook Mode:**
   - Viewport is constrained to an A4 ratio ($1 : \sqrt{2}$).
   - Paging navigation transitions between discrete pages with thumbnail index previews.

### 4.4 Floating Video Study Workflow
- Implemented as a top-level overlay in the editor `Stack`:
  ```dart
  Stack(
    children: [
      ViewportCanvas(),       // Drawing canvas
      FloatingVideoWidget(),  // Draggable picture-in-picture video
      FloatingToolbar(),      // Collapsible pen palette
    ],
  )
  ```
- Uses a `GestureDetector` with `HitTestBehavior.translucent` bounded strictly to the video pill. Stylus touches outside the video pill fall through cleanly to the canvas.
- Supports local video files (`video_player`) and YouTube / lecture streams.

### 4.5 Storage Engine & File Format
- File extension: `.bfly` (standard ZIP package).
- Internal hierarchy:
  - `meta.json`: Document name, created/updated timestamps, version header (`fileVersion: 2`).
  - `info.json`: Document preferences, thumbnail metadata, paper type.
  - `thumbnail.png`: 512×512 preview image.
  - `pages/0.page.json`, `pages/1.page.json`: Layer hierarchy and vector stroke arrays.
  - `assets/` (`images/`, `pdf/`, `textures/`): Stored by SHA-512 content hash to deduplicate binary assets.
- Persistence is handled by `DocumentSaveCubit` wrapping all writes in a mutex `savingLock.synchronized()` to prevent corruption.

### 4.6 PHUC AI — Learning Assistant Extension Architecture

Phuc AI is designed as a completely decoupled, modular extension. It layers non-intrusively above the note canvas without coupling to the low-level rendering or serializer internals.

```mermaid
flowchart TD
    subgraph UI_Surface["Editor Overlay Stack"]
        U1[Canvas Inking Surface]
        U2[Lasso Selection Context Menu]
        U3[Floating AI Chat Window]
        U4[Collapsible AI Side Panel]
    end

    subgraph PhucAI_Module["Phuc AI Core Engine (lib/features/phuc_ai)"]
        AI1[PhucAiBloc & ChatCubit]
        AI2[SelectionRasterizer\nIn-Memory Bounding Crop]
        AI3[NoteDocumentRetriever\nText Chunking & Citations]
        AI4[Consent & Privacy Gate]
    end

    subgraph Security_BYOK["Security & Hardware Keystore"]
        K1[flutter_secure_storage]
        K2[Android Hardware KeyStore]
        K3[User-Supplied Gemini API Key]
    end

    subgraph Cloud_AI["Official AI Integrations"]
        G1[Google AI Studio / Gemini API\nGemini 1.5/2.0 Flash & Pro]
        G2[Gemini Notebook Enterprise API\nOptional Cloud Project Adapter]
        G3[1-Tap NotebookLM Export Bridge\nMarkdown / PDF Course Sync]
    end

    U2 -->|Lasso Crop| AI2
    U3 --> AI1
    U4 --> AI1
    AI2 --> AI1
    U1 -->|Active PDF / Note Text| AI3
    AI3 --> AI1
    K3 --> K1 --> K2
    K1 --> AI1
    AI1 --> AI4
    AI4 -->|Explicit Consent| G1
    AI4 -.->|Optional Enterprise| G2
    AI1 -->|Insert to Note| U1
    AI3 -->|Course Export| G3
```

#### 4.6.1 Module Decoupling Strategy
- The extension resides in a dedicated package boundary (`lib/features/phuc_ai`).
- State is managed via `PhucAiBloc` and `ChatCubit`, keeping AI conversation history, streaming tokens, and prompt context completely isolated from `DocumentBloc` and `TransformCubit`.
- **Zero Impact on Inking:** Network I/O and streaming token decodes run asynchronously on background event loops; the inking thread on `ForegroundPainter` continues rendering at native 144Hz without frame drops.

#### 4.6.2 Multimodal Handwriting Pipeline
1. When the student makes a lasso selection, the selection handler calculates the AABB rectangle ($[x_{\min}, y_{\min}, x_{\max}, y_{\max}]$) of selected `PenElement` paths.
2. `SelectionRasterizer` renders only the selected stroke paths to an in-memory `ui.Image` with transparent padding and encodes it as a PNG byte buffer (`Uint8List`).
3. The image is passed directly into Gemini's multimodal vision API (`google_generative_ai` `Content.data('image/png', bytes)`) with prompts such as:
   - *"Transcribe and explain this handwritten derivation step-by-step."*
   - *"Check this handwritten formula or proof for mathematical errors."*
4. No temporary image files are written to disk.

#### 4.6.3 Document Retrieval & Source Citations
- For course-wide and document Q&A:
  - Text from typed text elements, markdown blocks, and PDF text streams is extracted into lightweight text chunks tagged with source coordinates:
    `[Source: Lecture_04.pdf | Page: 7 | Section: Theorem 2.1]`
  - Chunks are assembled into Gemini's multi-million token context window or indexed via local cosine similarity embeddings.
  - Responses return structured markdown citations with clickable jumping links to navigate the canvas directly to the cited page.

#### 4.6.4 Security, Consent & BYOK (Bring Your Own Key) Architecture
- **No Shared API Secrets:** The application binary contains zero hardcoded API keys.
- **BYOK Configuration:** Students provide their personal Google AI Studio API key. The key is written directly to `flutter_secure_storage`, which utilizes the **Android KeyStore** (hardware-backed TEE/StrongBox).
- **Explicit Consent Dialog:** PhucNote displays an informative modal detailing the exact payload (image preview, text excerpt) before sending data to the API.

#### 4.6.5 Gemini Notebook / NotebookLM Integration Strategy
Following an empirical investigation into Google's services:
1. **Consumer NotebookLM (gemini.google.com/notebooklm):** Has **no public developer API**. Reverse-engineered scraping scripts rely on transient cookie sessions and violate Google's Terms of Service.
   - *PhucNote Solution:* A native **"Export to NotebookLM"** bridge that bundles course notes, extracted PDF highlights, and flashcard summaries into formatted Markdown/PDF packages suitable for 1-tap Google Drive / NotebookLM import.
2. **Gemini Notebook Enterprise API:** Supported on Google Cloud for enterprise/academic domains.
   - *PhucNote Solution:* Provide an optional Enterprise Cloud Connector setting for university environments requiring managed Google Cloud project endpoints and OAuth2 credentials.
3. **Direct Gemini 1.5 / 2.0 API:** Acts as the primary in-app engine, delivering low-latency multimodal reasoning, citation generation, and canvas interaction.

#### 4.6.6 Tablet Ergonomics (Lenovo Legion Y700 Gen 4)
- **Floating Chat Window:** Compact 360×480dp draggable card with transparency controls.
- **Collapsible Side Panel:** Docks smoothly along the right edge (or left for left-handed writers) with 30/70 and 50/50 split ratios.
- **Coexistence with Floating Video:** In lecture study mode, the floating video player, canvas, and AI chat panel occupy non-overlapping layout zones in landscape orientation.

