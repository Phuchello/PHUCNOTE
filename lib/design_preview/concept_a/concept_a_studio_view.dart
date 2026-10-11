// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'concept_a_editor_view.dart';

class ConceptAStudioView extends StatelessWidget {
  final bool isDark;

  const ConceptAStudioView({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final panelBg = isDark ? const Color(0xFF161B22) : const Color(0xFFFAF7F2);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final gold = const Color(0xFFD4AF37);

    return Scaffold(
      body: Stack(
        children: [
          // Underlying Editor is partially visible on the left
          Positioned.fill(
            child: ConceptAEditorView(isDark: isDark),
          ),

          // Subtle scrim over the left portion
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.25),
            ),
          ),

          // Right Atelier Inspector Panel
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 440,
            child: Container(
              decoration: BoxDecoration(
                color: panelBg,
                border: Border(
                  left: BorderSide(color: isDark ? Colors.white12 : gold.withValues(alpha: 0.5), width: 1.5),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(-4, 0)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Panel Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1117) : const Color(0xFF0F172A),
                        border: Border(bottom: BorderSide(color: gold.withValues(alpha: 0.3))),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune, color: gold, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'XƯỞNG CHẾ TÁC BÚT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                Text(
                                  'Hiệu chỉnh thông số ngòi & mực học thuật',
                                  style: TextStyle(color: Colors.white60, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Configuration Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Presets Selector Card
                            Text('MẪU BÚT ĐÃ CHỌN', style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: gold.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A8A),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: gold, width: 1.5),
                                    ),
                                    child: const Icon(Icons.draw, color: Colors.white, size: 16),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Bút máy ký họa (Fountain Pen)', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                        Text('Ngòi mềm biến thiên theo lực nhấn', style: TextStyle(color: textSecondary, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 2. Live Ink Writing Sandbox
                            Text('VIẾT THỬ NGÒI BÚT TẠI ĐÂY', style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            const SizedBox(height: 8),
                            Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F242C) : const Color(0xFFFFFDF9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                              ),
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    size: const Size(400, 90),
                                    painter: _LiveWaveStrokePainter(
                                      strokeColor: const Color(0xFF1E3A8A),
                                      isDark: isDark,
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    bottom: 8,
                                    child: Row(
                                      children: [
                                        Icon(Icons.refresh, size: 14, color: textSecondary),
                                        const SizedBox(width: 4),
                                        Text('Xóa nét thử', style: TextStyle(color: textSecondary, fontSize: 10.5)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 3. Precision Sliders
                            _buildAtelierSlider('Độ rộng ngòi', '3.0 mm', 0.45, gold, textPrimary, textSecondary),
                            _buildAtelierSlider('Độ đậm mực', '100 %', 1.0, gold, textPrimary, textSecondary),
                            _buildAtelierSlider('Độ biến thiên lực', '45 %', 0.45, gold, textPrimary, textSecondary),
                            _buildAtelierSlider('Độ mượt nét bút', '55 %', 0.55, gold, textPrimary, textSecondary),

                            const SizedBox(height: 16),

                            // 4. UNCLIPPED ARTISANAL INK WELLS (KHAY MỰC MỸ THUẬT)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('BẢNG MỰC HỌC THUẬT', style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                Text('12 sắc màu', style: TextStyle(color: textSecondary, fontSize: 10.5)),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 2-Row Generously Spaced Grid with FULL VISIBILITY
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F242C) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildInkWel('Xanh Oxford', const Color(0xFF1E3A8A), isSelected: true, gold: gold),
                                      _buildInkWel('Đen Mực Nho', const Color(0xFF0F172A), isSelected: false, gold: gold),
                                      _buildInkWel('Đỏ Huyết Dụ', const Color(0xFF881337), isSelected: false, gold: gold),
                                      _buildInkWel('Xanh Rừng Già', const Color(0xFF14532D), isSelected: false, gold: gold),
                                      _buildInkWel('Hổ Phách', const Color(0xFFD97706), isSelected: false, gold: gold),
                                      _buildInkWel('Tím Hoàng Gia', const Color(0xFF6B21A8), isSelected: false, gold: gold),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildInkWel('Lam Ngọc', const Color(0xFF0284C7), isSelected: false, gold: gold),
                                      _buildInkWel('Xám Bồ Câu', const Color(0xFF475569), isSelected: false, gold: gold),
                                      _buildInkWel('Đỏ Son', const Color(0xFFDC2626), isSelected: false, gold: gold),
                                      _buildInkWel('Lục Ôliu', const Color(0xFF65A30D), isSelected: false, gold: gold),
                                      _buildInkWel('Cam Cháy', const Color(0xFFEA580C), isSelected: false, gold: gold),
                                      _buildInkWel('Tím Thạch Anh', const Color(0xFF9333EA), isSelected: false, gold: gold),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Panel Footer Actions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111720) : const Color(0xFFEFECE5),
                        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                      ),
                      child: Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textSecondary,
                              side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onPressed: () {},
                            child: const Text('Đặt lại mẫu', style: TextStyle(fontSize: 12.5)),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: const Color(0xFFFDE68A),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              side: BorderSide(color: gold, width: 1.0),
                            ),
                            icon: const Icon(Icons.bookmark_add, size: 16, color: Color(0xFFD4AF37)),
                            label: const Text('Lưu mẫu riêng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtelierSlider(String title, String valText, double value, Color gold, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
              Text(valText, style: TextStyle(color: const Color(0xFF1E3A8A), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF1E3A8A),
              thumbColor: gold,
              inactiveTrackColor: Colors.black12,
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInkWel(String name, Color color, {required bool isSelected, required Color gold}) {
    return Tooltip(
      message: name,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? gold : Colors.white,
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Center(
                child: Icon(Icons.check, size: 18, color: Colors.white),
              )
            : null,
      ),
    );
  }
}

class _LiveWaveStrokePainter extends CustomPainter {
  final Color strokeColor;
  final bool isDark;

  _LiveWaveStrokePainter({required this.strokeColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Ruled lines in test area
    final linePaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06))
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), linePaint);

    // Calligraphic stroke wave
    final path = Path();
    path.moveTo(30, 45);
    for (double x = 30; x < size.width - 30; x += 36) {
      path.quadraticBezierTo(x + 9, 20, x + 18, 45);
      path.quadraticBezierTo(x + 27, 70, x + 36, 45);
    }

    final wavePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
