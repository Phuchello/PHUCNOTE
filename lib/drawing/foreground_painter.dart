// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../core/models/stroke_point.dart';
import '../core/models/stroke_property.dart';
import 'stroke_geometry.dart';

/// CustomPainter responsible for the high-refresh-rate active foreground stroke in progress.
class PhucNoteForegroundPainter extends CustomPainter {
  final List<StrokePoint> activePoints;
  final StrokeProperty property;
  final Offset? eraserPosition;
  final double eraserRadius;

  PhucNoteForegroundPainter({
    required this.activePoints,
    required this.property,
    this.eraserPosition,
    this.eraserRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw active stroke if points exist
    if (activePoints.isNotEmpty) {
      final path = StrokeGeometry.generatePath(activePoints, property);
      final paint = Paint()
        ..color = property.color
        ..style = PaintingStyle.fill;

      if (property.isHighlighter) {
        paint.blendMode = BlendMode.multiply;
      }

      canvas.drawPath(path, paint);
    }

    // 2. Draw eraser indicator if active
    if (eraserPosition != null) {
      final circlePaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(eraserPosition!, eraserRadius, circlePaint);
      canvas.drawCircle(eraserPosition!, eraserRadius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(PhucNoteForegroundPainter oldDelegate) {
    return true; // Fast path for in-flight input
  }
}
