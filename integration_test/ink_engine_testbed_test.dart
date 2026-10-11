import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/stroke_path_cache.dart';
import 'package:phucnote/drawing/view_painter.dart';

import '../tool/ink_benchmark/allocation_snapshot.dart';
import '../tool/ink_benchmark/benchmark.dart';
import '../tool/ink_benchmark/incremental_geometry.dart';
import '../tool/ink_benchmark/traces.dart';

class _Replay extends ChangeNotifier {
  final String phase;
  final points = <StrokePoint>[];
  final candidate = IncrementalGeometry(PenPreset.defaults.last.property);
  Offset offset = Offset.zero;
  double zoom = 1;
  int builds = 0;
  int paints = 0;
  final cpu = <double>[];
  _Replay(this.phase);
  void add(StrokePoint point) {
    points.add(point);
    if (phase != 'baseline') candidate.append(point);
  }

  void update() => notifyListeners();
}

class _WetPainter extends CustomPainter {
  final _Replay replay;
  _WetPainter(this.replay, {bool repaintOnly = false})
    : super(repaint: repaintOnly ? replay : null);
  @override
  void paint(Canvas canvas, Size size) {
    final watch = Stopwatch()..start();
    final path = replay.phase == 'baseline'
        ? StrokeGeometry.generatePath(
            replay.points,
            PenPreset.defaults.last.property,
          )
        : replay.candidate.path();
    watch.stop();
    replay.cpu.add(watch.elapsedMicroseconds / 1000);
    replay.paints++;
    canvas.save();
    canvas.translate(replay.offset.dx, replay.offset.dy);
    canvas.scale(replay.zoom);
    canvas.drawPath(path, Paint()..color = const Color(0xFF1565C0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WetPainter oldDelegate) => true;
}

Widget _shell(_Replay replay, NoteDocument document, StrokePathCache cache) {
  Widget layers() => Stack(
    fit: StackFit.expand,
    children: [
      RepaintBoundary(
        child: CustomPaint(
          painter: PhucNoteViewPainter(
            document: document,
            backgroundColor: const Color(0xFFFAFAFA),
            repaintCounter: 0,
            strokeCache: cache,
          ),
        ),
      ),
      RepaintBoundary(
        child: CustomPaint(
          painter: _WetPainter(
            replay,
            repaintOnly: replay.phase == 'a2_repaint',
          ),
        ),
      ),
    ],
  );
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('PHUCNOTE Ink Testbed · ${replay.phase} · synthetic'),
      ),
      body: replay.phase == 'a2_repaint'
          ? Builder(
              builder: (_) {
                replay.builds++;
                return layers();
              },
            )
          : ListenableBuilder(
              listenable: replay,
              builder: (_, _) {
                replay.builds++;
                return layers();
              },
            ),
    ),
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Isolated baseline A1 A2 profile replay and geometry measurements',
    (tester) async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
      ]);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await SystemChrome.setPreferredOrientations([]);
      });
      final phases = <Map<String, Object?>>[];
      // Same fixed dry page and point trace in all three phases. A2 alone changes
      // notification-to-widget wiring; A1 only changes wet preprocessing.
      final document = NoteDocument(
        strokes: [
          for (var i = 0; i < 32; i++)
            StrokeElement(
              id: 'fixed_$i',
              points: [
                for (final s in curve(count: 64))
                  s.point.copyWith(
                    x: s.point.x + (i % 8) * 140,
                    y: s.point.y + (i ~/ 8) * 110,
                  ),
              ],
              property: PenPreset.defaults.first.property,
            ),
        ],
      );
      for (final phase in ['baseline', 'a1_incremental', 'a2_repaint']) {
        final replay = _Replay(phase);
        await tester.pumpWidget(_shell(replay, document, StrokePathCache()));
        await tester.pumpAndSettle();
        final before = await tester.runAsync(
          () => allocationSnapshot(phase: phase, reset: true),
        );
        final frames = <ui.FrameTiming>[];
        void record(List<ui.FrameTiming> batch) => frames.addAll(batch);
        SchedulerBinding.instance.addTimingsCallback(record);
        final source = curve(count: 1024, ramp: true);
        final processing = <double>[];
        for (var i = 0; i < source.length; i += 4) {
          final watch = Stopwatch()..start();
          for (final s in source.skip(i).take(4)) {
            replay.add(s.point);
          }
          replay.offset = Offset(i.isEven ? 1 : -1, 10);
          replay.zoom = i >= 512 ? 1.1 : 1;
          replay.update();
          watch.stop();
          processing.add(watch.elapsedMicroseconds / 1000);
          await tester.pump(const Duration(milliseconds: 17));
        }
        // Extra transforms with unchanged input expose reusable wet geometry.
        final activePaintCount = replay.cpu.length;
        for (var i = 0; i < 30; i++) {
          replay.offset = Offset(i.isEven ? 4 : -4, 10);
          replay.update();
          await tester.pump(const Duration(milliseconds: 17));
        }
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 1)),
        );
        SchedulerBinding.instance.removeTimingsCallback(record);
        final after = await tester.runAsync(
          () => allocationSnapshot(phase: phase),
        );
        phases.add({
          'phase': phase,
          'inputCount': replay.points.length,
          'builds': replay.builds,
          'paints': replay.paints,
          'geometryCalls': phase == 'baseline'
              ? replay.paints
              : replay.candidate.geometryCalls,
          'inputProcessingMs': distribution(processing),
          'activeGeometryMs': distribution(
            replay.cpu.take(activePaintCount).toList(),
          ),
          'transformGeometryMs': distribution(
            replay.cpu.skip(activePaintCount).toList(),
          ),
          'rawGeometryMs': replay.cpu,
          'memoryBefore': before,
          'memoryAfter': after,
          'frames': [
            for (final f in frames)
              {
                'buildMs': f.buildDuration.inMicroseconds / 1000,
                'rasterMs': f.rasterDuration.inMicroseconds / 1000,
                'totalMs': f.totalSpan.inMicroseconds / 1000,
              },
          ],
          'buildMs': distribution(
            frames.map((f) => f.buildDuration.inMicroseconds / 1000).toList(),
          ),
          'rasterMs': distribution(
            frames.map((f) => f.rasterDuration.inMicroseconds / 1000).toList(),
          ),
          'totalMs': distribution(
            frames.map((f) => f.totalSpan.inMicroseconds / 1000).toList(),
          ),
        });
        expect(replay.points.length, 1024);
        expect(
          replay.points.map((p) => p.toJson()),
          source.map((s) => s.point.toJson()),
        );
        if (phase == 'a2_repaint') expect(replay.builds, 1);
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('ink_$phase');
        await tester.pumpWidget(const SizedBox.shrink());
        replay.dispose();
      }
      final controller = CanvasController();
      final controllerTimes = <double>[];
      controller.handlePointerDown(
        const PointerDownEvent(
          kind: PointerDeviceKind.stylus,
          position: Offset(20, 70),
          pressure: .1,
        ),
      );
      for (final s in curve(count: 1024, ramp: true)) {
        final watch = Stopwatch()..start();
        controller.handlePointerMove(
          PointerMoveEvent(
            kind: PointerDeviceKind.stylus,
            position: s.point.toOffset(),
            pressure: s.point.pressure,
            tilt: s.point.tilt,
          ),
        );
        watch.stop();
        controllerTimes.add(watch.elapsedMicroseconds / 1000);
      }
      controller.handlePointerUp(
        const PointerUpEvent(kind: PointerDeviceKind.stylus),
      );
      expect(controller.document.strokes.single.points.length, 1025);
      controller.dispose();
      final geometry = geometryBenchmark(lengths: const [128, 512, 2048]);
      binding.reportData = {
        ...?binding.reportData,
        'environment':
            'medium_tablet Android 15; profile; synthetic, no physical Y700',
        'phases': phases,
        'geometry': geometry,
        'controllerInputMs': distribution(controllerTimes),
        'trace': catalogJson(),
      };
      expect(tester.takeException(), isNull);
    },
  );
}
