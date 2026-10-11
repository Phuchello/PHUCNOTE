# P0.2 dense committed-ink cache

Baseline: a02a78e. The original algorithm is frozen in
`tool/ink_benchmark/p02_baseline_cache.dart`. Same identity keys, mutable-point
snapshots, bounds culling, renderer and 128-entry / 20,000-point budgets are used.

Confirmed defect: sequential LRU access to a visible working set larger than
capacity evicts each upcoming hit. The pre-fix 256-stroke regression fails
(`cache-before.log`). Previously measured over-capacity paint was slower than
uncached paint; raising capacity is not a correction.

Candidate: protect already-cached visible entries for one synchronous paint.
Misses admit into free/offscreen capacity, or use the unchanged uncached renderer
without displacing that visible working set. Every stroke still draws in document
order. Mutation continues to validate exact point-object snapshots. A fast path
skips the extra protection scan when the entire document is already cached.
Entries/points and the extra identity set remain bounded; native Path bytes are
not claimed as precisely measured by the logical point budget.

The first protection-only candidate regressed small pages; its distributions
are retained in `cache-desktop-protect-all.json`. The first complete measurement
also exceeded the test harness's default 30-second timeout; that failed attempt
is retained separately, not counted as a passed test. An explicit three-minute
test timeout covers the approximately one-minute matrix. No SDK was changed.

Final desktop matrix: three matched repetitions, reversed variant order in the
middle run, 32/128/256/512 strokes × 32/128/512 points; 5 warm-up and 24 measured
frames per variant. Identical-frame pairs, panning and zooming are included.
Raw p50/p95/p99, all samples, hits/misses/evictions/bypasses and retained counts
are in `artifacts/p02-ink-hardening/cache-desktop.json`.

For 128-point strokes, baseline → candidate p95 (ms), runs 0/1/2:

| Visible strokes | Run 0 | Run 1 | Run 2 |
|---|---|---|---|
| 32 | .114 → .157 | .177 → .100 | .194 → .137 |
| 128 | .196 → .180 | .285 → .232 | .201 → .284 |
| 256 | 17.758 → 9.532 | 18.253 → 9.301 | 18.475 → 9.020 |
| 512 | 33.965 → 25.054 | 33.136 → 25.976 | 31.649 → 24.430 |

Small-page unfavorable tails are explicit investigation items, not an automatic
pass. At 256 visible 128-point strokes, steady cache hits increase from 0 to 128 per frame;
over the 29-frame capture, evictions fall 7,296 → 128 (initial admission only).
At 512 strokes, evictions fall 14,720 → 384. No capacity increase occurred.

Exact-pixel comparison of all four existing pen modes, every existing synthetic
catalog pattern, `.bfly` reopen and repeated identical rendering: **PASS**.
Mutation, undo/redo ordering, identity/document clear, offscreen pan, zoom and
long-stroke budget bypass assertions: **PASS**. The before/after PNGs were both
inspected; row order is Ballpoint, Gel, Fountain, Highlighter. Existing fountain
blobs and dense overlapping-highlighter darkening are preserved, not beautified.

Three matched profile repetitions: functional replay **PASS**, performance gate
**FAIL**. At 128 strokes in reversed run 1, raster p95/p99 worsen
53.458/62.396 → 66.009/102.729 ms, total p95/p99 worsen
97.918/107.021 → 113.072/150.753 ms, jank 68/72 → 72/72. At 256 strokes,
run 0 raster p99 worsens 60.147 → 101.212 ms despite much lower paint CPU.
All runs and heap/PSS are retained in `cache-profile/`; snapshots vary with
phase order, retained harness data, native/GPU state and GC, and do not establish
a safe memory advantage. The 512-stroke distributed profile partly culls ink;
the desktop workload has all 512 visible. No supplementary adoption run was
made after the candidate failed, as required by the stop rule.

**NOT ADOPTED.** Production cache and painter were restored exactly to a02a78e.
The tested admission algorithm remains isolated in `p02_candidate_cache.dart`;
the small testbed wrapper prepares its frame before calling the unchanged
production painter. The originally measured temporary production patch is
preserved as evidence. The known production dense-cache thrash remains unresolved.
Physical Y700/AP501U: **NOT EXECUTED**.
