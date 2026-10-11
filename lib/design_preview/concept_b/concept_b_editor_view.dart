// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../mock_data.dart';

class ConceptBEditorView extends StatefulWidget {
  final bool isDark;
  final bool isPortrait;
  final VoidCallback? onOpenStudio;

  const ConceptBEditorView({
    super.key,
    this.isDark = false,
    this.isPortrait = false,
    this.onOpenStudio,
  });

  @override
  State<ConceptBEditorView> createState() => _ConceptBEditorViewState();
}

class _ConceptBEditorViewState extends State<ConceptBEditorView> {
  int _activeToolIndex = 0; // 0: Fine Pen, 1: Gel Pen, 2: Highlighter, 3: Eraser, 4: Lasso, 5: Ruler
  bool _sidebarOpen = true;

  @override
  void initState() {
    super.initState();
    if (widget.isPortrait) {
      _sidebarOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isPortrait = widget.isPortrait;

    final bg = isDark ? const Color(0xFF090B10) : const Color(0xFFF1F5F9);
    final headerBg = isDark ? const Color(0xFF11141C).withValues(alpha: 0.92) : const Color(0xFFFFFFFF).withValues(alpha: 0.92);
    final sidebarBg = isDark ? const Color(0xFF11141C) : const Color(0xFFFFFFFF);
    final paperBg = isDark ? const Color(0xFF161B26) : const Color(0xFFFFFFFF);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cobalt = const Color(0xFF0052FF);
    final borderCol = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Studio Workspace Breadcrumb Header
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: headerBg,
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: Row(
                children: [
                  // Back Button
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios_new, size: 13, color: textPrimary),
                          const SizedBox(width: 6),
                          Text(
                            'Không gian',
                            style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Toggle Sidebar Button
                  IconButton(
                    icon: Icon(
                      _sidebarOpen ? Icons.view_sidebar : Icons.view_sidebar_outlined,
                      size: 20,
                      color: _sidebarOpen ? cobalt : textSecondary,
                    ),
                    tooltip: 'Trang & Dàn ý',
                    onPressed: () {
                      setState(() {
                        _sidebarOpen = !_sidebarOpen;
                      });
                    },
                  ),

                  const SizedBox(width: 8),

                  // Breadcrumb & Title
                  Expanded(
                    child: Row(
                      children: [
                        if (!isPortrait)
                          Text(
                            'Toán học & Giải tích  /  ',
                            style: TextStyle(color: textSecondary, fontSize: 13),
                          ),
                        Flexible(
                          child: Text(
                            'Đại số tuyến tính — Học kỳ I',
                            style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isPortrait) ...[
                          const SizedBox(width: 10),
                          // Cloud sync pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cloud_done, size: 12, color: Color(0xFF10B981)),
                                SizedBox(width: 4),
                                Text(
                                  'Đã đồng bộ',
                                  style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions right
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Undo / Redo
                      IconButton(
                        icon: Icon(Icons.undo, size: 19, color: textSecondary),
                        tooltip: 'Hoàn tác (Undo)',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.redo, size: 19, color: textSecondary),
                        tooltip: 'Làm lại (Redo)',
                        onPressed: () {},
                      ),

                      const SizedBox(width: 4),

                      // Zoom Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '100%',
                          style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Export / Share
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cobalt,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.share_outlined, size: 15),
                        label: const Text('Xuất file', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Main Workspace Body: Sidebar + Canvas Area with Floating Dock
            Expanded(
              child: Row(
                children: [
                  // Collapsible Page Thumbnails Rail
                  if (_sidebarOpen && !isPortrait)
                    Container(
                      width: 190,
                      decoration: BoxDecoration(
                        color: sidebarBg,
                        border: Border(right: BorderSide(color: borderCol)),
                      ),
                      child: Column(
                        children: [
                          // Rail Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  'TRANG (1/16)',
                                  style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(Icons.add, size: 18, color: cobalt),
                                  tooltip: 'Thêm trang mới',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              children: [
                                _buildPageThumbnail(
                                  pageNumber: 1,
                                  title: 'Định lý ma trận',
                                  isSelected: true,
                                  isDark: isDark,
                                  cobalt: cobalt,
                                ),
                                const SizedBox(height: 12),
                                _buildPageThumbnail(
                                  pageNumber: 2,
                                  title: 'Hệ phương trình',
                                  isSelected: false,
                                  isDark: isDark,
                                  cobalt: cobalt,
                                ),
                                const SizedBox(height: 12),
                                _buildPageThumbnail(
                                  pageNumber: 3,
                                  title: 'Không gian Vector',
                                  isSelected: false,
                                  isDark: isDark,
                                  cobalt: cobalt,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Main Canvas Workspace with Floating Dynamic Island Dock
                  Expanded(
                    child: Stack(
                      children: [
                        // The Canvas Surface
                        Positioned.fill(
                          child: SingleChildScrollView(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                child: Container(
                                  width: isPortrait ? 760 : 840,
                                  height: 1188,
                                  decoration: BoxDecoration(
                                    color: paperBg,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CustomPaint(
                                      size: Size(isPortrait ? 760 : 840, 1188),
                                      painter: MockAcademicHandwritingPainter(
                                        isDark: isDark,
                                        showA4Guides: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Floating Dynamic Island Capsule Dock
                        Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (isDark ? const Color(0xFF11141C) : Colors.white).withValues(alpha: 0.88),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.1),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark ? Colors.black54 : Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Pen 1: Fine Liner (1.2mm, Oxford Blue)
                                      _buildDockTool(
                                        index: 0,
                                        icon: Icons.edit,
                                        label: 'Bút mực',
                                        spec: '1.2mm',
                                        dotColor: const Color(0xFF0052FF),
                                        isSelected: _activeToolIndex == 0,
                                        cobalt: cobalt,
                                        isDark: isDark,
                                        onTap: () {
                                          setState(() => _activeToolIndex = 0);
                                          widget.onOpenStudio?.call();
                                        },
                                      ),

                                      const SizedBox(width: 6),

                                      // Pen 2: Gel Pen (2.4mm, Emerald)
                                      _buildDockTool(
                                        index: 1,
                                        icon: Icons.border_color,
                                        label: 'Bút gel',
                                        spec: '2.4mm',
                                        dotColor: const Color(0xFF10B981),
                                        isSelected: _activeToolIndex == 1,
                                        cobalt: cobalt,
                                        isDark: isDark,
                                        onTap: () {
                                          setState(() => _activeToolIndex = 1);
                                          widget.onOpenStudio?.call();
                                        },
                                      ),

                                      const SizedBox(width: 6),

                                      // Pen 3: Highlighter (18mm, Gold/Amber)
                                      _buildDockTool(
                                        index: 2,
                                        icon: Icons.brush,
                                        label: 'Dạ quang',
                                        spec: '18mm',
                                        dotColor: const Color(0xFFF59E0B),
                                        isSelected: _activeToolIndex == 2,
                                        cobalt: cobalt,
                                        isDark: isDark,
                                        onTap: () {
                                          setState(() => _activeToolIndex = 2);
                                          widget.onOpenStudio?.call();
                                        },
                                      ),

                                      const SizedBox(width: 8),
                                      Container(height: 28, width: 1, color: borderCol),
                                      const SizedBox(width: 8),

                                      // Eraser
                                      _buildDockIconTool(
                                        index: 3,
                                        icon: Icons.auto_fix_high,
                                        tooltip: 'Tẩy xoá theo nét / vùng',
                                        isSelected: _activeToolIndex == 3,
                                        cobalt: cobalt,
                                        isDark: isDark,
                                        onTap: () => setState(() => _activeToolIndex = 3),
                                      ),

                                      // Selection Lasso
                                      _buildDockIconTool(
                                        index: 4,
                                        icon: Icons.gesture,
                                        tooltip: 'Vùng chọn Lasso',
                                        isSelected: _activeToolIndex == 4,
                                        cobalt: cobalt,
                                        isDark: isDark,
                                        onTap: () => setState(() => _activeToolIndex = 4),
                                      ),

                                      // Ruler / Guide
                                      _buildDockIconTool(
                                        index: 5,
                                        icon: Icons.straighten,
                                        tooltip: 'Thước kẻ & Hình học',
                                        isSelected: _activeToolIndex == 5,
                                        cobalt: cobalt,
                                        isDark: isDark,
                                        onTap: () => setState(() => _activeToolIndex = 5),
                                      ),

                                      const SizedBox(width: 8),
                                      Container(height: 28, width: 1, color: borderCol),
                                      const SizedBox(width: 8),

                                      // Trigger Studio button
                                      InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: widget.onOpenStudio,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: cobalt.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: cobalt.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.tune, size: 14, color: cobalt),
                                              const SizedBox(width: 5),
                                              Text(
                                                'Pen Studio',
                                                style: TextStyle(
                                                  color: cobalt,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
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
                            ),
                          ),
                        ),
                      ),

                        // Bottom-Right Floating Controls (Fit Page, Zen Mode)
                        Positioned(
                          right: 20,
                          bottom: 20,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF11141C) : Colors.white).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderCol),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.aspect_ratio, size: 15, color: textSecondary),
                                    const SizedBox(width: 6),
                                    Text('Vừa khổ A4', style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF11141C) : Colors.white).withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderCol),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.fullscreen, size: 20, color: textPrimary),
                                  tooltip: 'Chế độ tập trung (Zen)',
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildDockTool({
    required int index,
    required IconData icon,
    required String label,
    required String spec,
    required Color dotColor,
    required bool isSelected,
    required Color cobalt,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? cobalt.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? cobalt : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Tool Icon
            Icon(
              icon,
              size: 16,
              color: isSelected ? cobalt : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 6),
            // Live Stroke Silhouette: Color dot + size badge
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: dotColor.withValues(alpha: 0.4), blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              spec,
              style: TextStyle(
                color: isSelected ? cobalt : (isDark ? Colors.white60 : Colors.black54),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockIconTool({
    required int index,
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required Color cobalt,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 19,
        color: isSelected ? cobalt : (isDark ? Colors.white70 : Colors.black87),
      ),
      tooltip: tooltip,
      onPressed: onTap,
    );
  }

  Widget _buildPageThumbnail({
    required int pageNumber,
    required String title,
    required bool isSelected,
    required bool isDark,
    required Color cobalt,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? cobalt.withValues(alpha: 0.12)
            : (isDark ? const Color(0xFF161B26) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? cobalt : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aspect miniature sheet preview
          Container(
            height: 95,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F131A) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black12),
            ),
            child: Center(
              child: Icon(
                Icons.description_outlined,
                size: 24,
                color: isSelected ? cobalt : (isDark ? Colors.white38 : Colors.black26),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'P.$pageNumber',
                style: TextStyle(
                  color: isSelected ? cobalt : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 10.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
