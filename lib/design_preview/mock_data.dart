// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class NotebookMock {
  final String id;
  final String title;
  final String category;
  final String lastModified;
  final int pageCount;
  final Color coverColor;
  final Color accentColor;
  final String templateName;
  final List<String> tags;

  const NotebookMock({
    required this.id,
    required this.title,
    required this.category,
    required this.lastModified,
    required this.pageCount,
    required this.coverColor,
    required this.accentColor,
    required this.templateName,
    required this.tags,
  });

  static const List<NotebookMock> sampleNotebooks = [
    NotebookMock(
      id: 'nb-1',
      title: 'Đại số tuyến tính — Học kỳ I',
      category: 'Toán học & Giải tích',
      lastModified: 'Vừa xong · 09:42',
      pageCount: 16,
      coverColor: Color(0xFF1E3A8A), // Oxford Blue
      accentColor: Color(0xFFD4AF37), // Gold foil
      templateName: 'Khổ A4 Kẻ ngang',
      tags: ['#toan-dai-so', '#hoc-ky-1', '#chinh-thuc'],
    ),
    NotebookMock(
      id: 'nb-2',
      title: 'Giải tích II — Chuỗi & Vi phân',
      category: 'Toán học & Giải tích',
      lastModified: 'Hôm qua · 16:30',
      pageCount: 28,
      coverColor: Color(0xFF14532D), // Deep Forest Emerald
      accentColor: Color(0xFF86EFAC),
      templateName: 'Lưới ô vuông 5mm',
      tags: ['#giai-tich', '#toan-cao-cap'],
    ),
    NotebookMock(
      id: 'nb-3',
      title: 'Cấu trúc dữ liệu & Thuật toán',
      category: 'Khoa học máy tính',
      lastModified: '3 ngày trước',
      pageCount: 42,
      coverColor: Color(0xFF881337), // Antique Crimson
      accentColor: Color(0xFFFDA4AF),
      templateName: 'Khổ A4 Kẻ ngang',
      tags: ['#dsa', '#cay-nhi-phan', '#do-thi'],
    ),
    NotebookMock(
      id: 'nb-4',
      title: 'Nhật ký nghiên cứu & Bản thảo 2026',
      category: 'Bản thảo & Ý tưởng',
      lastModified: '5 ngày trước',
      pageCount: 9,
      coverColor: Color(0xFF4338CA), // Deep Indigo
      accentColor: Color(0xFFC7D2FE),
      templateName: 'Giấy trơn nghệ thuật',
      tags: ['#y-tuong', '#phucnote-v2'],
    ),
    NotebookMock(
      id: 'nb-5',
      title: 'Vật lý đại cương — Cơ học & Nhiệt',
      category: 'Toán học & Giải tích',
      lastModified: 'Tuần trước',
      pageCount: 34,
      coverColor: Color(0xFF78350F), // Saddle Leather Brown
      accentColor: Color(0xFFFDE68A),
      templateName: 'Khổ A4 Lưới chấm',
      tags: ['#vat-ly', '#thi-nghiem'],
    ),
    NotebookMock(
      id: 'nb-6',
      title: 'Triết học Mác - Lênin & Luận cương',
      category: 'Khoa học xã hội',
      lastModified: '2 tuần trước',
      pageCount: 12,
      coverColor: Color(0xFF334155), // Slate Charcoal
      accentColor: Color(0xFF94A3B8),
      templateName: 'Khổ A4 Kẻ ngang',
      tags: ['#triet-hoc', '#on-tap'],
    ),
  ];
}

/// Custom painter to draw realistic handwritten notes on the canvas
class MockAcademicHandwritingPainter extends CustomPainter {
  final bool isDark;
  final Color? inkColorOverride;
  final bool showA4Guides;

