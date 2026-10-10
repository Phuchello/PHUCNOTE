# PhucNote — Test Report

## Test Strategy & Protocol
All features implemented must be validated with reproducible tests. No feature will be claimed functional without documented test passes.

### Planned Test Suites
1. **Input & Latency Suite**
   - Active stylus touch vs finger touch distinction (`PointerDeviceKind.stylus` vs `.touch`).
   - Palm rejection accuracy: palm resting on surface while writing.
   - Barrel button actuation: toggle eraser or lasso selection.
   - Multi-touch gesture navigation (two-finger pinch-to-zoom and pan) while palm rejection is active.
2. **Display & Split-Screen Suite**
   - Portrait orientation (full screen, split top/bottom).
   - Landscape orientation (full screen, split left/right with YouTube / browser).
   - Dynamic window resizing without losing canvas state or stroke buffer.
   - 144Hz high refresh rate rendering stability.
3. **Canvas & Paper Template Suite**
   - Infinite 2D freeform canvas navigation and baking.
   - Continuous vertical paper scrolling and boundary snapping.
   - A4 fixed page aspect ratio notebooks.
   - Dark mode paper and light mode paper rendering.
4. **PDF Engine Suite**
   - Import of standard and large (50+ pages) PDF documents.
   - Annotation fidelity: vector ink overlay accuracy on zoom.
   - Dark mode PDF color inversion.
   - Export to PDF at 1:1 scale with preserved vector paths.
5. **Data Safety & Persistence Suite**
   - Continuous autosave test during rapid writing.
   - Forced process kill / OS restart recovery verification.
   - File integrity validation of `.bfly` archives.
   - Complete offline functionality with airplane mode enabled.
6. **Video Study Workflow Suite**
   - Floating video player overlay drag, resize, and playback.
   - In-app video playback concurrent with real-time ink drawing without frame drops or touch contention.

---

## Test Execution Log
| Date | Test Case ID | Description | Environment | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 2026-10-10 | TC-AUDIT-01 | Upstream codebase verification | Ubuntu 26.04 | PASS | Clean git clone of Linwood Butterfly v2.6.0; verified module structure, pubspec dependencies, and assets. |
| 2026-10-10 | TC-AUDIT-02 | License & compliance check | Filesystem | PASS | AGPL-3.0 and CC BY-SA 4.0 branding boundaries established. |
| 2026-10-10 | TC-AUDIT-03 | Engine & input architecture check | Code Inspection | PASS | Verified `perfect_freehand` stroke generation, `_ViewportInputCoordinator` stylus detection, and `.bfly` serialization. |
