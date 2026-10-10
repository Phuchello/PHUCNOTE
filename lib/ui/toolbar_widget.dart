// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../core/models/note_document.dart';
import '../drawing/canvas_controller.dart';

/// Ergonomic tablet-first floating toolbar for inking tools, colors, widths, templates,
/// and stylus-only inking mode.
class ToolbarWidget extends StatelessWidget {
  final CanvasController controller;

  const ToolbarWidget({
    super.key,
    required this.controller,
  });

  static const List<Color> _paletteColors = [
    Color(0xFF1E1E1E), // Obsidian Black
    Color(0xFF1565C0), // Academic Blue
    Color(0xFFC62828), // Crimson Red
    Color(0xFF2E7D32), // Forest Green
    Color(0xFFEF6C00), // Amber Orange
    Color(0xFF6A1B9A), // Deep Purple
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                // Tool Selectors
                _buildToolButton(
                  context,
                  tool: CanvasTool.pen,
                  icon: Icons.edit_outlined,
                  selectedIcon: Icons.edit,
                  tooltip: 'Pen',
                ),
                _buildToolButton(
                  context,
                  tool: CanvasTool.highlighter,
                  icon: Icons.highlight_outlined,
                  selectedIcon: Icons.highlight,
                  tooltip: 'Highlighter',
                ),
                _buildToolButton(
                  context,
                  tool: CanvasTool.eraser,
                  icon: Icons.auto_fix_normal_outlined,
                  selectedIcon: Icons.auto_fix_normal,
                  tooltip: 'Stroke Eraser',
                ),

                const SizedBox(height: 24, child: VerticalDivider(width: 16)),

                // Color Chips (only when not in eraser mode)
                if (controller.tool != CanvasTool.eraser) ...[
                  for (final c in _paletteColors)
                    _buildColorChip(c, isSelected: controller.color.toARGB32() == c.toARGB32()),
                  const SizedBox(height: 24, child: VerticalDivider(width: 16)),
                ],

                // Stroke Width Chips
                _buildWidthChip(2.0, label: 'Fine'),
                _buildWidthChip(3.5, label: 'Normal'),
                _buildWidthChip(6.0, label: 'Bold'),

                const SizedBox(height: 24, child: VerticalDivider(width: 16)),

                // Stylus-only inking toggle
                IconButton(
                  icon: Icon(
                    controller.stylusOnlyMode ? Icons.draw : Icons.touch_app,
                    size: 20,
                    color: controller.stylusOnlyMode ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: controller.stylusOnlyMode
                      ? 'Stylus-Only Active (Fingers Pan Canvas)'
                      : 'Finger Inking Allowed (Tap to enable Stylus-Only)',
                  onPressed: () => controller.setStylusOnlyMode(!controller.stylusOnlyMode),
                ),

                // Paper Template Popup
                PopupMenuButton<PaperTemplate>(
                  tooltip: 'Paper Template',
                  icon: const Icon(Icons.grid_4x4, size: 20),
                  onSelected: controller.setPaperTemplate,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: PaperTemplate.ruled,
                      child: Text('Ruled Paper'),
                    ),
                    const PopupMenuItem(
                      value: PaperTemplate.grid,
                      child: Text('Grid / Graph Paper'),
                    ),
                    const PopupMenuItem(
                      value: PaperTemplate.blank,
                      child: Text('Blank Canvas'),
                    ),
                  ],
                ),

                // Undo / Redo
                IconButton(
                  icon: const Icon(Icons.undo, size: 20),
                  tooltip: 'Undo',
                  onPressed: controller.canUndo ? controller.undo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo, size: 20),
                  tooltip: 'Redo',
                  onPressed: controller.canRedo ? controller.redo : null,
                ),

                // Clear
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Clear Canvas',
                  onPressed: () => _confirmClear(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required CanvasTool tool,
    required IconData icon,
    required IconData selectedIcon,
    required String tooltip,
  }) {
    final isSelected = controller.tool == tool;
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => controller.setTool(tool),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isSelected ? selectedIcon : icon,
            size: 22,
            color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildColorChip(Color color, {required bool isSelected}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => controller.setColor(color),
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.black26,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1)]
              : null,
        ),
      ),
    );
  }

  Widget _buildWidthChip(double width, {required String label}) {
    final isSelected = (controller.strokeWidth - width).abs() < 0.1;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => controller.setStrokeWidth(width),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black12 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text('Are you sure you want to clear all strokes? This can be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.clearCanvas();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
