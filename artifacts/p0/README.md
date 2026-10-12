# P0 synthetic pen replay

pen_before_after.png is actual Flutter StrokeGeometry output, not a mockup.
SHA256: f730145edf61adad0477773cf1c005e5ea94573898cc5abaa18f76be23acad8a
Size: 249870 bytes. Image: 1980 x1870.
Columns: baseline/rejected-candidate Ballpoint, baseline/rejected-candidate Gel, baseline/rejected-candidate Fountain. Candidate numbers are frozen TEST-ONLY after P06 rejection; NOT production defaults.
Rows: traceCatalog() order (15 patterns), then acute/grave/hook/tilde/dot and breve/circumflex/horn/crossed-d components (17 rows total, 102 cells).
Reproduce: flutter test --no-pub test/p04_visual_test.dart
Raw pen_traces.json is generated locally (336341 bytes); source fixture is the authoritative reproducible input. Do not equate synthetic marks with human handwriting or physical pressure/latency evidence.
See P0_HANDWRITING_QUALITY_REPORT.md for limits and engine audit.

P06 compact actual profile evidence: p06_profile_summary.json. Three matched/reversed repeats,24 phases, per-phase p50/p95/p99/jank/heap/PSS, rejected-candidate verdict and allocation errors. Raw artifacts external: C:/Users/lyle3/AppData/Local/hermes/cache/scratch/phucnote-p0/p06-profile. Reproduce with flutter drive --no-pub --profile --target integration_test/p06_profile_test.dart --driver test_driver/ink_engine_driver.dart -d emulator-5554 (INK_PHASE_COUNT=24 and INK_OUTPUT_DIRECTORY set externally). Do not equate harness exit0 with candidate acceptance.

Accepted baseline CPU matrix: flutter test --no-pub test/p06_cpu_test.dart --dart-define=P06_MEASURE=true.45 geometry runs (three pens x five lengths x three repeats) and72 cached/uncached density phases;24 raw samples per phase. Local-only generated cpu_baseline.json includes raw distributions. Existing128-entry cache still thrashes at256/512 visible strokes; no renderer/cache candidate adopted. Neither CPU nor emulator proves physical latency or handwriting quality.
