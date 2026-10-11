import 'p02_candidate_cache.dart';
import 'p02_cache_metrics.dart';

import 'dart:ui';

import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_element.dart';

import 'p02_cache_painter.dart';

import 'benchmark.dart';
import 'p02_baseline_cache.dart';
import 'traces.dart';

Map<String, int> cacheStats(P02MeasuredCache cache) => {
  'hits': cache.hits,
  'misses': cache.misses,
  'evictions': cache.evictions,
  'bypasses': cache.bypasses,
  'entries': cache.entryCount,
  'points': cache.retainedPointCount,
  'maxEntries': cache.maxEntries,
  'maxPoints': cache.maxPoints,
};

NoteDocument cachePage(int density, int length, {bool distributed = false}) =>
    NoteDocument(
      strokes: [
        for (var i = 0; i < density; i++)
          StrokeElement(
            id: 'p02_$i',
            points: [
              for (final sample in curve(count: length))
                distributed
                    ? sample.point.copyWith(
                        x: sample.point.x * .55 + (i % 16) * 72,
                        y: sample.point.y * .35 + (i ~/ 16) * 35,
                      )
                    : sample.point,
            ],
            property: PenPreset.defaults[i % 3].property,
          ),
      ],
    );

Map<String, Object> p02DensityBenchmark() {
  final runs = <Map<String, Object>>[];
  for (final density in [32, 128, 256, 512]) {
    for (final length in [32, 128, 512]) {
      final document = cachePage(density, length);
      for (var repeat = 0; repeat < 3; repeat++) {
        final order = repeat.isEven
            ? ['baseline', 'candidate', 'uncached']
            : ['uncached', 'candidate', 'baseline'];
        for (final phase in order) {
          final cache = phase == 'baseline'
              ? P02BaselineCache()
              : P02CandidateCache();
          final samples = <double>[];
          for (var frame = 0; frame < 29; frame++) {
            final painter = P02CachePainter(
              document: document,
              backgroundColor: const Color(0xffffffff),
              repaintCounter: frame,
              viewportOffset: Offset(frame % 6 < 2 ? 2 : -2, 0),
              zoomScale: frame % 6 >= 4 ? 1.05 : 1,
              strokeCache: phase == 'uncached' ? null : cache,
            );
            final recorder = PictureRecorder();
            final watch = Stopwatch()..start();
            painter.paint(Canvas(recorder), const Size(1200, 800));
            final picture = recorder.endRecording();
            watch.stop();
            picture.dispose();
            if (frame >= 5) samples.add(watch.elapsedMicroseconds / 1000);
          }
          runs.add({
            'density': density,
            'length': length,
            'repeat': repeat,
            'order': order,
            'phase': phase,
            'paintCpuMs': distribution(samples),
            'rawMs': samples,
            'cache': cacheStats(cache),
          });
        }
      }
    }
  }
  return {
    'units': 'CPU ms, not stylus latency',
    'warmupFrames': 5,
    'measuredFrames': 24,
    'workload': 'All strokes visible; alternating pan, zoom and identical consecutive transforms; original overlapping trace retained',
    'runs': runs,
  };
}
