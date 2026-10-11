// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../core/models/note_document.dart';
import '../drawing/canvas_controller.dart';
import 'pen_studio_panel.dart';

/// Primary inking controls stay visible; secondary settings use one menu.
class ToolbarWidget extends StatelessWidget {
  final CanvasController controller;
  final VoidCallback? onEnterZen;

  static const continuousPaperTooltip = 'Continuous Paper (Tap for A4 Writing)';
  static const a4WritingTooltip =
      'A4 Writing (Tap to disable)\nStart inside a page; strokes may cross edges.';

  const ToolbarWidget({super.key, required this.controller, this.onEnterZen});

  static const _palette = <String, Color>{
    'Black': Color(0xFF1E1E1E),
    'Blue': Color(0xFF1565C0),
    'Red': Color(0xFFC62828),
    'Green': Color(0xFF2E7D32),
    'Orange': Color(0xFFEF6C00),
    'Purple': Color(0xFF6A1B9A),
  };
  static const _widths = <String, double>{'Fine': 2, 'Normal': 3.5, 'Bold': 6};

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final theme = Theme.of(context);
          final narrow = constraints.maxWidth < 360;
          final showInkSettings = constraints.maxWidth >= 480;
          final tools = [
            _toolButton(
              context,
              CanvasTool.pen,
              Icons.edit_outlined,
              Icons.edit,
              'Pen',
            ),
            _toolButton(
              context,
              CanvasTool.highlighter,
              Icons.highlight_outlined,
              Icons.highlight,
              'Highlighter',
            ),
            _toolButton(
              context,
              CanvasTool.eraser,
              Icons.auto_fix_normal_outlined,
              Icons.auto_fix_normal,
              'Stroke Eraser',
            ),
          ];
          final history = [
            _button(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: controller.canUndo ? controller.undo : null,
            ),
            _button(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
              onPressed: controller.canRedo ? controller.redo : null,
            ),
          ];
          final settings = [
            if (showInkSettings && controller.tool != CanvasTool.eraser) ...[
              PopupMenuButton<String>(
                tooltip: 'Ink Color',
                constraints: const BoxConstraints(minWidth: 180),
                icon: Icon(Icons.circle, color: controller.color, size: 22),
                onSelected: (label) => controller.setColor(_palette[label]!),
                itemBuilder: (_) => _colorItems(),
              ),
              _button(
                tooltip: 'Pen Studio',
                icon: const Icon(Icons.tune),
                onPressed: () => _openPenStudio(context),
              ),
            ],
            if (constraints.maxWidth >= 560 && controller.showA4Guides)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'A4',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            if (constraints.maxWidth >= 560 && controller.stylusOnlyMode)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.draw, size: 18),
              ),
            PopupMenuButton<String>(
              tooltip: 'Drawing Options',
              icon: Icon(
                Icons.more_horiz,
                color: controller.showA4Guides || controller.stylusOnlyMode
                    ? theme.colorScheme.primary
                    : null,
              ),
              onSelected: (value) => _selectOption(context, value),
              itemBuilder: (_) => _optionItems(showInkSettings),
            ),
            if (onEnterZen != null)
              _button(
                icon: const Icon(Icons.fullscreen),
                tooltip: 'Enter Zen',
                onPressed: onEnterZen,
              ),
          ];
          return Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.95,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: narrow
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [...tools, const Spacer(), ...settings]),
                        Row(children: history),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...tools,
                        const SizedBox(width: 8),
                        ...history,
                        const Spacer(),
                        ...settings,
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _button({
    required Widget icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      icon: icon,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  Widget _toolButton(
    BuildContext context,
    CanvasTool tool,
    IconData icon,
    IconData selectedIcon,
    String tooltip,
  ) {
    final selected = controller.tool == tool;
    final theme = Theme.of(context);
    return IconButton(
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      tooltip: tooltip,
      isSelected: selected,
      icon: Icon(icon, size: 22),
      selectedIcon: Icon(selectedIcon, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        foregroundColor: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
      ),
      onPressed: () => controller.setTool(tool),
    );
  }

  List<PopupMenuEntry<String>> _colorItems({String prefix = ''}) => [
    for (final entry in _palette.entries)
      CheckedPopupMenuItem(
        value: '$prefix${entry.key}',
        checked: controller.color.toARGB32() == entry.value.toARGB32(),
        child: Row(
          children: [
            Icon(Icons.circle, size: 18, color: entry.value),
            const SizedBox(width: 12),
            Text(entry.key),
          ],
        ),
      ),
  ];

  List<PopupMenuEntry<String>> _widthItems({String prefix = ''}) => [
    for (final entry in _widths.entries)
      CheckedPopupMenuItem(
        value: '$prefix${entry.key}',
        checked: (controller.strokeWidth - entry.value).abs() < 0.1,
        child: Text(entry.key),
      ),
  ];

  List<PopupMenuEntry<String>> _optionItems(bool showInkSettings) => [
    const PopupMenuItem<String>(value: 'studio', child: Text('Pen Studio')),
    if (!showInkSettings && controller.tool != CanvasTool.eraser) ...[
      ..._colorItems(prefix: 'color:'),
      const PopupMenuDivider(),
    ],
    if (controller.tool != CanvasTool.eraser) ...[
      ..._widthItems(prefix: 'width:'),
      const PopupMenuDivider(),
    ],
    const PopupMenuItem<String>(
      enabled: false,
      child: Tooltip(message: 'Paper Template', child: Text('Paper Template')),
    ),
    for (final entry in <PaperTemplate, String>{
      PaperTemplate.ruled: 'Ruled Paper',
      PaperTemplate.grid: 'Grid / Graph Paper',
      PaperTemplate.blank: 'Blank Canvas',
    }.entries)
      CheckedPopupMenuItem(
        value: 'paper:${entry.key.name}',
        checked: controller.document.paperTemplate == entry.key,
        child: Text(entry.value),
      ),
    const PopupMenuDivider(),
    CheckedPopupMenuItem(
      value: 'stylus',
      checked: controller.stylusOnlyMode,
      child: Tooltip(
        message: controller.stylusOnlyMode
            ? 'Stylus-Only Active (Fingers Pan Canvas)'
            : 'Finger Inking Allowed (Tap to enable Stylus-Only)',
        child: const Text('Stylus-only input'),
      ),
    ),
    CheckedPopupMenuItem<String>(
      key: const ValueKey('a4-option'),
      value: 'a4',
      checked: controller.showA4Guides,
      child: Tooltip(
        message: controller.showA4Guides
            ? a4WritingTooltip
            : continuousPaperTooltip,
        child: const Text('A4 Writing'),
      ),
    ),
    if (controller.showA4Guides)
      const PopupMenuItem<String>(
        value: 'fit',
        child: Tooltip(message: 'Fit to Width', child: Text('Fit to Width')),
      ),
    if (controller.zoomScale != 1 || controller.viewportOffset != Offset.zero)
      PopupMenuItem<String>(
        value: 'reset',
        child: Tooltip(
          message: 'Reset View',
          child: Text('Reset View (${(controller.zoomScale * 100).round()}%)'),
        ),
      ),
    const PopupMenuDivider(),
    const PopupMenuItem<String>(
      value: 'clear',
      child: Tooltip(message: 'Clear Canvas', child: Text('Clear Canvas')),
    ),
  ];

  void _selectOption(BuildContext context, String value) {
    if (value.startsWith('color:')) {
      controller.setColor(_palette[value.substring(6)]!);
    } else if (value.startsWith('width:')) {
      controller.setStrokeWidth(_widths[value.substring(6)]!);
    } else if (value.startsWith('paper:')) {
      controller.setPaperTemplate(
        PaperTemplate.values.byName(value.substring(6)),
      );
    } else {
      switch (value) {
        case 'studio':
          _openPenStudio(context);
        case 'stylus':
          controller.setStylusOnlyMode(!controller.stylusOnlyMode);
        case 'a4':
          controller.toggleA4Guides();
        case 'fit':
          controller.fitToWidth(MediaQuery.sizeOf(context).width);
        case 'reset':
          controller.resetViewport();
        case 'clear':
          _confirmClear(context);
      }
    }
  }

  void _openPenStudio(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => PenStudioPanel(controller: controller),
  );

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text(
          'Are you sure you want to clear all strokes? This can be undone.',
        ),
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
