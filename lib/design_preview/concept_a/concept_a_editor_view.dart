// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../mock_data.dart';

class ConceptAEditorView extends StatelessWidget {
  final bool isDark;
  final bool isPortrait;
  final VoidCallback? onOpenStudio;

  const ConceptAEditorView({
    super.key,
    this.isDark = false,
    this.isPortrait = false,
    this.onOpenStudio,
  });

  @override
  Widget build(BuildContext context) {
    final deskBg = isDark ? const Color(0xFF0B0F14) : const Color(0xFFEBE6DC);
    final headerBg = isDark ? const Color(0xFF161B22) : const Color(0xFF0F172A);
    final paperBg = isDark ? const Color(0xFF161D26) : const Color(0xFFFAF7F0);
    final gold = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: deskBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Atelier Top Header
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: headerBg,
                border: Border(
                  bottom: BorderSide(color: isDark ? Colors.white12 : gold.withValues(alpha: 0.4), width: 1.0),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  // Back to Library
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, size: 16, color: Color(0xFFFDE68A)),
                          SizedBox(width: 6),
                          Text(
                            'Thư viện',
                            style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Notebook Title
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark, size: 18, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            'Đại số tuyến tính — Học kỳ I',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isPortrait) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.edit, size: 14, color: Colors.white54),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Autosave Safe Pill
                  if (!isPortrait)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Color(0xFF34D399)),
                          SizedBox(width: 4),
                          Text(
                            'Đã lưu 09:42',
                            style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Page Navigation Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.chevron_left, size: 18, color: Colors.white70),
                        SizedBox(width: 4),
                        Text('Trang 1 / 16', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 18, color: Colors.white70),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // A4 Guide toggle pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: gold.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.description, size: 14, color: Color(0xFFFDE68A)),
                        SizedBox(width: 4),
                        Text('Khổ A4', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Zen Mode Icon
                  IconButton(
                    tooltip: 'Chế độ tĩnh tâm',
                    icon: const Icon(Icons.fullscreen, color: Colors.white70, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 2. Atelier Dedicated Pen Tray (Docked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111720) : const Color(0xFF243044),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  // Pen Preset 1: Bút máy (Active)
                  _buildPenSlot(
                    name: 'Bút máy',
                    widthText: '0.5mm',
                    inkColor: const Color(0xFF1E3A8A),
                    icon: Icons.draw,
                    isActive: true,
                    gold: gold,
                  ),
                  const SizedBox(width: 12),

                  // Pen Preset 2: Bút bi đỏ
                  _buildPenSlot(
                    name: 'Bút bi đỏ',
                    widthText: '0.38mm',
                    inkColor: const Color(0xFF881337),
                    icon: Icons.edit,
                    isActive: false,
                    gold: gold,
                  ),
                  const SizedBox(width: 12),

                  // Pen Preset 3: Dạ quang
                  _buildPenSlot(
                    name: 'Dạ quang',
                    widthText: '3.5mm',
                    inkColor: const Color(0xFFF59E0B),
                    icon: Icons.highlight,
                    isActive: false,
                    gold: gold,
                  ),

                  Container(
                    height: 28,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white24,
                  ),

                  // Companion tools
                  _buildCompanionTool(Icons.auto_fix_normal, 'Tẩy nét', isSelected: false),
                  const SizedBox(width: 8),
                  _buildCompanionTool(Icons.straighten, 'Thước kẻ', isSelected: false),
                  const SizedBox(width: 8),
                  _buildCompanionTool(Icons.gesture, 'Khoanh vùng', isSelected: false),

                  Container(
                    height: 28,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white24,
                  ),

                  // Undo / Redo
                  IconButton(
                    icon: const Icon(Icons.undo, size: 20, color: Colors.white70),
                    tooltip: 'Hoàn tác',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo, size: 20, color: Colors.white38),
                    tooltip: 'Làm lại',
                    onPressed: () {},
                  ),

                  const SizedBox(width: 14),

                  // "Xưởng bút" (Pen Studio) Button
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: gold.withValues(alpha: 0.2),
                      foregroundColor: const Color(0xFFFDE68A),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: gold, width: 1.0),
                      ),
                    ),
                    icon: const Icon(Icons.tune, size: 16, color: Color(0xFFD4AF37)),
                    label: const Text(
                      'Xưởng bút',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    onPressed: onOpenStudio,
                  ),
                ],
              ),
            ),
          ),

            // 3. Centered Tactile Paper Canvas
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    width: isPortrait ? 760 : 840,
                    height: 1188,
                    decoration: BoxDecoration(
                      color: paperBg,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: isDark ? Colors.blueGrey.shade800 : Colors.blueGrey.shade200,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Ruled lines background
                        CustomPaint(
                          size: Size(isPortrait ? 760 : 840, 1188),
                          painter: _AtelierRuledLinesPainter(isDark: isDark),
                        ),

                        // Realistic handwritten academic notes
                        CustomPaint(
                          size: Size(isPortrait ? 760 : 840, 1188),
                          painter: MockAcademicHandwritingPainter(
                            isDark: isDark,
                            showA4Guides: false,
                          ),
                        ),

                        // Page number footer
                        Positioned(
                          right: 24,
                          bottom: 16,
                          child: Text(
                            'Trang 1',
                            style: TextStyle(
                              color: isDark ? Colors.blueGrey.shade400 : const Color(0xFF78909C),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenSlot({
    required String name,
    required String widthText,
    required Color inkColor,
    required IconData icon,
    required bool isActive,
    required Color gold,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? gold : Colors.white12,
          width: isActive ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: inkColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              Text(
                widthText,
                style: TextStyle(
                  color: isActive ? const Color(0xFFFDE68A) : Colors.white38,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionTool(IconData icon, String tooltip, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 19, color: isSelected ? Colors.white : Colors.white70),
    );
  }
}

class _AtelierRuledLinesPainter extends CustomPainter {
  final bool isDark;

  _AtelierRuledLinesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    const lineHeight = 28.0;
    const topMargin = 84.0;
    final linePaint = Paint()
      ..color = (isDark ? Colors.blueGrey.shade800 : Colors.blueGrey.shade200).withValues(alpha: 0.6)
      ..strokeWidth = 0.8;

    for (double y = topMargin; y < size.height - 40; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Red vertical margin line at x = 64
    final marginPaint = Paint()
      ..color = (isDark ? Colors.red.shade400 : Colors.red.shade600).withValues(alpha: 0.3)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(64, 0), Offset(64, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
