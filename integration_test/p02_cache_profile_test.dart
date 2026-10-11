import '../tool/ink_benchmark/p02_candidate_cache.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/drawing/stroke_path_cache.dart';

import '../tool/ink_benchmark/p02_cache_painter.dart';
import '../tool/ink_benchmark/allocation_snapshot.dart';
import '../tool/ink_benchmark/benchmark.dart';
import '../tool/ink_benchmark/p02_baseline_cache.dart';
import '../tool/ink_benchmark/p02_measurements.dart';

class _Viewport extends ChangeNotifier {
  Offset offset = Offset.zero;
  double zoom = 1;
  final cpu = <double>[];
  void step(int i) {
    offset = Offset(i % 6 < 2 ? 2 : -2, 0);
    zoom = i % 6 >= 4 ? 1.05 : 1;
    notifyListeners();
  }
}

class _Painter extends CustomPainter {
  final _Viewport viewport;
  final NoteDocument document;
  final StrokePathCache cache;
  _Painter(this.viewport, this.document, this.cache) : super(repaint: viewport);
  @override
  void paint(Canvas canvas, Size size) {
    final watch = Stopwatch()..start();
    P02CachePainter(
      document: document,
      backgroundColor: const Color(0xfffafafa),
      repaintCounter: 0,
      viewportOffset: viewport.offset,
      zoomScale: viewport.zoom,
      strokeCache: cache,
    ).paint(canvas, size);
    watch.stop();
    viewport.cpu.add(watch.elapsedMicroseconds / 1000);
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) => true;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('P02 three matched committed-cache frame repetitions', (
    tester,
  ) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await SystemChrome.setPreferredOrientations([]);
    });
    final results = <Map<String, Object?>>[];
    for (var repeat = 0; repeat < 3; repeat++) {
      for (final density in [32, 128, 256, 512]) {
        final document = cachePage(density, 128, distributed: true);
        final order = repeat.isEven
            ? ['baseline', 'candidate']
            : ['candidate', 'baseline'];
        for (final phase in order) {
          final capture = 'r${repeat}_cache_${density}_$phase';
          final cache = phase == 'baseline'
              ? P02BaselineCache()
              : P02CandidateCache();
          final viewport = _Viewport();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RepaintBoundary(
                  child: CustomPaint(
                    painter: _Painter(viewport, document, cache),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (var i = 0; i < 8; i++) {
            viewport.step(i);
            await tester.pump(const Duration(milliseconds: 17));
          }
          await tester.runAsync(
            () => allocationSnapshot(phase: capture, reset: true),
          );
          viewport.cpu.clear();
          final frames = <ui.FrameTiming>[];
          void record(List<ui.FrameTiming> batch) => frames.addAll(batch);
          SchedulerBinding.instance.addTimingsCallback(record);
          for (var i = 0; i < 72; i++) {
            viewport.step(i);
            await tester.pump(const Duration(milliseconds: 17));
          }
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(seconds: 1)),
          );
          SchedulerBinding.instance.removeTimingsCallback(record);
          await tester.runAsync(() => allocationSnapshot(phase: capture));
          results.add({
            'repeat': repeat,
            'density': density,
            'length': 128,
            'phase': phase,
            'capture': capture,
            'order': order,
            'paintCpuMs': distribution(viewport.cpu),
            'rawPaintMs': List.of(viewport.cpu),
            'cache': cacheStats(cache),
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
              frames
                  .map((f) => f.rasterDuration.inMicroseconds / 1000)
                  .toList(),
            ),
            'totalMs': distribution(
              frames.map((f) => f.totalSpan.inMicroseconds / 1000).toList(),
            ),
          });
          expect(cache.entryCount, lessThanOrEqualTo(128));
          expect(cache.retainedPointCount, lessThanOrEqualTo(20000));
          if (repeat == 2) {
            await binding.convertFlutterSurfaceToImage();
            await tester.pumpAndSettle();
            await binding.takeScreenshot(capture);
          }
          await tester.pumpWidget(const SizedBox.shrink());
          viewport.dispose();
        }
      }
    }
    binding.reportData = {
      ...?binding.reportData,
      'environment': 'Android 15 medium_tablet profile, synthetic; physical Y700/AP501U NOT EXECUTED',
      'warmupFrames': 8,
      'measuredFrames': 72,
      'cachePhases': results,
    };
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(minutes: 12)));
}
