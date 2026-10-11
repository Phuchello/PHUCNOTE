// Isolated experiment, never imported by production lib/.
// Preprocessing recurrence adapted from perfect_freehand 2.5.2+1 (MIT).
// Copyright (c) 2021 Stephen Ruiz; (c) 2023 Adil Hanney.
// See PERFECT_FREEHAND_LICENSE.txt for the complete notice.
import 'dart:ui';

import 'package:perfect_freehand/perfect_freehand.dart' as freehand;

import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';

/// Append-only preprocessing. The outline is deliberately still regenerated.
/// The last input has different minimum-length rules, so it stays provisional.
class IncrementalGeometry {
  final StrokeProperty property;
  final List<StrokePoint> _raw = [];
  final List<freehand.PointVector> _vectors = [];
  final List<freehand.StrokePoint> _stable = [];
  late final freehand.StrokeOptions _options;
  late freehand.StrokePoint _previous;
  double _runningLength = 0;
  bool _reachedMinimum = false;
  bool _pressureVaries = false;
  Path? _path;
  int geometryCalls = 0;
  int get retainedSamples => _raw.length;
  int get retainedPreprocessed => _stable.length;

  IncrementalGeometry(this.property) {
    _options = freehand.StrokeOptions(
      size: property.strokeWidth,
      thinning: property.thinning.clamp(-1.0, 1.0),
      smoothing: property.smoothing.clamp(0.0, 1.0),
      streamline: property.streamline.clamp(0.0, 1.0),
      isComplete: false,
    );
  }

  void append(StrokePoint point) {
    if (_raw.isNotEmpty && (point.pressure - _raw.first.pressure).abs() > .01) {
      _pressureVaries = true;
    }
    _raw.add(point);
    _vectors.add(point.toFreehandPoint());
    _path = null;
    if (_raw.length == 1) {
      _previous = freehand.StrokePoint(
        point: _vectors.first,
        updatePressure: null,
        vector: freehand.PointVector.one,
        distance: 0,
        runningLength: 0,
      );
      _stable.add(_previous);
    } else if (_raw.length >= 3) {
      // The former last input is now an ordinary input. Two-point interpolation
      // is handled by the original engine, and never enters this stable prefix.
      _advance(_vectors[_vectors.length - 2], isLast: false);
    }
  }

  void _advance(freehand.PointVector input, {required bool isLast}) {
    final point = _previous.point.lerp(
      .15 + (1 - _options.streamline) * .85,
      input,
    );
    if (point == _previous.point) return;
    final distance = point.distanceTo(_previous.point);
    _runningLength += distance;
    if (!isLast && !_reachedMinimum) {
      if (_runningLength < _options.size) return;
      _reachedMinimum = true;
    }
    _previous = freehand.StrokePoint(
      point: point,
      updatePressure: null,
      vector: point.unitVectorTo(_previous.point),
      distance: distance,
      runningLength: _runningLength,
    );
    _stable.add(_previous);
  }

  T _withTail<T>(T Function(List<freehand.StrokePoint>) work) {
    if (_raw.length < 3) {
      return work(freehand.getStrokePoints(_vectors, options: _options));
    }
    final count = _stable.length;
    final running = _runningLength;
    final minimum = _reachedMinimum;
    final previous = _previous;
    try {
      _advance(_vectors.last, isLast: true);
      _stable.first.vector = _stable.length > 1
          ? _stable[1].vector
          : freehand.PointVector.zero;
      return work(_stable);
    } finally {
      _stable.removeRange(count, _stable.length);
      _runningLength = running;
      _reachedMinimum = minimum;
      _previous = previous;
    }
  }

  /// Snapshot used by equivalence tests; not part of the measured hot path.
  List<freehand.StrokePoint> debugPreprocessed() =>
      _withTail((points) => List.of(points));

  Path path() {
    if (_path != null) return _path!;
    geometryCalls++;
    if (_raw.length < 3) {
      return _path = StrokeGeometry.generatePath(_raw, property);
    }
    // Keep the historical pressure heuristic, including its known limitation.
    _options.simulatePressure = !_pressureVaries;
    final outline = _withTail(
      (points) => freehand.getStrokeOutlinePoints(points, options: _options),
    );
    return _path = outlinePath(outline, property.strokeWidth);
  }
}

/// Exactly the production outline-to-path conversion; no geometry redesign.
Path outlinePath(List<Offset> outline, double width) {
  final path = Path();
  if (outline.isEmpty) return path;
  if (outline.length < 2) {
    return path
      ..addOval(Rect.fromCircle(center: outline.first, radius: width / 2));
  }
  path.moveTo(outline.first.dx, outline.first.dy);
  for (var i = 1; i < outline.length - 1; i++) {
    final a = outline[i];
    final b = outline[i + 1];
    path.quadraticBezierTo(a.dx, a.dy, (a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  }
  return path..close();
}
