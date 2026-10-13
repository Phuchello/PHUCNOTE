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

P07 compact validation evidence: p07_validation_summary.json contains actual test exits/counts,59 named Android cases (excludes teardown),54 captured screenshot count/four inspected image hashes, ADB-native provenance, public APK manifest/signature/ABI/hash and limits. Fresh independent deleg_bbcbf973 PASS in p07_audit.json, zero blockers; reviewer independently verified logs/hashes/binary. LOCAL ONLY p07_local_evidence holds raw successful/failed logs, screenshots, native JSON,2222459-byte Perfetto trace, public signer/manifest outputs and recovery helpers; do not stage it. ARM64 APK stays in build/app/outputs/flutter-apk; no distribution/signing keys. Physical acceptance/release-runtime test absent, synthetic captures are not premium handwriting certification. Own post-push exact SHA proof is local push_p07.json and .git/p0-push-records/p07.json, written after this checkpoint commit.

Prior push proof: push_p06.json records independently read-back remote/local3a790b966571b37641a479254ac7ad15251b6799 and protected branch equality. Each checkpoint's own post-push record is stored locally in .git/p0-push-records and artifacts/p0, not embedded into its self-referential commit.
