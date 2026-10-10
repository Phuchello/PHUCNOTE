# PhucNote — License Audit & Compliance Review

**Project:** PhucNote  
**Repository:** [https://github.com/Phuchello/PHUCNOTE](https://github.com/Phuchello/PHUCNOTE)  
**Upstream Project:** [Linwood Butterfly](https://github.com/LinwoodDev/Butterfly)  
**Evaluated Upstream Release:** `v2.6.0` (commit `1e4c86b`)  
**Auditor:** PhucNote Architecture Team  
**Date:** 2026-10-10  

---

## 1. Executive Summary

This audit evaluates the legal framework governing the use of Linwood Butterfly source code within PhucNote. The upstream codebase is released under the **GNU Affero General Public License Version 3 (AGPL-3.0)**, with its trademarks and visual branding governed by a separate **Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)** license.

**Conclusion:**  
Using Linwood Butterfly as the foundational base for PhucNote is fully compliant and legally viable provided that:
1. PhucNote is released as open source under the **AGPL-3.0**.
2. All original Linwood copyright notices and license headers are maintained.
3. All proprietary Linwood branding, logos, trademarks, and associated names are replaced with PhucNote branding.
4. Source code modifications are documented with clear change notices.

---

## 2. Upstream License Analysis

### 2.1 GNU Affero General Public License v3.0 (AGPL-3.0)
The core software of Linwood Butterfly is licensed under AGPL-3.0. The AGPL-3.0 is a strong copyleft license designed to guarantee software freedom.

#### Key Permissions:
- **Commercial & Non-Commercial Use:** The software may be used, modified, and run freely without fee.
- **Modification & Derivation:** The codebase may be forked, refactored, extended, and incorporated into derived projects.
- **Distribution:** Binary APKs and source code may be distributed freely to end-users.

#### Key Obligations:
- **Copyleft (Reciprocity):** Derivative works or programs containing portions of the AGPL-3.0 licensed code must also be licensed under the AGPL-3.0 (Section 5c).
- **Source Code Availability:** When distributing the application (e.g., via Android APK or binary packages), the corresponding complete, machine-readable source code must be made accessible under AGPL-3.0 terms (Section 6).
- **Preservation of Notices:** All existing copyright notices, warranty disclaimers, and references to the AGPL-3.0 must be retained in all source files (Section 4 & 5a).
- **State Changes:** Any file that is modified must carry prominent notices stating that it was modified and the date of modification (Section 5a).

### 2.2 Branding License (`BRANDING_LICENSE` — CC BY-SA 4.0)
Linwood explicitly separates software copyright from branding assets via `BRANDING_LICENSE`:
- **Scope:** The Linwood name, Butterfly name, logo, iconography, splash screens, and associated trademarks are protected.
- **Requirement for Derivations:** To avoid trademark confusion and misattribution, downstream projects must **not** present themselves as official Linwood software.
- **Action for PhucNote:** All occurrences of "Linwood Butterfly", Butterfly butterfly logos, and `dev.linwood.butterfly` identifiers must be substituted with **PhucNote** trademarks, logos, and package IDs (`com.phucnote.app`).

---

## 3. Dependency License Compatibility Audit

The upstream project relies on key third-party packages in `pubspec.yaml`. All dependencies have been audited for compatibility with AGPL-3.0:

| Dependency | License | Type | Compatibility Status |
| :--- | :--- | :--- | :---: |
| **`perfect_freehand`** | MIT | Permissive | **Fully Compatible** (Permissive can be incorporated into copyleft) |
| **`pdfrx`** | MIT | Permissive | **Fully Compatible** |
| **`flutter_bloc` / `bloc`** | MIT | Permissive | **Fully Compatible** |
| **`flex_color_scheme`** | BSD-3-Clause | Permissive | **Fully Compatible** |
| **`lw_file_system` / `dart_pkgs`** | AGPL-3.0 / MIT | Copyleft / Permissive | **Fully Compatible** |
| **`path_provider`** | BSD-3-Clause | Permissive | **Fully Compatible** |
| **`archive`** | Apache 2.0 | Permissive | **Fully Compatible** with GPLv3 / AGPLv3 |
| **`crypto`** | BSD-3-Clause | Permissive | **Fully Compatible** |

**Outcome:** Zero license conflicts identified among core dependencies.

---

## 4. PhucNote Compliance Checklist

To ensure 100% compliance during all phases of development, PhucNote enforces the following protocol:

- [x] **License Selection:** PhucNote will be published under the **GNU Affero General Public License v3.0**.
- [x] **License Document:** Include the full verbatim text of the AGPL-3.0 in the repository `LICENSE` file.
- [x] **Attribution Header:** Retain upstream copyright headers:
  ```dart
  // Copyright (c) Linwood Development and contributors
  // Copyright (c) PhucNote contributors
  // Licensed under the AGPL-3.0.
  ```
- [x] **Branding Separation:**
  - App Name: `PhucNote`
  - Android Package ID: `com.phucnote.app`
  - Custom vector icons, app launcher assets, and splash animations.
- [x] **Modification Notices:** Maintain detailed modification logs in [CHANGELOG.md](CHANGELOG.md) and git commit histories.
- [x] **Public Source Access:** Host the public, verifiable source code at [https://github.com/Phuchello/PHUCNOTE](https://github.com/Phuchello/PHUCNOTE).
