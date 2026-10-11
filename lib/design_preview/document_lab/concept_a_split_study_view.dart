// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ConceptASplitStudyView extends StatefulWidget {
  final bool isSlide;
  final bool isDark;
  final double initialSplitRatio;
  final VoidCallback? onBackToLibrary;

  const ConceptASplitStudyView({
    super.key,
    this.isSlide = true,
    this.isDark = false,
    this.initialSplitRatio = 0.46,
    this.onBackToLibrary,
  });

  @override
  State<ConceptASplitStudyView> createState() => _ConceptASplitStudyViewState();
}

class _ConceptASplitStudyViewState extends State<ConceptASplitStudyView> {
  late double _splitRatio;
  int _currentDocPage = 0;
  String _activeTool = 'pen';

  @override
  void initState() {
    super.initState();
    _splitRatio = widget.initialSplitRatio;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final deskBg = isDark ? const Color(0xFF0B0F14) : const Color(0xFFEBE6DC);
    final headerBg = isDark ? const Color(0xFF161B22) : const Color(0xFF0F172A);
    final gold = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: deskBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Dual Header
            _buildTopDualHeader(headerBg, gold, isDark),

            // 2. Split Workspace
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final leftWidth = (totalWidth * _splitRatio).clamp(240.0, totalWidth - 280.0);
                  final rightWidth = totalWidth - leftWidth - 14.0; // 14px for divider

                  return Row(
                    children: [
                      // LEFT PANE: Document (Slide or PDF)
                      SizedBox(
                        width: leftWidth,
                        child: _buildLeftDocumentPane(deskBg, gold, isDark),
                      ),

                      // CENTER DIVIDER: Draggable Atelier Brass Bar
                      _buildCenterDivider(gold, isDark, totalWidth),

                      // RIGHT PANE: PhucNote Handwriting Canvas
                      SizedBox(
                        width: rightWidth,
                        child: _buildRightHandwritingPane(isDark, gold),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDualHeader(Color headerBg, Color gold, bool isDark) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white12 : gold.withValues(alpha: 0.35), width: 1.0),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Back button
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: widget.onBackToLibrary ?? () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, size: 15, color: Color(0xFFFDE68A)),
                  SizedBox(width: 4),
                  Text(
                    'Thư viện',
                    style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Workspace Title Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: gold.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.vertical_split, size: 14, color: gold),
                const SizedBox(width: 6),
                Text(
                  widget.isSlide ? 'KHÔNG GIAN HỌC ĐÔI: SLIDE + SỔ TAY' : 'KHÔNG GIAN HỌC ĐÔI: PDF + SỔ TAY',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Split Ratio Preset Pills
          Row(
            children: [
              _buildRatioPill('40:60', 0.40, gold),
              const SizedBox(width: 4),
              _buildRatioPill('50:50', 0.50, gold),
              const SizedBox(width: 4),
              _buildRatioPill('60:40', 0.60, gold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatioPill(String label, double ratio, Color gold) {
    final isSelected = (_splitRatio - ratio).abs() < 0.05;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _splitRatio = ratio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? gold.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? gold : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDivider(Color gold, bool isDark, double totalWidth) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _splitRatio = (_splitRatio + details.delta.dx / totalWidth).clamp(0.25, 0.75);
        });
      },
      child: Container(
        width: 14,
        color: isDark ? const Color(0xFF161B22) : const Color(0xFFD6CEBE),
        child: Center(
          child: Container(
            width: 8,
            height: 48,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black26, width: 0.5),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 3),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.more_vert, size: 10, color: Color(0xFF0F172A)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftDocumentPane(Color deskBg, Color gold, bool isDark) {
    final isSlide = widget.isSlide;
    final docTitle = isSlide ? 'Kiến trúc An toàn Mạng & Mật mã' : 'Toán Rời Rạc — Lý thuyết Đồ thị';
    final pageLabel = isSlide ? 'Slide ${_currentDocPage + 1} / 6' : 'Trang ${_currentDocPage + 1} / 4';
    final targetAspect = isSlide ? (16 / 9) : (210 / 297);

    final imageAsset = isSlide
        ? (_currentDocPage == 0
            ? 'fixtures/document_lab/renders/slide_16_9_s1.png'
            : 'fixtures/document_lab/renders/slide_16_9_s2.png')
        : 'fixtures/document_lab/renders/a4_lecture_p1.png';

    return Container(
      color: isDark ? const Color(0xFF0F141C) : const Color(0xFFE4DFD5),
      child: Column(
        children: [
          // Left Pane Header Bar
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: isDark ? const Color(0xFF1E2530) : const Color(0xFFDCD6C9),
            child: Row(
              children: [
                Icon(isSlide ? Icons.slideshow : Icons.picture_as_pdf, size: 16, color: gold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    docTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    pageLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Left Document Viewport
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AspectRatio(
                  aspectRatio: targetAspect,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Left Bottom Mini Navigation
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: isDark ? const Color(0xFF1E2530) : const Color(0xFFDCD6C9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 13),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (_currentDocPage > 0) setState(() => _currentDocPage--);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      pageLabel,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 13),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        final maxPages = isSlide ? 5 : 3;
                        if (_currentDocPage < maxPages) setState(() => _currentDocPage++);
                      },
                    ),
                  ],
                ),
                Text(
                  isSlide ? 'Tỷ lệ 16:9 chuẩn' : 'Tỷ lệ A4 chuẩn',
                  style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightHandwritingPane(bool isDark, Color gold) {
    final paperBg = isDark ? const Color(0xFF161D26) : const Color(0xFFFAF7F0);

    return Container(
      color: paperBg,
      child: Stack(
        children: [
          // Ruled paper background & handwritten study notes
          Positioned.fill(
            child: CustomPaint(
              painter: _SplitStudyNotesPainter(
                isSlide: widget.isSlide,
                isDark: isDark,
              ),
            ),
          ),

          // Top Header for Notebook
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1ECE1)).withValues(alpha: 0.95),
                border: Border(
                  bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, size: 18, color: Color(0xFF1E3A8A)),
                  const SizedBox(width: 6),
                  Text(
                    widget.isSlide
                        ? 'Sổ tay: An toàn mạng & Mật mã học'
                        : 'Sổ tay: Toán rời rạc & Đồ thị',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Trang 1 / 16 (Khổ A4)',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Academic Atelier Pen Tray (Bottom Right)
          Positioned(
            bottom: 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: gold.withValues(alpha: 0.6), width: 1.2),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniTool(Icons.edit, 'Bút kim', _activeTool == 'pen', const Color(0xFF1E3A8A), () {
                    setState(() => _activeTool = 'pen');
                  }),
                  const SizedBox(width: 6),
                  _buildMiniTool(Icons.brush, 'Dạ quang', _activeTool == 'highlighter', const Color(0xFFF59E0B), () {
                    setState(() => _activeTool = 'highlighter');
                  }),
                  const SizedBox(width: 6),
                  _buildMiniTool(Icons.auto_fix_normal, 'Tẩy', _activeTool == 'eraser', Colors.amber, () {
                    setState(() => _activeTool = 'eraser');
                  }),
                  const VerticalDivider(width: 14, color: Colors.white24),
                  IconButton(
                    icon: const Icon(Icons.undo, size: 16, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.redo, size: 16, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTool(IconData icon, String tip, bool isActive, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? const Color(0xFFD4AF37) : Colors.transparent),
        ),
        child: Icon(icon, size: 16, color: isActive ? const Color(0xFFFDE68A) : Colors.white70),
      ),
    );
  }
}

class _SplitStudyNotesPainter extends CustomPainter {
  final bool isSlide;
  final bool isDark;

  _SplitStudyNotesPainter({required this.isSlide, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final inkPrimary = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
    final inkAccent = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final inkHighlight = const Color(0xFFF59E0B).withValues(alpha: 0.35);

    // 1. Ruled Paper Lines
    final linePaint = Paint()
      ..color = (isDark ? Colors.blueGrey.shade800 : Colors.blueGrey.shade200).withValues(alpha: 0.5)
      ..strokeWidth = 0.8;

    const lineSpacing = 32.0;
    for (double y = 60.0; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), linePaint);
    }

    // Red Margin Line
    final marginPaint = Paint()
      ..color = (isDark ? Colors.red.shade400 : Colors.red.shade700).withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(65, 45), Offset(65, size.height), marginPaint);

    if (isSlide) {
      // --- NOTES FOR NETWORK SECURITY LECTURE ---
      // Highlight behind heading
      final hlPaint = Paint()
        ..color = inkHighlight
        ..strokeWidth = 20.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(80, 85), const Offset(420, 85), hlPaint);

      final title = TextPainter(
        text: TextSpan(
          text: 'BÀI HỌC: MÃ HÓA BẤT ĐỐI XỨNG & RSA',
          style: TextStyle(color: inkPrimary, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      title.paint(canvas, const Offset(80, 75));

      final note1 = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '1. Nguyên lý Kerckhoffs:\n',
              style: TextStyle(color: inkAccent, fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '• Độ an toàn của mật mã hoàn toàn phụ thuộc vào việc giữ bí mật Khóa riêng (Private Key),\n'
                  '  không phụ thuộc vào việc giấu giếm thuật toán giải mã.\n\n'
                  '2. Thuật toán RSA (Rivest–Shamir–Adleman):\n'
                  '• Chọn hai số nguyên tố rất lớn p và q (ngẫu nhiên, độc lập).\n'
                  '• Tính n = p · q  và  φ(n) = (p - 1)(q - 1).\n'
                  '• Khóa công khai: (e, n); Khóa bí mật: (d, n) với  e · d ≡ 1 (mod φ(n)).',
              style: TextStyle(color: inkPrimary, fontSize: 13, height: 1.45),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      note1.paint(canvas, const Offset(80, 115));

      // Hand-drawn formula frame
      final rrect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(80, 240, 360, 48),
        const Radius.circular(6),
      );
      final boxPaint = Paint()
        ..color = inkAccent
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect, boxPaint);

      final formula = TextPainter(
        text: TextSpan(
          text: 'Bản mã C = Mᵉ mod n   ⟺   Bản rõ M = Cᵈ mod n',
          style: TextStyle(color: inkAccent, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      formula.paint(canvas, const Offset(95, 255));

      final note2 = TextPainter(
        text: TextSpan(
          text: '✓ Lưu ý: Trong thực tế TLS 1.3 không dùng RSA trực tiếp để mã hóa toàn bộ luồng mạng\n'
              '  mà dùng ECDHE (Elliptic Curve Diffie-Hellman Ephemeral) để tạo khóa đối xứng AES-GCM.',
          style: TextStyle(
            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      note2.paint(canvas, const Offset(80, 305));
    } else {
      // --- NOTES FOR DISCRETE MATH / GRAPH THEORY ---
      final hlPaint = Paint()
        ..color = inkHighlight
        ..strokeWidth = 20.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(80, 85), const Offset(440, 85), hlPaint);

      final title = TextPainter(
        text: TextSpan(
          text: 'BÀI HỌC: THUẬT TOÁN DIJKSTRA & ĐỒ THỊ',
          style: TextStyle(color: inkPrimary, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      title.paint(canvas, const Offset(80, 75));

      final note1 = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '1. Bài toán tìm đường đi ngắn nhất:\n',
              style: TextStyle(color: inkAccent, fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '• Đồ thị có hướng/vô hướng có trọng số dương w(u, v) ≥ 0.\n'
                  '• Mảng khoảng cách d[v] ban đầu: d[s] = 0; d[v] = ∞ (với mọi v ≠ s).\n'
                  '• Cấu trúc dữ liệu: Min-Priority Queue để lấy đỉnh u có d[u] nhỏ nhất trong O(log V).\n\n'
                  '2. Công thức Cải tiến (Relaxation):\n'
                  '   Nếu  d[u] + w(u, v) < d[v]  thì cập nhật:  d[v] = d[u] + w(u, v)',
              style: TextStyle(color: inkPrimary, fontSize: 13, height: 1.45),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      note1.paint(canvas, const Offset(80, 115));

      // Hand-drawn graph diagram
      final penPaint = Paint()
        ..color = inkPrimary
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // Draw vertices A, B, C, D
      const oA = Offset(120, 260);
      const oB = Offset(240, 230);
      const oC = Offset(240, 290);
      const oD = Offset(360, 260);

      canvas.drawLine(oA, oB, penPaint);
      canvas.drawLine(oA, oC, penPaint);
      canvas.drawLine(oB, oD, penPaint);
      canvas.drawLine(oC, oD, penPaint);

      final nodeFill = Paint()..color = (isDark ? const Color(0xFF1E293B) : Colors.white);
      for (final p in [oA, oB, oC, oD]) {
        canvas.drawCircle(p, 14, nodeFill);
        canvas.drawCircle(p, 14, penPaint);
      }

      void drawNodeLabel(String name, Offset p) {
        final tp = TextPainter(
          text: TextSpan(text: name, style: TextStyle(color: inkPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
      }

      drawNodeLabel('S', oA);
      drawNodeLabel('B', oB);
      drawNodeLabel('C', oC);
      drawNodeLabel('T', oD);

      final note2 = TextPainter(
        text: TextSpan(
          text: 'Độ phức tạp tổng thể: O((V + E) log V).\n'
              'Nếu có cạnh trọng số âm: KHÔNG được dùng Dijkstra (phải dùng Bellman-Ford O(VE)).',
          style: TextStyle(
            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      note2.paint(canvas, const Offset(80, 320));
    }
  }

  @override
  bool shouldRepaint(covariant _SplitStudyNotesPainter oldDelegate) => true;
}
