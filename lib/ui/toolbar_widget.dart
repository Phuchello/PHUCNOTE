// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../core/models/note_document.dart';
import '../drawing/canvas_controller.dart';
import 'pen_studio_panel.dart';
import '../l10n/l10n.dart';
import 'app_theme.dart';
import 'ink_palette.dart';

/// Primary inking controls stay visible; secondary settings use one menu.
class ToolbarWidget extends StatelessWidget {
  final CanvasController controller;
  final VoidCallback? onEnterZen;

  const ToolbarWidget({super.key, required this.controller, this.onEnterZen});

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
              context.l10n.pen,
            ),
            _toolButton(
              context,
              CanvasTool.highlighter,
              Icons.highlight_outlined,
              Icons.highlight,
              context.l10n.highlighter,
            ),
            _toolButton(
              context,
              CanvasTool.eraser,
              Icons.auto_fix_normal_outlined,
              Icons.auto_fix_normal,
              context.l10n.eraser,
            ),
          ];
          final history = [
            _button(
              icon: const Icon(Icons.undo),
              tooltip: context.l10n.undo,
              onPressed: controller.canUndo ? controller.undo : null,
            ),
            _button(
              icon: const Icon(Icons.redo),
              tooltip: context.l10n.redo,
              onPressed: controller.canRedo ? controller.redo : null,
            ),
          ];
          final settings = [
            if (showInkSettings && controller.tool != CanvasTool.eraser) ...[
              PopupMenuButton<String>(
                tooltip: context.l10n.inkColor,
                constraints: const BoxConstraints(minWidth: 180),
                icon: InkSwatch(color: controller.color, selected: true),
                onSelected: (label) => controller.setColor(inkPalette[label]!),
                itemBuilder: (_) => _colorItems(context),
              ),
              _button(
                tooltip: context.l10n.penStudio,
                icon: const Icon(Icons.tune),
                onPressed: () => _openPenStudio(context),
              ),
            ],
            if (constraints.maxWidth >= 560 && controller.showA4Guides)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  context.l10n.a4Badge,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            if (constraints.maxWidth >= 560 && controller.stylusOnlyMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Semantics(
                  label: context.l10n.stylusOnlyActive,
                  child: const Icon(Icons.draw, size: 18),
                ),
              ),
            PopupMenuButton<String>(
              tooltip: context.l10n.drawingOptions,
              icon: Icon(
                Icons.more_horiz,
                color: controller.showA4Guides || controller.stylusOnlyMode
                    ? theme.colorScheme.primary
                    : null,
              ),
              onSelected: (value) => _selectOption(context, value),
              itemBuilder: (_) => _optionItems(context, showInkSettings),
            ),
            if (onEnterZen != null)
              _button(
                icon: const Icon(Icons.fullscreen),
                tooltip: context.l10n.enterZen,
                onPressed: onEnterZen,
              ),
          ];
          return Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StudioTokens.toolbarRadius),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            color: theme.colorScheme.surface,
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
                        SizedBox(
                          width: 8,
                          height: 28,
                          child: VerticalDivider(
                            width: 8,
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
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

  List<PopupMenuEntry<String>> _colorItems(
    BuildContext context, {
    String prefix = '',
  }) => [
    for (final entry in inkPalette.entries)
      CheckedPopupMenuItem(
        value: '$prefix${entry.key}',
        checked: controller.color.toARGB32() == entry.value.toARGB32(),
        child: Row(
          children: [
            InkSwatch(
              color: entry.value,
              selected: controller.color.toARGB32() == entry.value.toARGB32(),
            ),
            const SizedBox(width: 12),
            Text(inkColorLabel(context.l10n, entry.key)),
          ],
        ),
      ),
  ];

  List<PopupMenuEntry<String>> _widthItems(
    BuildContext context, {
    String prefix = '',
  }) => [
    for (final entry in _widths.entries)
      CheckedPopupMenuItem(
        value: '$prefix${entry.key}',
        checked: (controller.strokeWidth - entry.value).abs() < 0.1,
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Container(
                height: entry.value,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(switch (entry.key) {
              'Fine' => context.l10n.widthFine,
              'Normal' => context.l10n.widthNormal,
              _ => context.l10n.widthBold,
            }),
          ],
        ),
      ),
  ];

  List<PopupMenuEntry<String>> _optionItems(
    BuildContext context,
    bool showInkSettings,
  ) => [
    PopupMenuItem<String>(value: 'studio', child: Text(context.l10n.penStudio)),
    if (!showInkSettings && controller.tool != CanvasTool.eraser) ...[
      ..._colorItems(context, prefix: 'color:'),
      const PopupMenuDivider(),
    ],
    if (controller.tool != CanvasTool.eraser) ...[
      ..._widthItems(context, prefix: 'width:'),
      const PopupMenuDivider(),
    ],
    PopupMenuItem<String>(
      enabled: false,
      child: Tooltip(
        message: context.l10n.paperTemplate,
        child: Text(
          context.l10n.paperTemplate,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    ),
    for (final entry in <PaperTemplate, String>{
      PaperTemplate.ruled: context.l10n.paperRuled,
      PaperTemplate.grid: context.l10n.paperGrid,
      PaperTemplate.blank: context.l10n.paperBlank,
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
            ? context.l10n.stylusOnlyActive
            : context.l10n.fingerInkingAllowed,
        child: Text(context.l10n.stylusOnly),
      ),
    ),
    CheckedPopupMenuItem<String>(
      key: const ValueKey('a4-option'),
      value: 'a4',
      checked: controller.showA4Guides,
      child: Tooltip(
        message: controller.showA4Guides
            ? context.l10n.a4WritingHint
            : context.l10n.continuousPaperHint,
        child: Text(context.l10n.a4Mode),
      ),
    ),
    if (controller.showA4Guides)
      PopupMenuItem<String>(
        value: 'fit',
        child: Tooltip(
          message: context.l10n.fitToWidth,
          child: Text(context.l10n.fitToWidth),
        ),
      ),
    if (controller.zoomScale != 1 || controller.viewportOffset != Offset.zero)
      PopupMenuItem<String>(
        value: 'reset',
        child: Tooltip(
          message: context.l10n.resetView,
          child: Text(
            context.l10n.resetViewAt((controller.zoomScale * 100).round()),
          ),
        ),
      ),
    const PopupMenuDivider(),
    PopupMenuItem<String>(
      value: 'clear',
      child: Tooltip(
        message: context.l10n.clearCanvas,
        child: Text(context.l10n.clearCanvas),
      ),
    ),
  ];

  void _selectOption(BuildContext context, String value) {
    if (value.startsWith('color:')) {
      controller.setColor(inkPalette[value.substring(6)]!);
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
        title: Text(context.l10n.clearCanvas),
        content: Text(context.l10n.clearCanvasBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.clearCanvas();
            },
            child: Text(context.l10n.clear),
          ),
        ],
      ),
    );
  }
}
