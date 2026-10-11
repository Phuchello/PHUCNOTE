import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/view_painter.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';

import 'support/y700_trace.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const phase = String.fromEnvironment('INK_PHASE', defaultValue: 'baseline');
  testWidgets('Synthetic dense ink profile ($phase)', (tester) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    final directory = await Directory.systemTemp.createTemp('y700_profile_');
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await directory.delete(recursive: true);
      await SystemChrome.setPreferredOrientations([]);
    });
    await tester.pumpWidget(
      PhucNoteApp(noteStorage: NoteStorage(customRootDirectory: directory)),
    );
    await tester.pumpAndSettle();
    final controller = tester
        .widget<CanvasView>(find.byType(CanvasView))
        .controller;
    controller.setDocument(denseDocument());
    await tester.pumpAndSettle();
    final paints = <double>[];
    final frames = <ui.FrameTiming>[];
    void timings(List<ui.FrameTiming> batch) => frames.addAll(batch);
    SchedulerBinding.instance.addTimingsCallback(timings);
    for (var i = 0; i < 80; i++) {
      controller.panViewport(Offset(i.isEven ? 1 : -1, 0));
      await tester.pump(const Duration(milliseconds: 17));
      final painter = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(CanvasView),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((w) => w.painter)
          .whereType<PhucNoteViewPainter>()
          .single;
      final recorder = ui.PictureRecorder();
      final watch = Stopwatch()..start();
      painter.paint(Canvas(recorder), const Size(900, 600));
      final picture = recorder.endRecording();
      watch.stop();
      picture.dispose();
      if (i >= 10) paints.add(watch.elapsedMicroseconds / 1000);
    }
    final active = <double>[];
    controller.handlePointerDown(
      const PointerDownEvent(
        kind: PointerDeviceKind.stylus,
        position: Offset(100, 500),
        pressure: 0.15,
      ),
    );
    for (final p in loopTrace(count: 240, x: 100, y: 500)) {
      controller.handlePointerMove(
        PointerMoveEvent(
          kind: PointerDeviceKind.stylus,
          position: p.toOffset(),
          pressure: p.pressure,
        ),
      );
      final watch = Stopwatch()..start();
      StrokeGeometry.generatePath(
        controller.activePoints,
        controller.activeProperty,
      );
      watch.stop();
      active.add(watch.elapsedMicroseconds / 1000);
      await tester.pump(const Duration(milliseconds: 17));
    }
    controller.handlePointerUp(
      PointerUpEvent(
        kind: PointerDeviceKind.stylus,
        position: controller.canvasToScreen(
          controller.activePoints.last.toOffset(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Flutter batches timings in profile mode. Wait without adding measured work.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    SchedulerBinding.instance.removeTimingsCallback(timings);
    binding.reportData = {
      'phase': phase,
      'hardware': 'synthetic replay; physical Y700/AP501U NOT EXECUTED',
      'trace': denseDocument().toJson(),
      'paintCpuMs': summarize(paints),
      'activeGeometryCpuMs': summarize(active),
      'frames': [
        for (final f in frames)
          {
            'buildMs': f.buildDuration.inMicroseconds / 1000,
            'rasterMs': f.rasterDuration.inMicroseconds / 1000,
            'totalMs': f.totalSpan.inMicroseconds / 1000,
          },
      ],
      'frameBuildMs': summarize(
        frames.map((f) => f.buildDuration.inMicroseconds / 1000).toList(),
      ),
      'frameRasterMs': summarize(
        frames.map((f) => f.rasterDuration.inMicroseconds / 1000).toList(),
      ),
      'frameTotalMs': summarize(
        frames.map((f) => f.totalSpan.inMicroseconds / 1000).toList(),
      ),
      'presets': [for (final p in PenPreset.defaults) p.toJson()],
    };
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('${phase}_dense_ink');
    expect(controller.document.strokes, hasLength(121));
    expect(tester.takeException(), isNull);
  });
}
