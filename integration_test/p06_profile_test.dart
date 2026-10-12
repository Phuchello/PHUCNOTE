import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_property.dart';

import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/ui/canvas_view.dart';
import '../tool/ink_benchmark/traces.dart';
import '../tool/ink_benchmark/benchmark.dart';
import '../tool/ink_benchmark/allocation_snapshot.dart';
import '../test/support/localized_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const oldProps = [
    StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 3, thinning: 0, smoothing: .5, streamline: .35),
    StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 4.5, thinning: .2, smoothing: .7, streamline: .55),
    StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 5, thinning: .8, smoothing: .55, streamline: .4),
  ];
  // Frozen rejected candidate; retained ONLY for reproducibility, not adoption.
  const newProps = [
    StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 2.8, thinning: 0, smoothing: .35, streamline: .20),
    StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 3.8, thinning: .15, smoothing: .50, streamline: .35),
    StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 4.8, thinning: .60, smoothing: .45, streamline: .30),
  ];
  const pairs = [(32, 128), (128, 512), (256, 2048), (512, 4096)];
  final basePhases = [for (final p in pairs) ...[(p.$1, p.$2, false), (p.$1, p.$2, true)]];

  testWidgets('P06 matched production CanvasView old vs new preset profile', (tester) async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    addTearDown(() async { await SystemChrome.setPreferredOrientations([]); });
    final phaseReports = <String, dynamic>{};
    for (int rep = 0; rep < 3; rep++) {
      final phases = rep == 1 ? basePhases.reversed.toList() : basePhases;
      for (final (density, wetLength, isNew) in phases) {
        final label = 'rep${rep}_${isNew ? "new" : "old"}_d${density}_w$wetLength';
        final props = isNew ? newProps : oldProps;
        final cCurve = curve(count: 128);
        final cLastX = cCurve.last.point.x;
        final cPts = cCurve.map((s) => s.point.copyWith(x: 20 + s.point.x / cLastX * 180)).toList();
        final doc = NoteDocument(strokes: List.generate(density, (i) => StrokeElement(id: 'p06_$i', points: List.of(cPts), property: props[i % 3])));
        final c = CanvasController(document: doc);
        c.setPenProperty(props[2]);
        await tester.pumpWidget(localizedApp(home: Scaffold(body: CanvasView(controller: c))));
        await tester.pumpAndSettle();
        for (int f = 0; f < 8; f++) {
          c.panViewport(const Offset(1, 1));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.runAsync(() => allocationSnapshot(phase: label, reset: true));
        final rawWet = curve(count: wetLength);
        final wLastX = rawWet.last.point.x;
        final wetPts = rawWet.map((s) => s.point.copyWith(x: 20 + s.point.x / wLastX * 180)).toList();
        final timings = <ui.FrameTiming>[];
        void onTimings(List<ui.FrameTiming> t) => timings.addAll(t);
        SchedulerBinding.instance.addTimingsCallback(onTimings);
        int nextIndex = 0;
        for (int f = 0; f < 24; f++) {
          final target = ((f + 1) * wetLength / 24).ceil();
          while (nextIndex < target && nextIndex < wetLength) {
            final pt = wetPts[nextIndex];
            final pos = c.canvasToScreen(pt.toOffset());
            final press = pt.pressure.clamp(.1, 1.0);
            if (nextIndex == 0) {
              c.handlePointerDown(PointerDownEvent(kind: PointerDeviceKind.stylus, pointer: 100, position: pos, pressure: press));
            } else {
              c.handlePointerMove(PointerMoveEvent(kind: PointerDeviceKind.stylus, pointer: 100, position: pos, pressure: press));
            }
            nextIndex++;
          }
          c.panViewport(const Offset(1, 1));
          c.zoomAt(Offset.zero, 1.001);
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.pump(const Duration(seconds: 1));
        SchedulerBinding.instance.removeTimingsCallback(onTimings);
        await tester.runAsync(() => allocationSnapshot(phase: label, reset: false));
        final finalPt = wetPts.last;
        c.handlePointerUp(PointerUpEvent(kind: PointerDeviceKind.stylus, pointer: 100, position: c.canvasToScreen(finalPt.toOffset()), pressure: finalPt.pressure.clamp(.1, 1.0)));
        await tester.pump();
        expect(timings, isNotEmpty);
        expect(c.document.strokes.length, density + 1);
        final buildMs = timings.map((t) => t.buildDuration.inMicroseconds / 1000.0).toList();
        final rasterMs = timings.map((t) => t.rasterDuration.inMicroseconds / 1000.0).toList();
        final totalMs = timings.map((t) => t.totalSpan.inMicroseconds / 1000.0).toList();
        phaseReports[label] = {
          'raw_build_ms': buildMs,
          'raw_raster_ms': rasterMs,
          'raw_total_ms': totalMs,
          'distribution': distribution(totalMs),
          'jank_60hz': timings.where((t) => t.buildDuration.inMicroseconds / 1000.0 > 1000 / 60 || t.rasterDuration.inMicroseconds / 1000.0 > 1000 / 60).length,
        };
        await tester.pumpWidget(const SizedBox.shrink());
        c.dispose();
      }
    }
    expect(phaseReports.length, 24);
    binding.reportData = {
      'phases': phaseReports,
      'environment': {'type': 'synthetic_emulator', 'physical': 'NOT_EXECUTED'},
    };
  }, timeout: const Timeout(Duration(minutes: 10)));
}
