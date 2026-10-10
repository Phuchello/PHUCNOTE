# PHUCNOTE — A4 Visual Acceptance Final Report

**Date:** 2026-10-10  
**Target Repository:** `Phuchello/PHUCNOTE`  
**Branch:** `develop`  
**Baseline Commit:** `af46bb30b2dbd3f81b859ccaab88ed2e7dcc11e3`  

---

## 1. Test Environment

- **Host Platform:** Windows 11
- **Flutter Version:** 3.29.3 (Channel stable)
- **Dart Version:** 3.7.2
- **Android Target Device:** `emulator-5554` (AVD `medium_tablet`)
- **Android OS / API:** Android 15 (VanillaIceCream) / API Level 35
- **ABI / System Image:** `x86_64` (Google APIs, hardware accelerated)
- **Display Resolution:** 2560 × 1600 physical pixels (320 dpi, devicePixelRatio 2.0)
- **Orientations Validated:**
  - Landscape (`user_rotation 0`, 2560 × 1600)
  - Portrait (`user_rotation 1`, 1600 × 2560; logical width 800, height 1280)

---

## 2. Visual Acceptance Checklist (V-01 through V-06)

| Test ID | Test Scenario | Orientation / Zoom | Verification Criteria | Status |
|---|---|---|---|---|
| **V-01** | Landscape at 1.0× | Landscape / 1.0× | 210:297 A4 outline rendered at $x = 840.0$; header toolbar controls visible and unobstructed; ruled lines and handwriting aligned. | **PASS** |
| **V-02** | Landscape at 0.5× | Landscape / 0.5× | Dynamic text scaling preserves readable "Page 1" label; inter-page gap line and Page 2 header visible; toolbar 50% pill active; no clipping or layout overflow. | **PASS** |
| **V-03** | Portrait with Fit-to-Width | Portrait / ~0.952× | At 1.0× unscaled, A4 width (840) exceeded portrait width (800) by 40px, clipping right border and footer. With `fitToWidth(800.0)` requested (zoom ~0.952×), entire A4 page is visible within $[0, 800]$, right border is on-screen, footer label has >20px right margin, and top toolbar remains unobstructed. | **PASS** |
| **V-04** | Portrait at 0.5× | Portrait / 0.5× | "Page 1" label legible; inter-page separator visible; Page 2 outline visible with bottom-right label; no layout overflow. | **PASS** |
| **V-05** | Page 2 & Deep Scrolling | Landscape / 1.0× | Viewport navigated downward past Page 1; inter-page divider bar clearly rendered; Page 2 handwriting properly registered and aligned. | **PASS** |
| **V-06** | Handwriting Integrity | Landscape / 1.0× & 1.5× | Full cycle verified: stroke drawing, pan/zoom transformation, eraser hit-testing with Undo/Redo, and storage save/reload with unchanged logical coordinates. | **PASS** |

---

## 3. Screenshot Evidence Artifacts

All screenshots were captured directly on Android Emulator `emulator-5554` and extracted without compression or transcoding into `artifacts/a4-visual-validation/`:

| Artifact File | Size | Description |
|---|---|---|
| `artifacts/a4-visual-validation/01_landscape_1x.png` | 62,845 bytes | Landscape 1.0× view with A4 page outline, margin rule, and handwriting |
| `artifacts/a4-visual-validation/02_landscape_0_5x.png` | 68,258 bytes | Landscape 0.5× view showing scaled A4 outline, "Page 1", and inter-page separator |
| `artifacts/a4-visual-validation/03_portrait_1x.png` | 69,030 bytes | Portrait view with fit-to-width (~0.952×) showing complete A4 page outline, legible footer, and toolbar |
| `artifacts/a4-visual-validation/04_portrait_0_5x.png` | 72,451 bytes | Portrait 0.5× layout showing Page 1, separator, Page 2 outline, and zoom pill |
| `artifacts/a4-visual-validation/05_page_2.png` | 65,754 bytes | Viewport scrolled to Page 2 showing separator and Page 2 handwriting |
| `artifacts/a4-visual-validation/06_handwriting.png` | 63,965 bytes | Post-reload canvas verifying geometric coordinates after pan/zoom/erase/undo |

---

## 4. Test Suite Execution Summary

- **Static Analysis (`flutter analyze`):**
  - Result: 0 issues found.
- **Unit & Widget Test Suites (`flutter test`):**
  - Total: 66 tests (including `test/a4_portrait_fit_test.dart` reproduction and regression tests)
  - Passed: 66
  - Failed: 0
- **Android Integration Suites (`integration_test/`):**
  - `app_test.dart` (TC-01 to TC-17): 17 passed, 0 failed
  - `landscape_visual_test.dart` (V-05, V-06): 2 passed, 0 failed
  - `portrait_visual_test.dart` (V-03, V-04): 2 passed, 0 failed
  - Total Integration Tests Passed: 21 / 21
- **Logcat Diagnostic Check (`com.phucnote.phucnote`):**
  - 0 unhandled exceptions, 0 crashes, 0 ANRs.

---

## 5. Defect Analysis & Single-Defect Repair

- **Confirmed Defect:** At portrait viewport width of 800 logical pixels, A4 guides configured with logical width 840 at $(0, 0)$ clipped the rightmost 40 pixels off-screen at $1.0\times$ zoom. The right border was not visible and the "Page 1" footer label was partially clipped by 16 pixels.
- **Root Cause:** A4 preview layout was fixed at $x \in [0, 840]$ in document coordinates without a viewport-fit mechanism for viewports narrower than A4 width.
- **Fix Implemented:**
  1. Added `CanvasController.fitToWidth(double viewportWidth)` adjusting `_zoomScale` to `(viewportWidth / a4Width).clamp(minZoom, maxZoom)` and centering `_viewportOffset.dx` to `(viewportWidth - a4Width * _zoomScale) / 2.0`, while preserving vertical offset `_viewportOffset.dy`.
  2. Extended `ToolbarWidget` with a dedicated "Fit to Width" button (`Icons.fit_screen`) visible whenever A4 guides are active.
  3. Preserved all document coordinates, stroke representations, eraser hit-testing, undo/redo history, and continuous-paper mode.
- **Verification:** Unit and integration regression tests assert full visibility of page borders and footer on an 800px portrait screen, confirmed via live emulator screenshot `03_portrait_1x.png`.

---

## 6. Known Limitations

- **Nonpersistent Visual Layout:** A4 Notebook Guides is intentionally an in-memory UI preview toggle. Continuous vertical paper and the existing `.bfly` document schema remain canonical. No schema migration or toggle state persistence was introduced, per checkpoint specification.
