// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'concept_b_editor_view.dart';

class ConceptBStudioView extends StatefulWidget {
  final bool isDark;

  const ConceptBStudioView({super.key, this.isDark = false});

  @override
  State<ConceptBStudioView> createState() => _ConceptBStudioViewState();
}

class _ConceptBStudioViewState extends State<ConceptBStudioView> {
  int _selectedColorIndex = 0;
  double _strokeWidth = 2.4;
  double _opacity = 0.95;
  double _smoothing = 0.80;
  double _pressureSens = 0.70;

  static const List<Map<String, dynamic>> _palette = [
    {'name': 'Cobalt Blue', 'color': Color(0xFF0052FF), 'hex': '#0052FF'},
    {'name': 'Deep Navy', 'color': Color(0xFF0F172A), 'hex': '#0F172A'},
    {'name': 'Emerald', 'color': Color(0xFF10B981), 'hex': '#10B981'},
    {'name': 'Amber Gold', 'color': Color(0xFFF59E0B), 'hex': '#F59E0B'},
    {'name': 'Crimson', 'color': Color(0xFFEF4444), 'hex': '#EF4444'},
    {'name': 'Violet', 'color': Color(0xFF8B5CF6), 'hex': '#8B5CF6'},
    {'name': 'Cyan Tech', 'color': Color(0xFF06B6D4), 'hex': '#06B6D4'},
    {'name': 'Slate Grey', 'color': Color(0xFF64748B), 'hex': '#64748B'},
    {'name': 'Neon Rose', 'color': Color(0xFFEC4899), 'hex': '#EC4899'},
    {'name': 'Lime Green', 'color': Color(0xFF84CC16), 'hex': '#84CC16'},
    {'name': 'Orange Punch', 'color': Color(0xFFF97316), 'hex': '#F97316'},
    {'name': 'Teal Wave', 'color': Color(0xFF14B8A6), 'hex': '#14B8A6'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cobalt = const Color(0xFF0052FF);
    final popoverBg = isDark ? const Color(0xFF11141C).withValues(alpha: 0.94) : const Color(0xFFFFFFFF).withValues(alpha: 0.96);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.12);

    return Scaffold(
      body: Stack(
        children: [
          // Underlying Studio Workspace Editor is visible in background
          Positioned.fill(
            child: ConceptBEditorView(isDark: isDark),
          ),

          // Translucent frosted scrim
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.25),
              ),
            ),
          ),

