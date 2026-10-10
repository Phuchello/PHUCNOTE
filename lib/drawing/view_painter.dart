// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:math';
import 'package:flutter/material.dart';
import '../core/models/note_document.dart';
import '../core/models/stroke_element.dart';
import 'stroke_geometry.dart';
import 'a4_page_layout.dart';

/// CustomPainter responsible for rendering the static canvas background,
/// paper ruling/grid patterns, optional A4 notebook page guides, and committed vector strokes.
class PhucNoteViewPainter extends CustomPainter {
  final NoteDocument document;
  final Color backgroundColor;
  final int repaintCounter;
  final Offset viewportOffset;
  final double zoomScale;
  final bool showA4Guides;

  PhucNoteViewPainter({
    required this.document,
    required this.backgroundColor,
    required this.repaintCounter,
    this.viewportOffset = Offset.zero,
    this.zoomScale = 1.0,
    this.showA4Guides = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw paper background color across the visible screen viewport
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    canvas.save();
    canvas.translate(viewportOffset.dx, viewportOffset.dy);
    canvas.scale(zoomScale);

    // Compute visible bounds in document/canvas coordinates
    final visibleLeft = (-viewportOffset.dx) / zoomScale;
    final visibleTop = (-viewportOffset.dy) / zoomScale;
    final visibleRight = (size.width - viewportOffset.dx) / zoomScale;
    final visibleBottom = (size.height - viewportOffset.dy) / zoomScale;
    final visibleCanvasRect = Rect.fromLTRB(visibleLeft, visibleTop, visibleRight, visibleBottom);

    // 2. Draw paper template pattern strictly for visible canvas bounds
    _drawPaperPattern(canvas, visibleCanvasRect);

    // 3. Draw optional A4 visual page outlines, separators, and page numbers
    if (showA4Guides) {
      _drawA4Guides(canvas, visibleCanvasRect);
    }

    // 4. Draw committed strokes with offscreen viewport culling
    for (final stroke in document.strokes) {
      if (stroke.points.isEmpty || !visibleCanvasRect.overlaps(stroke.boundingBox)) {
        continue;
      }
      _drawStroke(canvas, stroke);
    }

    canvas.restore();
  }

  void _drawPaperPattern(Canvas canvas, Rect visibleRect) {
    final linePaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    switch (document.paperTemplate) {
      case PaperTemplate.blank:
        break;

      case PaperTemplate.ruled:
        const lineHeight = 36.0;
        const topMargin = 50.0;
        final startLine = max(0, ((visibleRect.top - topMargin) / lineHeight).floor());
        final endLine = max(startLine, ((visibleRect.bottom - topMargin) / lineHeight).ceil());

        for (int i = startLine; i <= endLine; i++) {
          final y = topMargin + i * lineHeight;
          canvas.drawLine(Offset(visibleRect.left, y), Offset(visibleRect.right, y), linePaint);
        }

        // Red vertical margin rule at x = 64
        final marginPaint = Paint()
          ..color = Colors.red.withValues(alpha: 0.20)
          ..strokeWidth = 1.2;
        final marginTop = max(0.0, visibleRect.top);
        final marginBottom = max(marginTop, visibleRect.bottom);
        canvas.drawLine(Offset(64, marginTop), Offset(64, marginBottom), marginPaint);
        break;

      case PaperTemplate.grid:
        const gridSize = 28.0;
        final startX = (visibleRect.left / gridSize).floor() * gridSize;
        final endX = (visibleRect.right / gridSize).ceil() * gridSize;
        final startY = max(0.0, (visibleRect.top / gridSize).floor() * gridSize);
        final endY = (visibleRect.bottom / gridSize).ceil() * gridSize;

        for (double x = startX; x <= endX; x += gridSize) {
          canvas.drawLine(Offset(x, startY), Offset(x, endY), linePaint);
        }
        for (double y = startY; y <= endY; y += gridSize) {
          canvas.drawLine(Offset(visibleRect.left, y), Offset(visibleRect.right, y), linePaint);
        }
        break;
    }

    // Top paper boundary at y = 0 if scrolled down
    if (visibleRect.top < 0.0 && visibleRect.bottom > 0.0) {
      final boundaryPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.10)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(visibleRect.left, 0.0), Offset(visibleRect.right, 0.0), boundaryPaint);
    }
  }

  void _drawA4Guides(Canvas canvas, Rect visibleRect) {
    const double a4Width = A4PageLayout.width;
    const double a4PageGap = A4PageLayout.gap;

    final pageBorderPaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoomScale;

    final gapFillPaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final gapLinePaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoomScale;

    for (final k in A4PageLayout.visiblePageIndices(visibleRect)) {
      final pageRect = A4PageLayout.pageBounds(k);
      final topY = pageRect.top;
      final bottomY = pageRect.bottom;

      // 1. Vertically stacked A4 page outline (210:297 ratio)
      canvas.drawRect(pageRect, pageBorderPaint);

      // 2. Inter-page separator bar & divider line
      if (k > 1) {
        final gapRect = A4PageLayout.gapAfterPage(k - 1);
        final gapTop = gapRect.top;
        if (gapTop < visibleRect.bottom && topY > visibleRect.top) {
          canvas.drawRect(gapRect, gapFillPaint);
          canvas.drawLine(
            Offset(0, gapTop + a4PageGap / 2),
            Offset(a4Width, gapTop + a4PageGap / 2),
            gapLinePaint,
          );
        }
      }

      // 3. Subtle page number indicator at bottom-right
      if (bottomY - 40 < visibleRect.bottom && bottomY > visibleRect.top) {
        // Keep footer text readable when the page is zoomed out.
        final labelScale = min(zoomScale, 1.0);
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'Page $k',
            style: TextStyle(
              color: const Color(0xFF78909C),
              fontSize: 12.0 / labelScale,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5 / labelScale,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(a4Width - textPainter.width - 24.0, bottomY - textPainter.height - 12.0),
        );
      }
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
        oldDelegate.viewportOffset != viewportOffset ||
        oldDelegate.zoomScale != zoomScale ||
        oldDelegate.showA4Guides != showA4Guides;
  }
}
