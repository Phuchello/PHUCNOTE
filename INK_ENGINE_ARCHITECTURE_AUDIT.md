# PHUCNOTE ink architecture audit

2026-10-11. Independent source audit and executable probes, starting at clean
`develop` / `daedb6971073b0aeb9347f7e567458d274337e4a`. Requested `1087b5e` is its
ancestor. No production files, existing document data or schema changed here.
Concept A / Academic Atelier remains the accepted design direction.

## Input to display

`CanvasView` receives Flutter pointer events, arbitrates touch/stylus and maps
navigation gestures. `CanvasController` converts local positions into global
document coordinates, holds active samples and freezes the property at down.
Controller notifications rebuild listenable editor/toolbar/canvas portions.
ForegroundPainter runs `StrokeGeometry.generatePath` on the active prefix at
paint time. ViewPainter handles paper/A4 and committed ink in a separate
RepaintBoundary, with viewport culling and the existing bounded path cache.
Pointer up creates one AddStrokeAction; revision tracking drives the existing
serialized autosave. Save/reopen uses the existing `.bfly` serializer.

Important distinction: geometry runs on **paint**, not directly on every pointer
event. Several pointer moves may arrive before a frame. Every growing prefix
paint still revisits the accumulated points; it is incorrect to describe the
production engine as necessarily tessellating once for every hardware sample.

## Findings and classification

| Area | Confirmed source / regression evidence | Classification and implication |
|---|---|---|
| A: Sampling | Controller appends each accepted Flutter down/move; it does not directly ingest Android MotionEvent history or prediction. Pointer-up position is not appended. Timestamps/orientation/tool provenance are absent from StrokePoint. | Confirmed behavior. Raw Android sampling/historical delivery on AP501U is unmeasured. Lift-off position may be missed if it differs from the last move; add a targeted next-checkpoint input repair before changing geometry. |
| B: Pressure | Down/move clamp event pressure to `.1..1`, ignoring pressureMin/Max. Geometry selects simulation unless any pressure differs from the first by more than `.01`. A real `.2` plateau rasterizes exactly like simulated pressure, and differently from explicit real pressure. | Confirmed pressure interpretation defect. Light pressure is floored, and a late varying sample can switch the interpretation of the whole wet prefix. There is no reliable hardware-capability discriminator in saved data. No production correction under this schema freeze. |
| C: Tilt | Tilt is stored, serialized and reopened; `toFreehandPoint` passes only x/y/pressure. Changing tilt alone leaves pixels unchanged. | Confirmed unused rendering input, not evidence of hardware tilt support. Existing fountain preset is circular pressure variation, not an oriented physical nib. |
| D: Smoothing | Streamline preprocesses point positions; smoothing controls outline spacing. Equal coordinates sampled at slow/fast synthetic timestamps render identically. Simulated pressure responds to inter-point distance, not actual elapsed time. | Confirmed algorithm semantics. Greater stabilization can round corners/trail the tip; physical lag remains unmeasured. No arbitrary filtering added. |
| E/I: Live cost | Full PointVector conversion, pressure scan, batch preprocessing, outline generation and Path construction happen for the active prefix. `activePoints` also returns a new unmodifiable list. | Confirmed O(n) work per growing-prefix paint; O(n²) cumulative traversal when painting every prefix. This is structural and reproduced at 128/512/2048/4096 samples, not a hardware latency claim. |
| F/J: Wet/dry and caps | Both painters call the same geometry function/property. Package default `isComplete=false` is used for both. Single-point accents are circles of width/2 independent of pressure; default caps are round and taper is disabled. | Already consistent for unchanged inputs. The final tip intentionally trails by package semantics. Turning on completed-tip/taper alters historical pixels; short-mark taper trials are visibly worse. Antialiasing follows Flutter Paint defaults; no physical sharpness certification. |
| G: Dry cache | View-local identity LRU, 128 entries / 20,000 stored points. Snapshot comparison detects mutation; large strokes bypass it. Cache is cleared on document identity change. | Already implemented in preceding checkpoint. Within capacity, viewport paint reuses paths. Over-capacity sequential access can thrash, regenerating all visible paths. Point equality/bounds checks remain O(n), and Path/native bytes are not covered by the point budget. |
| H: Repaint isolation | Separate dry/wet RepaintBoundaries; dry shouldRepaint ignores active moves while revision/viewport/style changes repaint it. CanvasView, HomeScreen's listenable editor and ToolbarWidget still listen to the same controller. | Good paint isolation; broad rebuild/list allocation is a confirmed cost opportunity. Rebuild count does not itself establish a layout or raster improvement. Isolated A2 removes testbed builds, but frame acceptance is separately measured. |
| K: Palm/finger | Stylus-only rejects touch ink; active stylus suppresses touch; contact-size heuristics exist. Previous repair prevents independent touch up/cancel terminating stylus. Genuine stylus cancel discards provisional pen input; erased strokes still receive undo history. | Existing synthetic regressions pass. Contact thresholds are heuristics, not AP501U palm certification. Controller has no explicit active-pointer ID ownership; unusual second stylus/pointer sequences are a risk requiring device evidence. |
| L: Coordinates | `(screen-offset)/zoom` and inverse transform; foreground/dry canvas apply offset and scale to points and widths together. A4 only gates initiation; accepted cross-boundary samples remain global. | Already correct under existing tests. No reflow, clipping/deletion or coordinate modification introduced. Zoom changes apparent width consistently with document scale. |
| M: Compatibility | Existing x/y/pressure/tilt and color/width/thinning/smoothing/streamline/highlighter/opacity round-trip. Legacy defaults remain. Active property is captured at down; undo/redo retain exact stroke objects/styles. | Already correct under regression tests. No schema changes. Native brush family/version, timing, orientation, physical scale, taper/curve/completion discriminators and mesh are not represented. |

