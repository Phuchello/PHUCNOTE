// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../mock_data.dart';

class ConceptALibraryView extends StatelessWidget {
  final bool isDark;

  const ConceptALibraryView({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final bgDark = const Color(0xFF0D1117);
    final bgLight = const Color(0xFFF7F4EE); // Warm atelier linen
    final surfaceColor = isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final accentGold = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Atelier Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Atelier Insignia
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFF1E3A8A), const Color(0xFF0D1B2A)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentGold.withValues(alpha: 0.6), width: 1.2),
                      boxShadow: [
                        BoxShadow(color: accentGold.withValues(alpha: 0.2), blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.auto_stories, color: Color(0xFFD4AF37), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'XƯỞNG VIẾT PHUCNOTE',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              fontFamily: 'serif',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: accentGold.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'ATELIER',
                              style: TextStyle(
                                color: accentGold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Thư viện sổ tay học thuật & ghi chép cá nhân',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Search bar
                  Container(
                    width: 260,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1EFEA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: textSecondary),
                        const SizedBox(width: 8),
                        Text('Tìm kiếm sổ tay...', style: TextStyle(color: textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // "+ Tạo sổ mới" Atelier Button
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF0F172A),
                      foregroundColor: const Color(0xFFFDE68A),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.0),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFFD4AF37)),
                    label: const Text(
                      'Tạo sổ mới',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 2. Atelier Category Filter Shelf
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111720) : const Color(0xFFEFECE5),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildCategoryChip('Tất cả sổ (6)', isSelected: true, isDark: isDark),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Toán học & Giải tích (3)', isSelected: false, isDark: isDark),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Khoa học máy tính (1)', isSelected: false, isDark: isDark),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Bản thảo & Ý tưởng (2)', isSelected: false, isDark: isDark),
                  const Spacer(),
                  Icon(Icons.view_module, size: 20, color: textSecondary),
                  const SizedBox(width: 8),
                  Icon(Icons.sort, size: 20, color: textSecondary),
                ],
              ),
            ),

            // 3. Grid of Notebook Covers
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: NotebookMock.sampleNotebooks.length,
                  itemBuilder: (context, index) {
                    final item = NotebookMock.sampleNotebooks[index];
                    return _buildAtelierBookCard(item, isDark: isDark);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {required bool isSelected, required bool isDark}) {
    final gold = const Color(0xFFD4AF37);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? gold : (isDark ? Colors.white12 : Colors.black12),
          width: isSelected ? 1.2 : 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? (isDark ? Colors.white : const Color(0xFFFDE68A)) : (isDark ? Colors.white60 : Colors.black87),
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAtelierBookCard(NotebookMock book, {required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Upper Book Cover Surface
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: book.coverColor,
                  border: Border(
                    left: BorderSide(
                      color: Colors.black.withValues(alpha: 0.35),
                      width: 14, // Spine texture
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    // Spine gold stitch line
                    Positioned(
                      left: 18,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1.5,
                        color: book.accentColor.withValues(alpha: 0.6),
                      ),
                    ),

                    // Ribbon bookmark peeking from top
                    Positioned(
                      top: 0,
                      right: 32,
                      child: Container(
                        width: 16,
                        height: 48,
                        decoration: BoxDecoration(
                          color: book.accentColor,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                      ),
                    ),

                    // Embossed Title Plate
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(left: 32, right: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF7F0),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              book.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'serif',
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 1,
                              width: 48,
                              color: const Color(0xFFD4AF37),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.templateName,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lower Metadata Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: isDark ? const Color(0xFF1E242C) : const Color(0xFFFAFAF8),
              child: Row(
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 14,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    book.lastModified,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${book.pageCount} trang',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.more_vert, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
