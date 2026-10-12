# P0 synthetic pen replay

pen_before_after.png is actual Flutter StrokeGeometry output, not a mockup.
SHA256: f730145edf61adad0477773cf1c005e5ea94573898cc5abaa18f76be23acad8a
Size: 249870 bytes. Image: 1980 x1870.
Columns: old/new Ballpoint, old/new Gel, old/new Fountain.
Rows: traceCatalog() order (15 patterns), then acute/grave/hook/tilde/dot and breve/circumflex/horn/crossed-d components (17 rows total, 102 cells).
Reproduce: flutter test --no-pub test/p04_visual_test.dart
Raw pen_traces.json is generated locally (336341 bytes); source fixture is the authoritative reproducible input. Do not equate synthetic marks with human handwriting or physical pressure/latency evidence.
See P0_HANDWRITING_QUALITY_REPORT.md for limits and engine audit.
