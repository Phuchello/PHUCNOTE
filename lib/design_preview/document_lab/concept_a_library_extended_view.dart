// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'document_lab_models.dart';

class ConceptALibraryExtendedView extends StatefulWidget {
  final bool isDark;
  final Function(LabDocument doc)? onOpenDocument;

  const ConceptALibraryExtendedView({
    super.key,
    this.isDark = false,
    this.onOpenDocument,
  });

  @override
  State<ConceptALibraryExtendedView> createState() => _ConceptALibraryExtendedViewState();
}

class _ConceptALibraryExtendedViewState extends State<ConceptALibraryExtendedView> {
  int _selectedFilterIndex = 0; // 0: All, 1: Notebooks, 2: PDF, 3: Slides, 4: Scan

  final List<String> _filters = [
    'Tất cả (6)',
    'Sổ tay .bfly (3)',
    'Tài liệu PDF (1)',
    'Bài giảng Slide (1)',
    'Bản quét (1)',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgDark = const Color(0xFF0D1117);
    final bgLight = const Color(0xFFF7F4EE); // Warm atelier linen
    final surfaceColor = isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final accentGold = const Color(0xFFD4AF37);

    final allDocs = LabDocument.sampleDocuments;
    final filteredDocs = allDocs.where((doc) {
      if (_selectedFilterIndex == 1) return doc.type == LabDocumentType.notebook;
      if (_selectedFilterIndex == 2) return doc.type == LabDocumentType.pdf;
      if (_selectedFilterIndex == 3) return doc.type == LabDocumentType.slides;
      if (_selectedFilterIndex == 4) return doc.type == LabDocumentType.scanned;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Atelier Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                              'DOCUMENT LAB',
                              style: TextStyle(
                                color: accentGold,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Thư viện học thuật — Sổ tay viết tay, Tài liệu PDF & Bài giảng',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Search Box
                  Container(
                    width: 280,
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1ECE1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 16, color: textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tìm sổ tay, PDF, slide...',
                            style: TextStyle(color: textSecondary, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // New Notebook / Import Buttons
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: const Color(0xFFFDE68A),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: accentGold.withValues(alpha: 0.6)),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tạo sổ tay', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 2. Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              color: isDark ? const Color(0xFF111620) : const Color(0xFFF0EBE1),
              child: Row(
                children: [
                  for (int i = 0; i < _filters.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => _selectedFilterIndex = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedFilterIndex == i
                                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF1E3A8A))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedFilterIndex == i
                                  ? accentGold.withValues(alpha: 0.6)
                                  : (isDark ? Colors.white12 : Colors.black12),
                            ),
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedFilterIndex == i ? FontWeight.bold : FontWeight.w500,
                              color: _selectedFilterIndex == i
                                  ? (isDark ? accentGold : Colors.white)
                                  : textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Icon(Icons.tune, size: 16, color: textSecondary),
                  const SizedBox(width: 6),
                  Text('Sắp xếp: Mới mở gần đây', style: TextStyle(color: textSecondary, fontSize: 11.5)),
                ],
              ),
            ),

            // 3. Document Shelf & Grid
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  // Section: Recent Documents Shelf
                  Row(
                    children: [
                      Icon(Icons.history_edu, size: 18, color: accentGold),
                      const SizedBox(width: 8),
                      Text(
                        'TÀI LIỆU MỞ GẦN ĐÂY',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final doc = allDocs[index];
                        return _buildRecentCard(doc, surfaceColor, accentGold, textPrimary, textSecondary, isDark);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section: All Documents Grid Header
                  Row(
                    children: [
                      Icon(Icons.collections_bookmark, size: 18, color: accentGold),
                      const SizedBox(width: 8),
                      Text(
                        'TOÀN BỘ DANH MỤC HỌC THUẬT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text('${filteredDocs.length} tài liệu', style: TextStyle(color: textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Grid of Documents
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      return _buildDocumentCard(doc, surfaceColor, accentGold, textPrimary, textSecondary, isDark);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(
    LabDocument doc,
    Color surfaceColor,
    Color accentGold,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => widget.onOpenDocument?.call(doc),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail / Cover Preview
            Container(
              width: 75,
              height: 105,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: doc.type == LabDocumentType.notebook
                    ? Container(
                        color: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bookmark, color: Color(0xFFD4AF37), size: 20),
                            const SizedBox(height: 4),
                            Text(
                              doc.title,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    : Image.asset(doc.thumbnailAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),

            // Meta Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: doc.badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: doc.badgeColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          doc.badgeText,
                          style: TextStyle(
                            color: doc.badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        doc.type == LabDocumentType.slides ? '${doc.pageCount} slide' : '${doc.pageCount} trang',
                        style: TextStyle(color: textSecondary, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    doc.title,
                    maxLines: 2,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doc.sourceFormat,
                    style: TextStyle(color: textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    doc.lastModified,
                    style: TextStyle(color: textSecondary, fontSize: 10.5, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    LabDocument doc,
    Color surfaceColor,
    Color accentGold,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => widget.onOpenDocument?.call(doc),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Preview Area
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F141C) : const Color(0xFFEFEAE1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: doc.type == LabDocumentType.notebook
                              ? Container(
                                  width: 100,
                                  color: const Color(0xFF1E3A8A),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.bookmark, color: Color(0xFFD4AF37), size: 24),
                                      const SizedBox(height: 6),
                                      Text(
                                        doc.title,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
                              : Image.asset(doc.thumbnailAsset, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    // Badge on top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: doc.badgeColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                        ),
                        child: Text(
                          doc.badgeText,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Meta Area
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.description, size: 12, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          doc.type == LabDocumentType.slides ? '${doc.pageCount} slide' : '${doc.pageCount} trang',
                          style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(doc.fileSize, style: TextStyle(fontSize: 10.5, color: textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.lastModified,
                      style: TextStyle(fontSize: 10, color: textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