Highlighter uses a `.35` alpha and multiply blend; separate strokes overlap darker
in the inspected comparison, as expected for the current renderer. The opacity
field is retained but highlighter rendering fixes its alpha. A chisel nib or
self-overlap policy is a distinct behavior, not an existing PHUCNOTE feature.

## Source map

- [Controller](lib/drawing/canvas_controller.dart): active sample getter, down/move
  clamp, captured style, pointer-up, cancel, transforms, history and revisions.
- [Geometry](lib/drawing/stroke_geometry.dart): full batch, pressure heuristic,
  dot/outline and quadratic path closure.
- [Wet painter](lib/drawing/foreground_painter.dart),
  [dry painter](lib/drawing/view_painter.dart),
  [cache](lib/drawing/stroke_path_cache.dart),
  [canvas](lib/ui/canvas_view.dart): scheduling, paint/rebuild isolation and cache.
- [Point](lib/core/models/stroke_point.dart),
  [property](lib/core/models/stroke_property.dart),
  [presets](lib/core/models/pen_preset.dart): exact existing data contract.
- [Focused probes](test/ink_engine_benchmark_test.dart) and
  [isolated profile replay](integration_test/ink_engine_testbed_test.dart).

The installed **perfect_freehand 2.5.2+1** source is the authority for this audit:
`get_stroke_points.dart` has two-point interpolation, provisional final-point
minimum-length handling and sequential streamline state;
`get_stroke_outline_points.dart` has pressure/joins/caps and a full outline pass;
`types/stroke_options.dart` defaults completion to false. The public package
table's completion default differs from the installed source, so the source
and tests take precedence. [Versioned package](https://pub.dev/packages/perfect_freehand/versions/2.5.2+1),
[maintainer source](https://github.com/steveruizok/perfect-freehand-dart).

## Controlled candidates

A1 caches append-only preprocessing while rebuilding the provisional tail and
full outline. It explicitly handles one/two-point special cases, duplicates,
minimum-length gating and late pressure variation. The MIT attribution is
preserved. It deliberately retains the legacy pressure heuristic and incomplete
tip: changing them would invalidate old geometry. Prefix/preprocessed values,
pixels, memoization and reopen equivalence are tested. It still allocates outlines
and Paths; cumulative outline work is still quadratic. No chunked-path seams,
compression or mutation of canonical inputs are used.

A2 is a repaint-only shell, independently compared after A1. It is not an editor
replacement and does not demonstrate that HomeScreen autosave/listeners can simply
be disconnected. Production adoption needs a narrow notification contract and
all editor regressions. See [measured results](INK_ENGINE_A_B_RESULTS.md).

The profile testbed transforms only the wet layer; the dry page remains at
identity. Its timings exercise synthetic wet-layer viewport work, not
synchronized production pan/zoom or dry-page transform acceptance. Existing
production coordinate regressions are a separate gate.

Pressure gamma, real-pressure selection, completed-tip and short taper are
session-only visual trials. Ballpoint remains fixed width; gel remains round,
fuller ink; fountain remains pressure-based circular geometry. No calligraphy,
brush textures or proprietary algorithms are introduced.

## Native feasibility and integration limits

Stable AndroidX Ink **1.0.0** was pinned in an isolated Android package. The exact
authoring AAR requires minSdk 23, compileSdk 35 and AGP 8.6+; the installed
AGP 9.1 / Kotlin 2.4 / JDK 17 / SDK 36 build meets them. No production dependency
changed. [Stable AAR](https://dl.google.com/dl/android/maven2/androidx/ink/ink-authoring-android/1.0.0/ink-authoring-android-1.0.0.aar),
[setup](https://developer.android.com/develop/ui/views/touch-and-input/stylus-input/ink-api-setup).

The spike uses InProgressStrokesView, fixed V1 marker/pressure brushes,
MotionEvent history, optional predictor, and same-run-loop wet-to-dry handoff via
CanvasStrokeRenderer. A native InProgressStroke benchmark queues only new inputs.
These APIs were checked against stable source archives rather than inconsistent
guide snippets. Historical support and prediction are capabilities; neither
proves that AP501U provides useful axes or that predictions improve its writing.
[Authoring source](https://dl.google.com/dl/android/maven2/androidx/ink/ink-authoring-android/1.0.0/ink-authoring-android-1.0.0-sources.jar),
[strokes source](https://dl.google.com/dl/android/maven2/androidx/ink/ink-strokes-android/1.0.0/ink-strokes-android-1.0.0-sources.jar),
[drawing guide](https://developer.android.com/develop/ui/views/touch-and-input/stylus-input/ink-api-draw-stroke).

The smoke cancels directly through the authoring API using a DOWN event, and
pauses/resumes only after completed-ink handoff. It does not exercise the
ACTION_CANCEL handler, FLAG_CANCELED, multitouch ownership or active-stroke
lifecycle cancellation. The spike's ACTION_UP handler currently ignores
FLAG_CANCELED. These limits block input/lifecycle acceptance of a native adapter.
Preview Canvas scaling and CanvasStrokeRenderer transform metadata are matched;
the regenerated screenshot was inspected after that isolated correction.

Source selects SurfaceControl/CanvasBufferedRenderer on API 33+, front-buffer
Canvas helper on API 29–32 and Canvas fallback below. Its SurfaceView is on top;
this matters for Flutter clipping and toolbar/Zen overlays. Stable release notes
list an API 29–32 detach/reattach issue fixed in a later alpha. Android 15 smoke
does not certify all supported devices. [Release notes](https://developer.android.com/jetpack/androidx/releases/ink).

PlatformView composition can add texture/composition cost; hybrid composition
trades Flutter throughput against native view fidelity. Experimental HCPP has
API/Vulkan requirements, and this software-rendered emulator cannot certify it.
Platform channels serialize/asynchronously transfer data; per-sample crossings
and UI-thread ownership need measurement. **No PlatformView/channel overhead was
measured in this standalone spike.** [Flutter platform views](https://docs.flutter.dev/platform-integration/android/platform-views),
[channels](https://docs.flutter.dev/platform-integration/platform-channels).

A safe future native adapter must own native input/viewport transforms, preserve
raw canonical samples, exclude predictions from saves, perform atomic completed
handoff and support document switching/disposal. Mapping raw points to existing
StrokeProperty is insufficient to recreate native geometry at dry handoff or
reopen. Exporting native brush/meshes would extend the schema and is blocked here.
The spike also detects small native input-coordinate differences; it must not
replace canonical `.bfly` coordinates. Retain legacy Flutter dry rendering until
an explicit compatibility decision and same-device advantage are demonstrated.
