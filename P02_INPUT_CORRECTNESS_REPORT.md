# P0.2 input correctness

Baseline: `a02a78ec6bc4cf703c20a6da93341108fbb2f0ba`, develop, clean.
CP-A reproduces nine failing cases before repair (`input-before.log`), then
passes all 142 current unit/widget tests (`cp-a-tests.log`).

The controller previously accepted move/up/cancel by kind, without pointer
ownership; a second down could replace active ink. It also omitted the UP
location, and document/navigation resets could leave the stylus-active flag set.
The minimal correction stores the initiating ID/kind and last accepted timestamp.
Other pointers, duplicate downs and older events cannot mutate, finish or cancel
that gesture. Missing-down and post-completion events are inert. Explicit
navigation cancellation and document switching release ownership. Eraser
cancellation retains its existing undoable action.

New ink intentionally differs: when an owned UP has a distinct, finite document
position, it appends that actual location using the last accepted pressure/tilt.
Identical UP coordinates do not duplicate the terminal point. Default zero UP
axes cannot create a new pressure transition. Existing caps, completion,
smoothing and pressure interpretation are unchanged; saved strokes are untouched.
This fixes coordinate capture, not the legacy trailing-tip algorithm.

The first accepted writing pointer retains ownership, including finger ink;
a stylus cannot preempt it. The existing tracked-touch cancellation regression
now establishes that touch as navigation, preserving the intended adversarial
tracked-touch/stylus case without permitting ownership theft. New tests separately
cover an already-writing finger. Synthetic style tests now release at their
actual last location instead of an implicit screen origin. Old audit assertions
are updated only for the intentional new UP-capture behavior.

INPUT-01 through INPUT-08: **PASS** in focused synthetic tests. Coverage includes
second stylus/inverted stylus/touch interference, tap, rapid lift, zero pressure,
pan/zoom coordinates, timestamp ordering, duplicate release, genuine cancel,
inverted erasing, undo/redo, finger writing and two-finger navigation.
Physical Y700/AP501U palm, pressure and missing-event behavior: **NOT EXECUTED**.
A missing release cannot be inferred safely; ownership persists until an explicit
cancel/navigation reset/document switch. No native production input path added.

Final validation: 147 unit/widget tests PASS (two measurement-only cases executed
separately), 47/47 combined Android regression cases PASS and analyzer clean.
The initial native diagnostic capture failure and passing recheck are disclosed
in `P02_REGRESSION_REPORT.md`; none of the pointer assertions were relaxed.
