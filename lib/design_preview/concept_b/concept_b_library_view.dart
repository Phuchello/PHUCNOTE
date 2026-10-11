// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../mock_data.dart';

class ConceptBLibraryView extends StatelessWidget {
  final bool isDark;

  const ConceptBLibraryView({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF090A0F) : const Color(0xFFF1F5F9);
    final sidebarBg = isDark ? const Color(0xFF11141C) : const Color(0xFFFFFFFF);
    final cardBg = isDark ? const Color(0xFF161B26) : const Color(0xFFFFFFFF);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cobalt = const Color(0xFF0052FF);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Row(
          children: [
            // 1. Left Navigation Rail
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: sidebarBg,
                border: Border(
                  right: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Brand
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0052FF), Color(0xFF00C6FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: cobalt.withValues(alpha: 0.35), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.edit_note, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PHUCNOTE',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'STUDIO WORKSPACE',
                            style: TextStyle(
                              color: cobalt,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Nav Sections
                  Text('KHÔNG GIAN LÀM VIỆC', style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
                  const SizedBox(height: 10),
                  _buildNavTile(Icons.dashboard_outlined, 'Tất cả ghi chú', count: 6, isSelected: true, cobalt: cobalt, isDark: isDark),
                  _buildNavTile(Icons.push_pin_outlined, 'Đã ghim', count: 2, isSelected: false, cobalt: cobalt, isDark: isDark),
                  _buildNavTile(Icons.schedule, 'Gần đây', count: 4, isSelected: false, cobalt: cobalt, isDark: isDark),
                  _buildNavTile(Icons.delete_outline, 'Thùng rác', count: null, isSelected: false, cobalt: cobalt, isDark: isDark),

                  const SizedBox(height: 24),

                  Text('NHÃN & CHỦ ĐỀ', style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
                  const SizedBox(height: 10),
                  _buildTagTile('#toan-dai-so', const Color(0xFF3B82F6), isDark: isDark),
                  _buildTagTile('#giai-tich', const Color(0xFF10B981), isDark: isDark),
                  _buildTagTile('#dsa', const Color(0xFFF43F5E), isDark: isDark),
                  _buildTagTile('#y-tuong-2026', const Color(0xFF8B5CF6), isDark: isDark),

                  const Spacer(),

                  // Storage / Sync pill
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_done, size: 18, color: Color(0xFF10B981)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bộ nhớ cục bộ an toàn', style: TextStyle(color: textPrimary, fontSize: 11.5, fontWeight: FontWeight.bold)),
                              Text('6 sổ tay · 128 MB', style: TextStyle(color: textSecondary, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Studio Content Area
            Expanded(
              child: Column(
                children: [
                  // Studio Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: sidebarBg,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Tất cả ghi chú',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cobalt.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '6 sổ',
                            style: TextStyle(color: cobalt, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),

                        const Spacer(),

                        // Search
                        Container(
                          width: 240,
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1F2C) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, size: 16, color: textSecondary),
                              const SizedBox(width: 8),
                              Text('Tìm kiếm (⌘K)...', style: TextStyle(color: textSecondary, fontSize: 12.5)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Filter / Sort toggle
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1F2C) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.grid_view, size: 18, color: cobalt),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.view_list, size: 18, color: textSecondary),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // "+ Sổ mới" Button
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: cobalt,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Sổ mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Cards Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.15,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: NotebookMock.sampleNotebooks.length,
                        itemBuilder: (context, index) {
                          final item = NotebookMock.sampleNotebooks[index];
                          return _buildStudioCard(item, cardBg, textPrimary, textSecondary, isDark, cobalt);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(IconData icon, String title, {int? count, required bool isSelected, required Color cobalt, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isSelected ? cobalt.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? cobalt : (isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? cobalt : (isDark ? Colors.white : Colors.black87),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          if (count != null)
            Text(
              '$count',
              style: TextStyle(color: isSelected ? cobalt : (isDark ? Colors.white38 : Colors.black38), fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildTagTile(String tag, Color dotColor, {required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(tag, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _buildStudioCard(NotebookMock book, Color cardBg, Color textPrimary, Color textSecondary, bool isDark, Color cobalt) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upper Canvas Thumbnail Preview with realistic handwriting silhouette
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2430) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(
                  bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                ),
              ),
              child: Stack(
                children: [
                  // Subtle paper ruling lines
                  CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _MiniRuledPaperPainter(isDark: isDark),
                  ),

                  // Mini handwriting strokes
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cobalt.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 180,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white30 : Colors.black26,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 110,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white30 : Colors.black26,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Template tag chip
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black54 : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Text(
                        book.templateName,
                        style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lower Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.more_horiz, size: 16, color: textSecondary),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      book.lastModified,
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cobalt.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${book.pageCount} trang',
                        style: TextStyle(color: cobalt, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRuledPaperPainter extends CustomPainter {
  final bool isDark;

  _MiniRuledPaperPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
      ..strokeWidth = 0.8;
    for (double y = 16; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
