// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'concept_a_annotation_overlay.dart';
import 'document_lab_models.dart';

class ConceptADocumentReaderView extends StatefulWidget {
  final LabDocument? document;
  final int initialPage;
  final bool isDark;
  final bool isPortrait;
  final bool isAnnotated;
  final bool showThumbnails;
  final bool showInfoDialog;
  final bool isFitWidth;
  final bool isCompact;
  final VoidCallback? onBackToLibrary;

  const ConceptADocumentReaderView({
    super.key,
    this.document,
    this.initialPage = 0,
    this.isDark = false,
    this.isPortrait = false,
    this.isAnnotated = false,
    this.showThumbnails = false,
    this.showInfoDialog = false,
    this.isFitWidth = false,
    this.isCompact = false,
    this.onBackToLibrary,
  });

  @override
  State<ConceptADocumentReaderView> createState() => _ConceptADocumentReaderViewState();
}

class _ConceptADocumentReaderViewState extends State<ConceptADocumentReaderView> {
  late LabDocument _doc;
  late int _currentPage;
  late bool _thumbnailsVisible;
  late bool _fitWidth;
  late bool _annotated;
  late bool _infoDialogVisible;
  double _zoomScale = 1.0;
  String _activeTool = 'pen'; // 'pen', 'highlighter', 'eraser'

  @override
  void initState() {
    super.initState();
    _doc = widget.document ?? LabDocument.sampleDocuments[0];
    _currentPage = widget.initialPage.clamp(0, _doc.pageAssets.isNotEmpty ? _doc.pageAssets.length - 1 : 0);
    _thumbnailsVisible = widget.showThumbnails;
    _fitWidth = widget.isFitWidth;
    _annotated = widget.isAnnotated;
    _infoDialogVisible = widget.showInfoDialog;
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _nextPage() {
    if (_currentPage < _doc.pageAssets.length - 1) {
      setState(() => _currentPage++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isPortrait = widget.isPortrait;
    final deskBg = isDark ? const Color(0xFF0B0F14) : const Color(0xFFEBE6DC);
    final headerBg = isDark ? const Color(0xFF161B22) : const Color(0xFF0F172A);
    final surfaceBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final textLight = isDark ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC);
    final gold = const Color(0xFFD4AF37);
    final isSlide = _doc.type == LabDocumentType.slides;

    return Scaffold(
      backgroundColor: deskBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Atelier Top Navigation Bar
                _buildHeader(headerBg, textLight, gold, isDark, isPortrait),

                // 2. Main Reader Viewport (with optional Thumbnail sidebar)
                Expanded(
                  child: Row(
                    children: [
                      // Thumbnail Sidebar
                      if (_thumbnailsVisible) _buildThumbnailSidebar(surfaceBg, gold, isDark),

                      // Document Canvas
                      Expanded(
                        child: _buildDocumentViewport(deskBg, gold, isDark, isSlide, isPortrait),
                      ),
                    ],
                  ),
                ),

                // 3. Floating Atelier Desk Bottom Tray
                _buildBottomTray(headerBg, gold, isDark, isSlide, isPortrait),
              ],
            ),

            // Optional Document Information Modal
            if (_infoDialogVisible) _buildInfoDialog(surfaceBg, gold, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color headerBg, Color textLight, Color gold, bool isDark, bool isPortrait) {
    final pageLabel = _doc.type == LabDocumentType.slides
        ? 'Slide ${_currentPage + 1} / ${_doc.pageCount}'
        : 'Trang ${_currentPage + 1} / ${_doc.pageCount}';

    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: widget.isCompact ? 8 : 16),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, size: 15, color: Color(0xFFFDE68A)),
                  if (!widget.isCompact) ...[
                    const SizedBox(width: 4),
                    const Text(
                      'Thư viện',
                      style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Document Title & Badges
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _doc.badgeColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _doc.badgeText,
                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _doc.title,
                    style: TextStyle(
                      color: textLight,
                      fontSize: widget.isCompact ? 13 : 14.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Page counter pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              pageLabel,
              style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),

          // Actions for Landscape
          if (!widget.isCompact && !isPortrait) ...[
            // Thumbnail toggle
            IconButton(
              icon: Icon(
                _thumbnailsVisible ? Icons.grid_view : Icons.grid_view_outlined,
                color: _thumbnailsVisible ? gold : Colors.white70,
                size: 20,
              ),
              tooltip: 'Trang nhỏ',
              onPressed: () => setState(() => _thumbnailsVisible = !_thumbnailsVisible),
            ),

            // Fit width / Fit page
            IconButton(
              icon: Icon(_fitWidth ? Icons.fit_screen : Icons.zoom_out_map, color: Colors.white70, size: 20),
              tooltip: _fitWidth ? 'Vừa trang' : 'Vừa chiều rộng',
              onPressed: () => setState(() => _fitWidth = !_fitWidth),
            ),

            // Zoom out
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white70, size: 18),
              onPressed: () => setState(() => _zoomScale = (_zoomScale - 0.1).clamp(0.5, 2.5)),
            ),
            Text(
              '${(_zoomScale * 100).toInt()}%',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white70, size: 18),
              onPressed: () => setState(() => _zoomScale = (_zoomScale + 0.1).clamp(0.5, 2.5)),
            ),

            // Info button
            IconButton(
              icon: Icon(_infoDialogVisible ? Icons.info : Icons.info_outline, color: gold, size: 20),
              tooltip: 'Thông tin tài liệu',
              onPressed: () => setState(() => _infoDialogVisible = !_infoDialogVisible),
            ),
          ],