  MockAcademicHandwritingPainter({
    this.isDark = false,
    this.inkColorOverride,
    this.showA4Guides = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final primaryInk = inkColorOverride ?? (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B));
    final highlightInk = (isDark ? const Color(0xFFF59E0B) : const Color(0xFFF59E0B)).withValues(alpha: 0.35);
    final accentBlue = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

    final penPaint = Paint()
      ..color = primaryInk
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final bluePaint = Paint()
      ..color = accentBlue
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = highlightInk
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    // Optional A4 Paper guides outline
    if (showA4Guides) {
      final a4Border = Paint()
        ..color = (isDark ? Colors.blueGrey.shade700 : Colors.blueGrey.shade300).withValues(alpha: 0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // Draw A4 Rect (centered horizontally or at x=60)
      const a4Width = 840.0;
      final startX = (size.width - a4Width) > 0 ? (size.width - a4Width) / 2 : 0.0;
      canvas.drawRect(Rect.fromLTWH(startX, 0, a4Width, 1188), a4Border);

      // Red margin line at startX + 64
      final marginPaint = Paint()
        ..color = (isDark ? Colors.red.shade400 : Colors.red.shade600).withValues(alpha: 0.3)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(startX + 64, 0), Offset(startX + 64, 1188), marginPaint);
    }

    final offsetX = showA4Guides && size.width > 840 ? (size.width - 840) / 2 : 0.0;

    // 1. Highlight bar behind title
    canvas.drawLine(Offset(offsetX + 120, 205), Offset(offsetX + 480, 205), highlightPaint);

    // 2. Handwritten heading: "Định lý 1.3: Ma trận khả nghịch"
    final pathTitle = Path();
    pathTitle.moveTo(offsetX + 130, 210);
    pathTitle.quadraticBezierTo(offsetX + 160, 195, offsetX + 190, 210);
    pathTitle.quadraticBezierTo(offsetX + 220, 225, offsetX + 250, 210);
    pathTitle.lineTo(offsetX + 280, 210);
    canvas.drawPath(pathTitle, penPaint..strokeWidth = 3.2);

    final titlePainter = TextPainter(
      text: TextSpan(
        text: 'I. Định lý 1.3: Ma trận khả nghịch và Định thức',
        style: TextStyle(
          color: primaryInk,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titlePainter.paint(canvas, Offset(offsetX + 130, 192));

    // 3. Formula: det(A) ≠ 0 ⟺ tồn tại A^(-1)
    final formulaPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(text: 'Điều kiện cần và đủ:  ', style: TextStyle(color: primaryInk, fontSize: 15, fontStyle: FontStyle.italic)),
          TextSpan(text: 'det(A) ≠ 0  ⟺  ∃ A⁻¹ sao cho  A · A⁻¹ = Iₙ', style: TextStyle(color: accentBlue, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    formulaPainter.paint(canvas, Offset(offsetX + 130, 240));

    // 4. Handwritten bracket / matrix diagram
    final bracketLeft = Path()
      ..moveTo(offsetX + 160, 280)
      ..lineTo(offsetX + 150, 280)
      ..lineTo(offsetX + 150, 360)
      ..lineTo(offsetX + 160, 360);
    canvas.drawPath(bracketLeft, penPaint..strokeWidth = 2.0);

    final matrixPainter = TextPainter(
      text: TextSpan(
        text: 'a₁₁   a₁₂   ...   a₁ₙ\na₂₁   a₂₂   ...   a₂ₙ\n...   ...   ...   ...\naₙ₁   aₙ₂   ...   aₙₙ',
        style: TextStyle(
          color: primaryInk,
          fontSize: 14,
          fontFamily: 'monospace',
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    matrixPainter.paint(canvas, Offset(offsetX + 175, 290));

    final bracketRight = Path()
      ..moveTo(offsetX + 360, 280)
      ..lineTo(offsetX + 370, 280)
      ..lineTo(offsetX + 370, 360)
      ..lineTo(offsetX + 360, 360);
    canvas.drawPath(bracketRight, penPaint..strokeWidth = 2.0);

    // 5. Handwritten notes below
    final notePainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '• Chú ý: Nếu det(A) = 0 thì hệ phương trình thuần nhất Ax = 0 có vô số nghiệm.\n'
                '• Thuật toán khử Gauss-Jordan cho phép tìm ma trận nghịch đảo A⁻¹ với độ phức tạp O(n³).\n'
                '• Ứng dụng trong phân tích giá trị riêng (Eigenvalues): det(A - λI) = 0.',
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              fontSize: 14.5,
              height: 1.6,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    notePainter.paint(canvas, Offset(offsetX + 130, 395));

    // Underline stroke under "Gauss-Jordan"
    final underline = Path()
      ..moveTo(offsetX + 250, 442)
      ..quadraticBezierTo(offsetX + 320, 445, offsetX + 390, 442);
    canvas.drawPath(underline, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
