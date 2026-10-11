import 'dart:math' as math;

import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';

/// Deterministic synthetic traces, never described as AP501U measurements.
List<StrokePoint> loopTrace({int count = 128, double x = 0, double y = 0}) => [
  for (var i = 0; i < count; i++)
    StrokePoint(
      x: x + i * 0.35,
      y: y + 8 * math.sin(i * 0.12),
      pressure: 0.15 + 0.7 * i / (count - 1),
    ),
];

NoteDocument denseDocument() => NoteDocument(
  strokes: [
    for (var i = 0; i < 120; i++)
      StrokeElement(
        id: 'replay-$i',
        points: loopTrace(x: 90 + (i % 10) * 70, y: 80 + (i ~/ 10) * 35),
        property: PenPreset.defaults[i % 3].property,
        createdAt: DateTime.utc(2026, 10, 11),
      ),
  ],
);

Map<String, Object> summarize(List<double> samples) {
  if (samples.isEmpty) return {'count': 0};
  final sorted = [...samples]..sort();
  double percentile(double p) => sorted[((sorted.length - 1) * p).ceil()];
  return {
    'count': samples.length,
    'p50': percentile(0.5),
    'p95': percentile(0.95),
    'p99': percentile(0.99),
    'max': sorted.last,
  };
}
