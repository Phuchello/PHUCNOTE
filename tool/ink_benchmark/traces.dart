import 'dart:math' as math;

import 'package:phucnote/core/models/stroke_point.dart';

class InkSample {
  final StrokePoint point;
  final int timeUs;
  const InkSample(this.point, this.timeUs);
  Map<String, Object> toJson() => {
    ...point.toJson(),
    'timeUs': timeUs,
    'tool': 'synthetic_stylus',
  };
}

class InkTrace {
  final String id;
  final String label;
  final List<List<InkSample>> strokes;
  const InkTrace(this.id, this.label, this.strokes);
  Map<String, Object> toJson() => {
    'id': id,
    'label': label,
    'strokes': [
      for (final s in strokes) [for (final p in s) p.toJson()],
    ],
  };
}

List<InkSample> curve({
  int count = 128,
  int stepUs = 8333,
  bool ramp = false,
}) => [
  for (var i = 0; i < count; i++)
    InkSample(
      StrokePoint(
        x: 20 + i * .8,
        y: 70 + 24 * math.sin(i * .09),
        pressure: ramp ? .05 + .9 * i / math.max(1, count - 1) : .5,
        tilt: .2 + .1 * math.sin(i * .03),
      ),
      i * stepUs,
    ),
];

List<InkSample> polyline(List<math.Point<double>> vertices, {int steps = 8}) {
  final points = <InkSample>[];
  for (var edge = 0; edge < vertices.length - 1; edge++) {
    final a = vertices[edge];
    final b = vertices[edge + 1];
    for (var j = 0; j < steps; j++) {
      final t = j / steps;
      points.add(
        InkSample(
          StrokePoint(
            x: a.x + (b.x - a.x) * t,
            y: a.y + (b.y - a.y) * t,
            pressure: .5,
          ),
          points.length * 8333,
        ),
      );
    }
  }
  final end = vertices.last;
  points.add(InkSample(StrokePoint(x: end.x, y: end.y), points.length * 8333));
  return points;
}

List<InkSample> line(List<double> xy) => polyline([
  for (var i = 0; i < xy.length; i += 2) math.Point(xy[i], xy[i + 1]),
]);

List<InkSample> oval(double x, double y, double rx, double ry) => [
  for (var i = 0; i <= 64; i++)
    InkSample(
      StrokePoint(
        x: x + rx * math.cos(i * math.pi / 32),
        y: y + ry * math.sin(i * math.pi / 32),
        pressure: .5,
      ),
      i * 8333,
    ),
];

List<InkTrace> traceCatalog() => [
  const InkTrace('01', 'Dots', [
    [InkSample(StrokePoint(x: 40, y: 60, pressure: .05), 0)],
    [InkSample(StrokePoint(x: 60, y: 60, pressure: .95), 0)],
  ]),
  InkTrace('02', 'Fine strokes', [
    line([20, 60, 24, 54, 28, 60]),
    line([40, 60, 46, 52]),
  ]),
  InkTrace('03', 'Long curve', [curve()]),
  InkTrace('04', 'Rapid zigzag', [
    line([20, 70, 40, 30, 60, 70, 80, 30, 100, 70, 120, 30]),
  ]),
  InkTrace('05', 'Tight loops', [
    for (var i = 0; i < 4; i++) oval(40 + i * 28, 60, 8, 20),
  ]),
  InkTrace('06', 'Sharp corners', [
    line([20, 30, 20, 70, 65, 70, 65, 30, 110, 70]),
  ]),
  InkTrace('07', 'Slow motifs', [curve(stepUs: 33333)]),
  InkTrace('08', 'Fast lecture motifs', [curve(stepUs: 4167)]),
  InkTrace('09', 'Tiếng Việt (synthetic components)', [
    line([20, 40, 45, 40]),
    line([32, 40, 32, 75]),
    line([53, 56, 53, 75]),
    const [InkSample(StrokePoint(x: 53, y: 48), 0)],
    oval(75, 66, 9, 10),
    line([66, 48, 75, 41, 84, 48]),
    line([75, 36, 81, 29]),
    line([98, 75, 98, 57, 107, 54, 114, 58, 114, 75]),
    oval(134, 66, 9, 10),
    line([143, 66, 143, 84, 133, 88]),
    line([163, 45, 176, 76, 189, 45]),
    line([201, 56, 201, 75]),
    const [InkSample(StrokePoint(x: 201, y: 48), 0)],
    oval(222, 66, 9, 10),
    line([213, 48, 222, 41, 231, 48]),
    const [InkSample(StrokePoint(x: 222, y: 84), 0)],
    line([250, 47, 250, 76]),
    line([241, 57, 258, 57]),
  ]),
  InkTrace('10', 'x2 + y2 = 1 components', [
    line([20, 55, 40, 75]),
    line([40, 55, 20, 75]),
    line([46, 74, 52, 70, 58, 74, 46, 84, 58, 84]),
    line([70, 65, 90, 65]),
    line([80, 55, 80, 75]),
    line([103, 54, 113, 67, 123, 54, 106, 85]),
    line([130, 47, 136, 43, 142, 47, 130, 57, 142, 57]),
    line([156, 61, 176, 61]),
    line([156, 70, 176, 70]),
    line([190, 58, 199, 53, 199, 75]),
  ]),
  InkTrace('11', 'Topology arrows', [
    oval(40, 60, 16, 14),
    oval(130, 60, 16, 14),
    line([58, 60, 110, 60]),
    line([100, 53, 110, 60, 100, 67]),
  ]),
  InkTrace('12', 'Pressure ramp', [curve(ramp: true)]),
  InkTrace('13', 'Plateau then pressure jump', [
    [
      for (var i = 0; i < 128; i++)
        InkSample(
          StrokePoint(x: 20 + i.toDouble(), y: 60, pressure: i < 96 ? .2 : .9),
          i * 8333,
        ),
    ],
  ]),
  InkTrace('14', 'Dense page unit', [
    for (var i = 0; i < 8; i++)
      [
        for (final p in curve())
          InkSample(p.point.copyWith(y: p.point.y + i * 5), p.timeUs),
      ],
  ]),
  InkTrace('15', 'Pan zoom source', [curve(ramp: true)]),
];

Map<String, Object> catalogJson() => {
  'provenance': 'deterministic synthetic marks; not captured human handwriting',
  'schema': 'benchmark only, never a .bfly schema',
  'traces': [for (final t in traceCatalog()) t.toJson()],
};