          // Actions for Portrait
          if (isPortrait && !widget.isCompact) ...[
            IconButton(
              icon: Icon(
                _thumbnailsVisible ? Icons.grid_view : Icons.grid_view_outlined,
                color: _thumbnailsVisible ? gold : Colors.white70,
                size: 20,
              ),
              tooltip: 'Trang nhỏ',
              onPressed: () => setState(() => _thumbnailsVisible = !_thumbnailsVisible),
            ),
            IconButton(
              icon: Icon(_infoDialogVisible ? Icons.info : Icons.info_outline, color: gold, size: 20),
              tooltip: 'Thông tin',
              onPressed: () => setState(() => _infoDialogVisible = !_infoDialogVisible),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnailSidebar(Color surfaceBg, Color gold, bool isDark) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: surfaceBg,
        border: Border(
          right: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.view_carousel, size: 16, color: Color(0xFFD4AF37)),
                const SizedBox(width: 6),
                Text(
                  _doc.type == LabDocumentType.slides ? 'DANH SÁCH SLIDE' : 'DANH SÁCH TRANG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: _doc.pageAssets.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentPage;
                final isSlide = _doc.type == LabDocumentType.slides;
                final aspectRatio = isSlide ? (16 / 9) : (210 / 297);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => setState(() => _currentPage = index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? gold : (isDark ? Colors.white12 : Colors.black12),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: gold.withValues(alpha: 0.3), blurRadius: 6)]
                            : const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: aspectRatio,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                              child: Image.asset(
                                _doc.pageAssets[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            alignment: Alignment.center,
                            color: isSelected ? gold.withValues(alpha: 0.2) : Colors.transparent,
                            child: Text(
                              isSlide ? 'Slide ${index + 1}' : 'Trang ${index + 1}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentViewport(Color deskBg, Color gold, bool isDark, bool isSlide, bool isPortrait) {
    final pageAsset = _doc.pageAssets.isNotEmpty
        ? _doc.pageAssets[_currentPage.clamp(0, _doc.pageAssets.length - 1)]
        : 'fixtures/document_lab/renders/a4_lecture_p1.png';

    // Proportions
    // A4 ratio: 210 / 297 = 0.707
    // Slide ratio: 16 / 9 = 1.777
    final targetAspect = isSlide ? (16 / 9) : (210 / 297);

    return Container(
      color: deskBg,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPortrait ? 8.0 : 16.0,
            vertical: 12.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visual mock disclaimer banner if annotated
              if (_annotated)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF92400E).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: gold.withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.palette_outlined, size: 13, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'BẢN MẪU GIAO DIỆN: LỚP CHÚ THÍCH VECTOR ĐỘC LẬP • CHƯA PERSIST .BFLY',
                        style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.4),
                      ),
                    ],
                  ),
                ),

