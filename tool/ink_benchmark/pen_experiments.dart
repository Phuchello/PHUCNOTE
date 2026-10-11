import 'dart:math' as math;
import 'dart:ui';

import 'package:perfect_freehand/perfect_freehand.dart' as freehand;

import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';

import 'incremental_geometry.dart';

/// Session-only alternatives. None can be encoded by existing StrokeProperty.
Path experimentalPen(
  List<StrokePoint> points,
  StrokeProperty property, {
  double pressureGamma = 1,
  double taper = 0,
  bool completedTip = false,
}) {
  if (points.isEmpty) return Path();
  if (points.length == 1) {
    // Keep dots explicit; tapering a one-point accent would hide it.
    return Path()..addOval(
      Rect.fromCircle(
        center: points.first.toOffset(),
        radius: property.strokeWidth / 2,
      ),
    );
  }
  final outline = freehand.getStroke(
    [
      for (final p in points)
        freehand.PointVector(
          p.x,
          p.y,
          math.pow(p.pressure.clamp(0, 1), pressureGamma).toDouble(),
        ),
    ],
    options: freehand.StrokeOptions(
      size: property.strokeWidth,
      thinning: property.thinning,
      smoothing: property.smoothing,
      streamline: property.streamline,
      simulatePressure: false,
      isComplete: completedTip,
      start: freehand.StrokeEndOptions.start(customTaper: taper),
      end: freehand.StrokeEndOptions.end(customTaper: taper),
    ),
  );
  return outlinePath(outline, property.strokeWidth);
}
