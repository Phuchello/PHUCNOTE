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
  final Offset viewportOffset;

  PhucNoteViewPainter({
    required this.document,
    required this.backgroundColor,
    required this.repaintCounter,
    this.viewportOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw paper background color across the visible viewport
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    canvas.save();
    canvas.translate(viewportOffset.dx, viewportOffset.dy);

    // 2. Draw paper template pattern relative to canvas coordinates
    _drawPaperPattern(canvas, size);

    // 3. Draw all committed strokes
    for (final stroke in document.strokes) {
      _drawStroke(canvas, stroke);
    }

    canvas.restore();
  }

  void _drawPaperPattern(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    // Extend pattern beyond viewport size to support smooth panning
    final canvasWidth = size.width + 4000.0;
    final canvasHeight = size.height + 8000.0;
    final startX = -2000.0;
    final startY = -2000.0;

    switch (document.paperTemplate) {
      case PaperTemplate.blank:
        break;

      case PaperTemplate.ruled:
        const lineHeight = 36.0;
        const topMargin = 50.0;
        for (double y = topMargin; y < canvasHeight; y += lineHeight) {
          canvas.drawLine(Offset(startX, y), Offset(canvasWidth, y), linePaint);
        }
        // Red vertical margin rule
        final marginPaint = Paint()
          ..color = Colors.red.withValues(alpha: 0.20)
          ..strokeWidth = 1.2;
        canvas.drawLine(Offset(64, startY), Offset(64, canvasHeight), marginPaint);
        break;

      case PaperTemplate.grid:
        const gridSize = 28.0;
        for (double x = startX; x < canvasWidth; x += gridSize) {
          canvas.drawLine(Offset(x, startY), Offset(x, canvasHeight), linePaint);
        }
        for (double y = startY; y < canvasHeight; y += gridSize) {
          canvas.drawLine(Offset(startX, y), Offset(canvasWidth, y), linePaint);
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
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.viewportOffset != viewportOffset;
  }
}