              // Document Paper / Slide Container
              Flexible(
                child: AspectRatio(
                  aspectRatio: targetAspect,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161D26) : Colors.white,
                      borderRadius: BorderRadius.circular(isSlide ? 6 : 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Base document rasterized page
                        ClipRRect(
                          borderRadius: BorderRadius.circular(isSlide ? 6 : 2),
                          child: Image.asset(
                            pageAsset,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Annotation Overlay (if enabled)
                        if (_annotated)
                          Positioned.fill(
                            child: ConceptAAnnotationOverlay(
                              isSlide: isSlide,
                              isDark: isDark,
                              showEraserCircle: _activeTool == 'eraser',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTray(Color headerBg, Color gold, bool isDark, bool isSlide, bool isPortrait) {
    final compactMode = isPortrait || widget.isCompact;

    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: compactMode ? 8 : 16),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white12 : gold.withValues(alpha: 0.35), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Page Navigation buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!compactMode)
                IconButton(
                  icon: const Icon(Icons.first_page, color: Colors.white70, size: 20),
                  tooltip: 'Về đầu',
                  onPressed: () => setState(() => _currentPage = 0),
                ),
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                tooltip: 'Trang trước',
                onPressed: _currentPage > 0 ? _previousPage : null,
              ),
              Text(
                '${_currentPage + 1} / ${_doc.pageCount}',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                tooltip: 'Trang tiếp',
                onPressed: _currentPage < _doc.pageAssets.length - 1 ? _nextPage : null,
              ),
              if (!compactMode)
                IconButton(
                  icon: const Icon(Icons.last_page, color: Colors.white70, size: 20),
                  tooltip: 'Về cuối',
                  onPressed: () => setState(() => _currentPage = _doc.pageAssets.length - 1),
                ),
            ],
          ),

          // Center: Annotation Tools (Desk Tray)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToolPill(
                      icon: Icons.edit,
                      label: compactMode ? '' : 'Bút viết',
                      isActive: _annotated && _activeTool == 'pen',
                      color: const Color(0xFFDC2626),
                      onTap: () {
                        setState(() {
                          _annotated = true;
                          _activeTool = 'pen';
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    _buildToolPill(
                      icon: Icons.brush,
                      label: compactMode ? '' : 'Dạ quang',
                      isActive: _annotated && _activeTool == 'highlighter',
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        setState(() {
                          _annotated = true;
                          _activeTool = 'highlighter';
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    _buildToolPill(
                      icon: Icons.auto_fix_normal,
                      label: compactMode ? '' : 'Tẩy',
                      isActive: _annotated && _activeTool == 'eraser',
                      color: Colors.amber,
                      onTap: () {
                        setState(() {
                          _annotated = true;
                          _activeTool = 'eraser';
                        });
                      },
                    ),
                    if (_annotated) ...[
                      const VerticalDivider(width: 12, indent: 4, endIndent: 4, color: Colors.white24),
                      IconButton(
                        icon: const Icon(Icons.undo, color: Colors.white70, size: 16),
                        tooltip: 'Hoàn tác',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.redo, color: Colors.white70, size: 16),
                        tooltip: 'Làm lại',
                        onPressed: () {},
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Right: Reading status & toggle annotate
          compactMode
              ? IconButton(
                  icon: Icon(
                    _annotated ? Icons.visibility : Icons.draw_outlined,
                    size: 20,
                    color: gold,
                  ),
                  tooltip: _annotated ? 'Ẩn ghi chú' : 'Thêm ghi chú',
                  onPressed: () => setState(() => _annotated = !_annotated),
                )
              : TextButton.icon(
                  icon: Icon(
                    _annotated ? Icons.visibility : Icons.draw_outlined,
                    size: 16,
                    color: gold,
                  ),
                  label: Text(
                    _annotated ? 'Ẩn ghi chú' : 'Thêm ghi chú',
                    style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => setState(() => _annotated = !_annotated),
                ),
        ],
      ),
    );
  }

  Widget _buildToolPill({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 6 : 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? color : Colors.white70),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDialog(Color surfaceBg, Color gold, bool isDark) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _infoDialogVisible = false),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {}, // prevent tap through
            child: Container(
              width: 480,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold.withValues(alpha: 0.8), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 16)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.info, color: gold, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THÔNG TIN TÀI LIỆU',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _doc.title,
                              style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _infoDialogVisible = false),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Định dạng:', _doc.sourceFormat, isDark),
                  _buildInfoRow('Số trang / slide:', '${_doc.pageCount} trang', isDark),
                  _buildInfoRow('Dung lượng tệp:', _doc.fileSize, isDark),
                  _buildInfoRow('Tỷ lệ hiển thị:', _doc.type == LabDocumentType.slides ? '16:9 Landscape' : 'A4 (210 × 297 mm)', isDark),
                  _buildInfoRow('Lớp chú thích:', _annotated ? 'Đang kích hoạt (Lớp vẽ vector độc lập)' : 'Chưa có chú thích', isDark),
                  _buildInfoRow('Ghi chú tương thích:', 'Không làm biến dạng file gốc; giữ nguyên tọa độ bút.', isDark),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => setState(() => _infoDialogVisible = false),
                      child: const Text('Đóng'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
