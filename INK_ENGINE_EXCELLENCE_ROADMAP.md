# Handwriting excellence roadmap and decision gate

**Recommendation A: continue optimizing the existing Flutter/perfect_freehand
engine.** This is a measured development direction, not authorization to replace
the production editor or a claim of flagship/competitor parity. Keep A1/A2
isolated until physical and reproducibility gates pass.

## Why A, rather than an unmeasured native adoption

A1 retains tested historical preprocessing, pixels and `.bfly` appearance while
reducing long-prefix CPU work. A2 proves that a repaint-only shell can avoid
rebuilding its testbed widget; it does not prove production editor state/listeners
can be removed. Two profile runs vary substantially, including frame regressions
in the first. This is useful evidence for a narrow follow-up, not stable hardware
acceptance. Outline reconstruction still scales with the whole wet stroke.

B compiles and draws through real AndroidX Ink 1.0.0. Its native incremental
microbenchmark is promising **within its own brush/build mode**. However, native
brush shapes, float inputs and metadata differ; exact input fidelity fails, and
existing `.bfly` fields cannot reproduce the native brush at reopen. Standalone
native debug timings are not directly comparable to Flutter profile timings.
No PlatformView cost or physical Y700 benefit has been measured.

C would add input ownership, wet/dry handoff, two renderer lifecycles, transform
and persistence seams. Using native wet ink then legacy Flutter dry ink can cause
a visible geometry jump. Without a representation decision and same-device gain,
hybrid complexity is not justified. Do not mask the mismatch with automatic
reflow, modified saved coordinates or an undocumented schema extension.

## Ordered follow-up checkpoints — not implemented here

| Priority | Bounded work | Required evidence before adoption |
|---|---|---|
| P0 input fidelity | Measure native/Flutter delivery on Y700/AP501U; explicitly own the active pointer; evaluate final up sample, real pressure range and stable plateaus. | Raw traces show no lost/spurious samples; touch/stylus cancel and inverted eraser regressions; preserve original canonical input and legacy interpretation. |
| P0 reproducibility | Run A1/A2 on actual hardware at observed 60/120 Hz, reverse phase order, include 4096+ samples and multiple page densities. | At least three matched runs meet predeclared geometry/frame gates; no p95/p99 or memory regression hidden by averaging. External-camera pen-to-display evidence. |
| P1 exact-output integration | If physical gates pass, introduce append-only wet preprocessing behind a local, reversible renderer choice, with narrow repaint notification wiring. | Arbitrary prefix, duplicates, very slow/short strokes, style capture, transforms, lifecycle/document switch, undo/redo/autosave/A4/Zen and reopen all pass. Full outline remains the fidelity fallback. |
| P1 pen semantics | Resolve how new strokes specify real/simulated pressure, curves, taper and completed-tip behavior without reinterpreting old ink. | Explicit compatibility analysis/authorization. Score small Vietnamese accents, loops, formulas and caps; current taper trial is rejected for short marks. No silent metadata or pressure mutation. |
| P1 dry scaling | Profile spatial culling/bounds checks and the 128-entry cache under dense visible pages. | Measured paint/memory benefit; bounded allocations; mutable-list invalidation, identity, undo/redo and offscreen behavior retained. Do not simply enlarge cache limits. |
| P2 native/hybrid revisit | Keep the standalone spike reproducible; test prediction on/off, true stylus/palm, lifecycle and supported API matrix. | Compatible completed-stroke representation, raw canonical sample retention, no wet/dry/reopen jump, measured composition/channel cost and same-device advantage over A. |

Velocity curves require timestamps and device sampling knowledge; distance-based
simulation is not calibrated speed. Tilt/nib/calligraphy require measured axes and
quality gates, not renamed presets. Texture brushes are outside this checkpoint.

## Product quality gate

Use `PHYSICAL_STYLUS_TEST_PLAN.md` and the Vietnamese rubric. Fixed-width
Ballpoint is the current conservative synthetic small-writing reference; Gel is
fuller; Fountain shows circular pressure variation, not a true oriented nib.
No pen is called the physical Y700 winner. Require preserved diacritics, open
counters, clean corners, stable tip/caps/highlighter and zero canonical data loss.

Preserve Concept A / Academic Atelier. PDF, AI, OCR, translation, organization
and major UI development remain paused pending the handwriting roadmap decision.
No original notes, production settings, document format or existing design were
altered. Stop this checkpoint after verified research/source/evidence commit and
fast-forward push; follow-up work needs its own scope.