          // Floating Glass Studio Popover anchored beneath the dynamic island
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 580,
                  constraints: const BoxConstraints(maxHeight: 700),
                  decoration: BoxDecoration(
                    color: popoverBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderCol, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black87 : Colors.black.withValues(alpha: 0.2),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Popover Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: borderCol)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cobalt.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.tune, color: cobalt, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PEN STUDIO — THIẾT LẬP NGÒI BÚT',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Điều chỉnh nét vector và khay màu mực',
                                    style: TextStyle(color: textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: textSecondary, size: 20),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      // 2. Popover Scrollable Content (No Slicing, Spacious Grid!)
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Live Dynamic Stroke Simulator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'MÔ PHỎNG NÉT VẼ ĐỘNG',
                                    style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                                  ),
                                  Text(
                                    'Bút gel — Tốc độ lấy mẫu 120Hz',
                                    style: TextStyle(color: cobalt, fontSize: 10.5, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF090B10) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderCol),
                                ),
                                child: CustomPaint(
                                  size: const Size(540, 80),
                                  painter: _DynamicStrokePreviewPainter(
                                    strokeColor: _palette[_selectedColorIndex]['color'] as Color,
                                    strokeWidth: _strokeWidth,
                                    opacity: _opacity,
                                    isDark: isDark,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Precision Sliders with Value Badges
                              Text(
                                'THÔNG SỐ KỸ THUẬT NGÒI',
                                style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                              ),
                              const SizedBox(height: 10),

                              _buildStudioSlider(
                                label: 'Cỡ ngòi (Stroke Width)',
                                valueText: '${_strokeWidth.toStringAsFixed(1)} mm',
                                value: _strokeWidth / 8.0,
                                cobalt: cobalt,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onChanged: (v) => setState(() => _strokeWidth = (v * 8.0).clamp(0.5, 8.0)),
                              ),
                              _buildStudioSlider(
                                label: 'Độ đậm mực (Opacity)',
                                valueText: '${(_opacity * 100).toInt()}%',
                                value: _opacity,
                                cobalt: cobalt,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onChanged: (v) => setState(() => _opacity = v.clamp(0.1, 1.0)),
                              ),
                              _buildStudioSlider(
                                label: 'Làm mượt nét (Smoothing)',
                                valueText: '${(_smoothing * 100).toInt()}%',
                                value: _smoothing,
                                cobalt: cobalt,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onChanged: (v) => setState(() => _smoothing = v.clamp(0.0, 1.0)),
                              ),
                              _buildStudioSlider(
                                label: 'Độ nhạy lực ấn (Pressure)',
                                valueText: '${(_pressureSens * 100).toInt()}%',
                                value: _pressureSens,
                                cobalt: cobalt,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onChanged: (v) => setState(() => _pressureSens = v.clamp(0.0, 1.0)),
                              ),

                              const SizedBox(height: 18),

                              // UNCLIPPED 12-COLOR HIGH-CONTRAST PALETTE
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'BẢNG MÀU STUDIO (12 SẮC MÀU)',
                                    style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                                  ),
                                  Text(
                                    'Đang chọn: ${_palette[_selectedColorIndex]['name']}',
                                    style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Generously spaced 2-row color grid with NO SLICING
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF090B10) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderCol),
                                ),
                                child: Column(
                                  children: [
                                    // Row 1 (first 6 colors)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(6, (i) {
                                        return _buildColorWell(
                                          index: i,
                                          data: _palette[i],
                                          isSelected: _selectedColorIndex == i,
                                          cobalt: cobalt,
                                          isDark: isDark,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 12),
                                    // Row 2 (next 6 colors)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(6, (i) {
                                        final index = i + 6;
                                        return _buildColorWell(
                                          index: index,
                                          data: _palette[index],
                                          isSelected: _selectedColorIndex == index,
                                          cobalt: cobalt,
                                          isDark: isDark,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. Popover Footer Actions
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF090B10) : const Color(0xFFF1F5F9),
                          border: Border(top: BorderSide(color: borderCol)),
                        ),
                        child: Row(
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.restart_alt, size: 16),
                              label: const Text('Mặc định', style: TextStyle(fontSize: 12.5)),
                              style: TextButton.styleFrom(foregroundColor: textSecondary),
                              onPressed: () {},
                            ),
                            const Spacer(),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textPrimary,
                                side: BorderSide(color: borderCol),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {},
                              child: const Text('Lưu mẫu mới', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cobalt,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {},
                              child: const Text('Áp dụng ngòi này', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildStudioSlider({
    required String label,
    required String valueText,
    required double value,
    required Color cobalt,
    required Color textPrimary,
    required Color textSecondary,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cobalt.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(color: cobalt, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3.5,
              activeTrackColor: cobalt,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.25),
              thumbColor: cobalt,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorWell({
    required int index,
    required Map<String, dynamic> data,
    required bool isSelected,
    required Color cobalt,
    required bool isDark,
  }) {
    final color = data['color'] as Color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? cobalt : (isDark ? Colors.white24 : Colors.black12),
                width: isSelected ? 3.0 : 1.2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(color: cobalt.withValues(alpha: 0.45), blurRadius: 8),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            data['hex'] as String,
            style: TextStyle(
              color: isSelected ? cobalt : (isDark ? Colors.white38 : Colors.black38),
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicStrokePreviewPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final double opacity;
  final bool isDark;

  _DynamicStrokePreviewPainter({
    required this.strokeColor,
    required this.strokeWidth,
    required this.opacity,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle background grid
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04))
      ..strokeWidth = 1.0;
    for (double x = 20; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final paint = Paint()
      ..color = strokeColor.withValues(alpha: opacity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw dynamic pressure wave
    final path = Path();
    path.moveTo(30, size.height * 0.5);
    path.cubicTo(
      size.width * 0.25, size.height * 0.15,
      size.width * 0.35, size.height * 0.85,
      size.width * 0.55, size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.70, size.height * 0.15,
      size.width * 0.85, size.height * 0.75,
      size.width - 40, size.height * 0.5,
    );

    // Simulated tapered pressure stroke
    paint.strokeWidth = strokeWidth * 1.5;
    canvas.drawPath(path, paint);

    // Mathematical formula text overlay
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'f(t) = sin(ωt) · e^(-λt)   [Tapered Vector Ink]',
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const Offset(30, 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
