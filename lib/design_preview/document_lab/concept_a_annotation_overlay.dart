// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ConceptAAnnotationOverlay extends StatelessWidget {
  final bool isSlide;
  final bool isDark;
  final bool showEraserCircle;

  const ConceptAAnnotationOverlay({
    super.key,
    this.isSlide = false,
    this.isDark = false,
    this.showEraserCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true, // Prototype visual overlay
      child: CustomPaint(
        painter: _DocumentAnnotationPainter(
          isSlide: isSlide,
          isDark: isDark,
          showEraserCircle: showEraserCircle,
        ),
      ),
    );
  }
}

class _DocumentAnnotationPainter extends CustomPainter {
  final bool isSlide;
  final bool isDark;
  final bool showEraserCircle;

  _DocumentAnnotationPainter({
    required this.isSlide,
    required this.isDark,
    required this.showEraserCircle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final redInk = const Color(0xFFDC2626);
    final blueInk = const Color(0xFF2563EB);
    final yellowHighlight = const Color(0xFFFFEB3B).withValues(alpha: 0.38);
    final cyanHighlight = const Color(0xFF00E5FF).withValues(alpha: 0.32);

    final penPaintRed = Paint()
      ..color = redInk
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final penPaintBlue = Paint()
      ..color = blueInk
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final highlightPaintYellow = Paint()
      ..color = yellowHighlight
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final highlightPaintCyan = Paint()
      ..color = cyanHighlight
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    if (!isSlide) {
      // --- PDF A4 ANNOTATIONS ---
      // Scale coordinates relative to size
      final scaleX = size.width / 840.0;
      final scaleY = size.height / 1188.0;

      // 1. Highlighter across heading/theorem
      canvas.drawLine(
        Offset(70 * scaleX, 185 * scaleY),
        Offset(520 * scaleX, 185 * scaleY),
        highlightPaintYellow,
      );

      // 2. Ink circle / bracket around formula
      final rectFormula = Rect.fromLTWH(65 * scaleX, 420 * scaleY, 560 * scaleX, 110 * scaleY);
      final rrect = RRect.fromRectAndRadius(rectFormula, const Radius.circular(8));
      canvas.drawRRect(rrect, penPaintRed);

      // Handwritten note beside formula
      final noteText1 = TextPainter(
        text: TextSpan(
          text: '★ Chú ý: Trọng số dương w(u,v) ≥ 0! (Nếu âm dùng Bellman-Ford)',
          style: TextStyle(
            color: redInk,
            fontSize: (13 * scaleX).clamp(11.0, 16.0),
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      noteText1.paint(canvas, Offset(80 * scaleX, 540 * scaleY));

      // Handwritten arrow from note to formula
      final arrowPath = Path();
      arrowPath.moveTo(680 * scaleX, 480 * scaleY);
      arrowPath.quadraticBezierTo(645 * scaleX, 460 * scaleY, 628 * scaleX, 475 * scaleY);
      // Arrowhead
      arrowPath.lineTo(638 * scaleX, 465 * scaleY);
      arrowPath.moveTo(628 * scaleX, 475 * scaleY);
      arrowPath.lineTo(638 * scaleX, 485 * scaleY);
      canvas.drawPath(arrowPath, penPaintRed..strokeWidth = 2.0);

      final marginNote = TextPainter(
        text: TextSpan(
          text: 'Ôn thi GK!\n(Ưu tiên làm bài tập mục 3)',
          style: TextStyle(
            color: blueInk,
            fontSize: (12 * scaleX).clamp(10.0, 15.0),
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      marginNote.paint(canvas, Offset(690 * scaleX, 465 * scaleY));

      // Underline on key paragraph
      final underline = Path()
        ..moveTo(70 * scaleX, 735 * scaleY)
        ..quadraticBezierTo(250 * scaleX, 738 * scaleY, 480 * scaleX, 734 * scaleY);
      canvas.drawPath(underline, penPaintBlue);

      // 3. Eraser indicator circle (shows non-destructive eraser test)
      if (showEraserCircle) {
        final eraserCenter = Offset(520 * scaleX, 735 * scaleY);
        final eraserPaint = Paint()
          ..color = (isDark ? Colors.amberAccent : const Color(0xFFD97706)).withValues(alpha: 0.8)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        final eraserFill = Paint()
          ..color = (isDark ? Colors.amberAccent : const Color(0xFFD97706)).withValues(alpha: 0.15)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(eraserCenter, 18 * scaleX, eraserFill);
        canvas.drawCircle(eraserCenter, 18 * scaleX, eraserPaint);

        // Subtle crosshair
        canvas.drawLine(
          Offset(eraserCenter.dx - 6, eraserCenter.dy),
          Offset(eraserCenter.dx + 6, eraserCenter.dy),
          eraserPaint..strokeWidth = 1.0,
        );
        canvas.drawLine(
          Offset(eraserCenter.dx, eraserCenter.dy - 6),
          Offset(eraserCenter.dx, eraserCenter.dy + 6),
          eraserPaint..strokeWidth = 1.0,
        );
      }
    } else {
      // --- SLIDE 16:9 ANNOTATIONS ---
      final scaleX = size.width / 960.0;
      final scaleY = size.height / 540.0;

      // 1. Highlighter on Slide Subtitle / Architecture component
      canvas.drawLine(
        Offset(80 * scaleX, 160 * scaleY),
        Offset(460 * scaleX, 160 * scaleY),
        highlightPaintCyan,
      );

      // 2. Handwritten Box around Key Encryption standard
      final rrectSlide = RRect.fromRectAndRadius(
        Rect.fromLTWH(120 * scaleX, 230 * scaleY, 320 * scaleX, 85 * scaleY),
        const Radius.circular(8),
      );
      canvas.drawRRect(rrectSlide, penPaintRed);

      // Handwritten Arrow & annotation
      final arrowPath = Path()
        ..moveTo(450 * scaleX, 275 * scaleY)
        ..quadraticBezierTo(540 * scaleX, 260 * scaleY, 610 * scaleX, 290 * scaleY);
      canvas.drawPath(arrowPath, penPaintRed..strokeWidth = 2.2);

      final slideNote = TextPainter(
        text: TextSpan(
          text: '✓ Khóa công khai / bí mật: Mã hóa đối xứng nhanh hơn 1000x\n  (Dùng AES cho payload, RSA cho trao đổi khóa)',
          style: TextStyle(
            color: redInk,
            fontSize: (12.5 * scaleX).clamp(11.0, 16.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      slideNote.paint(canvas, Offset(500 * scaleX, 310 * scaleY));

      // 3. Eraser indicator circle on slide
      if (showEraserCircle) {
        final eraserCenter = Offset(450 * scaleX, 275 * scaleY);
        final eraserPaint = Paint()
          ..color = (isDark ? Colors.amberAccent : const Color(0xFFD97706)).withValues(alpha: 0.8)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        final eraserFill = Paint()
          ..color = (isDark ? Colors.amberAccent : const Color(0xFFD97706)).withValues(alpha: 0.15)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(eraserCenter, 16 * scaleX, eraserFill);
        canvas.drawCircle(eraserCenter, 16 * scaleX, eraserPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DocumentAnnotationPainter oldDelegate) => true;
}
