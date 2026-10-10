// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../core/models/note_document.dart';
import '../core/models/stroke_element.dart';
import 'stroke_geometry.dart';

/// CustomPainter responsible for rendering the static canvas background,
/// paper ruling/grid patterns, and committed vector strokes.
class PhucNoteViewPainter extends CustomPainter {
  final NoteDocument document;
  final Color backgroundColor;
  final int repaintCounter;

  PhucNoteViewPainter({
    required this.document,
    required this.backgroundColor,
    required this.repaintCounter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw paper background color
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Draw paper template pattern
    _drawPaperPattern(canvas, size);

    // 3. Draw all committed strokes
    for (final stroke in document.strokes) {
      _drawStroke(canvas, stroke);
    }
  }

  void _drawPaperPattern(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    switch (document.paperTemplate) {
      case PaperTemplate.blank:
        break;

      case PaperTemplate.ruled:
        const lineHeight = 36.0;
        final topMargin = 50.0;
        for (double y = topMargin; y < size.height; y += lineHeight) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
        // Red vertical margin rule
        final marginPaint = Paint()
          ..color = Colors.red.withValues(alpha: 0.20)
          ..strokeWidth = 1.2;
        canvas.drawLine(const Offset(64, 0), Offset(64, size.height), marginPaint);
        break;

      case PaperTemplate.grid:
        const gridSize = 28.0;
        for (double x = 0; x < size.width; x += gridSize) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
        }
        for (double y = 0; y < size.height; y += gridSize) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
        break;
    }
  }

  void _drawStroke(Canvas canvas, StrokeElement stroke) {
    final path = StrokeGeometry.generatePath(stroke.points, stroke.property);
    final paint = Paint()
      ..color = stroke.property.color
      ..style = PaintingStyle.fill;

    if (stroke.property.isHighlighter) {
      paint.blendMode = BlendMode.multiply;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PhucNoteViewPainter oldDelegate) {
    return oldDelegate.repaintCounter != repaintCounter ||
        oldDelegate.document != document ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
