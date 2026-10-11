import 'dart:ui';

import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/stroke_path_cache.dart';
import 'package:phucnote/drawing/view_painter.dart';

import 'incremental_geometry.dart';
import 'traces.dart';

Map<String, Object> distribution(List<double> values) {
  if (values.isEmpty) return {'count': 0};
  final sorted = List.of(values)..sort();
  double rank(double q) => sorted[(q * sorted.length).ceil() - 1];
  return {
    'count': values.length,
    'p50': rank(.5),
    'p95': rank(.95),
    'p99': rank(.99),
    'max': sorted.last,
    'sum': values.fold<double>(0, (a, b) => a + b),
  };
}

Map<String, Object> densityBenchmark() {
  final runs = <Map<String, Object>>[];
  for (final density in [32, 128, 256]) {
    final document = NoteDocument(
      strokes: [
        for (var i = 0; i < density; i++)
          StrokeElement(
            id: 'density_$i',
            points: curve().map((s) => s.point).toList(),
            property: PenPreset.defaults.first.property,
          ),
      ],
    );
    final cache = StrokePathCache();
    for (final cached in [false, true]) {
      final times = <double>[];
      for (var i = 0; i < 25; i++) {
        final recorder = PictureRecorder();
        final painter = PhucNoteViewPainter(
          document: document,
          backgroundColor: const Color(0xFFFFFFFF),
          repaintCounter: i,
          strokeCache: cached ? cache : null,
          viewportOffset: Offset(i.isEven ? 1 : -1, 0),
        );
        final watch = Stopwatch()..start();
        painter.paint(Canvas(recorder), const Size(1200, 800));
        final picture = recorder.endRecording();
        watch.stop();
        picture.dispose();
        if (i >= 5) times.add(watch.elapsedMicroseconds / 1000);
      }
      runs.add({
        'density': density,
        'existingCacheEnabled': cached,
        'paintCpuMs': distribution(times),
        'rawMs': times,
      });
    }
  }
  return {
    'kind': 'existing committed cache capacity audit; not a new patch',
    'runs': runs,
  };
}

Map<String, Object> geometryBenchmark({
  List<int> lengths = const [128, 512, 2048, 4096],
  int repetitions = 2,
  List<InkSample> Function(int)? traceFactory,
}) {
  final property = PenPreset.defaults.last.property;
  for (var warm = 0; warm < 3; warm++) {
    final candidate = IncrementalGeometry(property);
    final raw = <StrokePoint>[];
    for (final s in traceFactory?.call(256) ?? curve(count: 256, ramp: true)) {
      raw.add(s.point);
      candidate.append(s.point);
      StrokeGeometry.generatePath(raw, property);
      candidate.path();
    }
  }
  final runs = <Map<String, Object>>[];
  for (final count in lengths) {
    for (var repeat = 0; repeat < repetitions; repeat++) {
      final raw = <StrokePoint>[];
      final candidate = IncrementalGeometry(property);
      final baseline = <double>[];
      final incremental = <double>[];
      final append = <double>[];
      for (final s
          in traceFactory?.call(count) ?? curve(count: count, ramp: true)) {
        raw.add(s.point);
        final a = Stopwatch()..start();
        candidate.append(s.point);
        a.stop();
        append.add(a.elapsedMicroseconds / 1000);
        void measureBaseline() {
          final watch = Stopwatch()..start();
          StrokeGeometry.generatePath(raw, property);
          watch.stop();
          baseline.add(watch.elapsedMicroseconds / 1000);
        }

        void measureCandidate() {
          final watch = Stopwatch()..start();
          candidate.path();
          watch.stop();
          incremental.add(watch.elapsedMicroseconds / 1000);
        }

        if ((raw.length + repeat).isEven) {
          measureBaseline();
          measureCandidate();
        } else {
          measureCandidate();
          measureBaseline();
        }
      }
      runs.add({
        'length': count,
        'repeat': repeat,
        'rawPrefixPointVisits': count * (count + 1) ~/ 2,
        'baselineGeometryMs': distribution(baseline),
        'candidateOutlinePathMs': distribution(incremental),
        'candidateAppendMs': distribution(append),
        'candidateCombinedMs': distribution([
          for (var i = 0; i < append.length; i++) append[i] + incremental[i],
        ]),
        'rawBaselineMs': baseline,
        'rawCandidateMs': incremental,
        'rawAppendMs': append,
        'retainedSamples': candidate.retainedSamples,
        'retainedPreprocessed': candidate.retainedPreprocessed,
      });
    }
  }
  return {
    'units': 'milliseconds; CPU processing, never physical ink latency',
    'warmup': '3 matched 256-prefix traversals',
    'order': 'Alternating baseline/candidate path calls at each prefix, reversed on odd repetitions; append timed separately',
    'preset': PenPreset.defaults.last.toJson(),
    'runs': runs,
  };
}
