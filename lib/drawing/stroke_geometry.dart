// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:perfect_freehand/perfect_freehand.dart' as freehand;
import '../core/models/stroke_point.dart';
import '../core/models/stroke_property.dart';

/// Geometry utilities for stroke outline generation and bezier path smoothing.
class StrokeGeometry {
  /// Converts a series of digitized points into a smooth vector outline [Path]
  /// using the audited `perfect_freehand` algorithm with quadratic bezier interpolation.
  static Path generatePath(List<StrokePoint> points, StrokeProperty property) {
    if (points.isEmpty) return Path();

    if (points.length == 1) {
      final p = points.first;
      final radius = property.strokeWidth / 2;
      return Path()
        ..addOval(Rect.fromCircle(center: p.toOffset(), radius: radius));
    }

    final freehandPoints = points.map((p) => p.toFreehandPoint()).toList();

    final outlinePoints = freehand.getStroke(
      freehandPoints,
      options: freehand.StrokeOptions(
        size: property.strokeWidth,
        thinning: property.thinning.clamp(-1.0, 1.0),
        smoothing: property.smoothing.clamp(0.0, 1.0),
        streamline: property.streamline.clamp(0.0, 1.0),
        simulatePressure: _shouldSimulatePressure(points),
      ),
    );

    if (outlinePoints.isEmpty) return Path();

    final path = Path();
    if (outlinePoints.length < 2) {
      path.addOval(
        Rect.fromCircle(
          center: outlinePoints[0],
          radius: property.strokeWidth / 2,
        ),
      );
    } else {
      path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);
      for (int i = 1; i < outlinePoints.length - 1; ++i) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }
      path.close();
    }

    return path;
  }

  static bool _shouldSimulatePressure(List<StrokePoint> points) {
    if (points.length < 2) return true;
    final firstPressure = points[0].pressure;
    for (int i = 1; i < points.length; i++) {
      if ((points[i].pressure - firstPressure).abs() > 0.01) {
        return false; // Hardware reports real pressure variation
      }
    }
    return true; // Constant pressure (e.g. mouse or non-pressure stylus), simulate it
  }
}
