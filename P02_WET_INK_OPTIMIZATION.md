# P0.2 wet ink assessment

Reuses the existing `IncrementalGeometry` candidate; its algorithm is unchanged.
Only benchmark repetition/trace inputs and testbed phase order were extended.
No new presets, pressure curves, schema fields or historical reinterpretation.

Predeclared gate: at least 20% lower long-prefix geometry p95, identical pixels
and canonical input, and no material p95/p99, jank or memory regression. The
10% threshold triggers investigation, not automatic approval. A1/A2 remain
isolated until the complete evidence satisfies those gates.

Three desktop matched runs use 3×256-prefix warm-up traversals, alternating
baseline/candidate path calls at each prefix (reversed on the middle repeat),
with append cost separately measured and added to candidate geometry. Lengths
128/512/2048/4096; ramp and constant .2 pressure. All p50/p95/p99 and raw values
are retained in `wet-desktop.json`. No CPU duration is called physical latency.

Long-prefix p95 baseline → A1 combined (ms), three runs:

| Input | Length | Run 0 | Run 1 | Run 2 |
|---|---|---|---|---|
| Ramp | 2048 | .820 → .543 | .787 → .495 | .808 → .468 |
| Ramp | 4096 | 1.866 → 1.444 | 1.932 → 1.236 | 1.701 → 1.008 |
| Plateau | 2048 | .826 → .500 | .807 → .485 | .837 → .489 |
| Plateau | 4096 | 1.932 → 1.124 | 1.970 → 1.467 | 1.794 → 1.164 |

Desktop long-prefix CPU gate: **PASS** (minimum improvement 22.6%). Small-prefix
ramp improvements are only 14.0–21.7%; no across-the-board 20% claim.
Expanded full-width pixel checks, including short accents, dots, late pressure,
all four modes and exact canonical prefix retention: **PASS**. Existing wet/dry
fallback/reopen/history tests remain separate. Full outline work is still O(n),
so cumulative every-prefix traversal still grows quadratically.

Profile assessment uses three independent app launches, unchanged emulator and
the same ramp workload; baseline/A1/A2 order is forward, reversed, then rotated.
The fixed dry page has 128 visible short strokes; wet transforms remain synthetic
and separate from the dry layer. This is not synchronized production transform
acceptance. Each launch also measures ramp/plateau microbenchmarks at all four
lengths, with matched warm-up/alternating calls. All runs are retained as evidence.

A2 contract inspection: HomeScreen currently uses controller notifications both
for rebuilding UI and debouncing autosave inactivity. CanvasView/Toolbar listen
to the same source; viewport, document revision and captured active style are
also read there. Suppressing broad notifications without routing autosave
activity separately would change behavior. A future narrow contract must route
wet repaint separately while preserving revision/save, toolbar, transforms,
document switch and Zen state updates. The existing shell's build counter alone
does not prove that contract.

The official [CustomPainter repaint guidance](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
supports direct Listenable repaint without build/layout. It does not supply
PHUCNOTE's autosave/state contract or certify a physical frame improvement.

Three independent profile launches: functional replay **PASS** in each.
Ramp microbenchmark long-prefix p95 improves 34.6–47.4%; plateau improves
42.0–66.2%. The geometry CPU target is reproduced, not extrapolated to latency.

Actual frame p95/p99 (ms), all runs:

| Run / phase | Active geometry | Flutter build | Raster | Total span | Jank / frames |
|---|---|---|---|---|---|
| 0 baseline | 2.473/5.309 | 5.977/12.663 | 53.359/74.580 | 96.095/110.486 | 286/286 |
| 0 A1 | .409/1.479 | 2.150/3.792 | 24.514/32.422 | 58.814/66.208 | 279/286 |
| 0 A2 | .623/2.795 | 2.389/4.484 | 24.942/28.781 | 59.574/68.396 | 285/286 |
| 1 baseline | .732/2.440 | 2.876/4.340 | 23.393/32.455 | 63.695/72.733 | 281/286 |
| 1 A1 | .598/3.653 | 2.795/6.837 | 25.816/33.968 | 62.577/74.958 | 284/286 |
| 1 A2 | .911/3.331 | 4.800/6.595 | 57.520/73.883 | 104.349/127.043 | 286/286 |
| 2 baseline | 1.655/2.368 | 3.250/5.416 | 22.978/26.262 | 59.598/66.187 | 271/286 |
| 2 A1 | 1.614/4.002 | 4.722/10.443 | 54.281/67.694 | 104.523/114.572 | 286/286 |
| 2 A2 | .679/2.527 | 2.387/4.273 | 22.787/24.755 | 56.788/69.186 | 275/286 |

Jank uses build OR raster > observed 60-Hz budget, not total span. Every p50 and
raw distribution is retained alongside these tails in `wet-profile-r0/r1/r2`.
There is strong phase-order dependence in this software-rendered emulator.
The favorable forward run does not erase the reversed/rotated regressions.
A2 reduces shell builds 287 → 1, but does not establish stable frame superiority.

End-of-phase Dart heap, baseline/A1/A2 bytes: run 0
8,570,096/11,564,336/8,561,200; run 1
8,236,960/10,539,488/8,497,680; run 2
12,463,920/9,901,568/12,833,072. PSS and raw VM responses are retained.
Sequential harness retention, GC and native/GPU state confound memory attribution;
selected-class allocation counters remain unavailable. No allocation/peak-memory
win is claimed.

**A1/A2 NOT ADOPTED: frame/memory acceptance FAIL.** No production geometry or
notification wiring changed. The renderer stays the tested fallback. A clean
autosave-aware notification contract would need dedicated integration assertions;
it is not implemented merely to force a failed performance candidate through.
Physical Y700/AP501U, end-to-end stylus latency and high refresh: **NOT EXECUTED**.
