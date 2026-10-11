import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/models/pen_preset.dart';
import '../core/models/stroke_property.dart';
import '../core/storage/pen_preset_store.dart';
import '../drawing/canvas_controller.dart';
import 'pen_preview.dart';
import '../l10n/l10n.dart';
import 'configuration_panel.dart';
import 'ink_palette.dart';

class PenStudioPanel extends StatefulWidget {
  final CanvasController controller;
  final PenPresetStore? store;
  const PenStudioPanel({super.key, required this.controller, this.store});

  @override
  State<PenStudioPanel> createState() => _PenStudioPanelState();
}

class _PenStudioPanelState extends State<PenStudioPanel> {
  final _personal = <PenPreset>[];
  late final TextEditingController _color;
  PenPreset? _selected;
  bool _loaded = false;
  bool _saving = false;
  String? _error;
  PenPresetStore get _store => widget.store ?? PenPresetStore.instance;

  static String _hex(StrokeProperty property) =>
      (property.colorValue & 0xFFFFFF)
          .toRadixString(16)
          .padLeft(6, '0')
          .toUpperCase();

  @override
  void initState() {
    super.initState();
    _color = TextEditingController(text: _hex(widget.controller.penProperty));
    _load();
  }

  Future<void> _load() async {
    try {
      final presets = await _store.load();
      if (!mounted) return;
      setState(() {
        _personal.addAll(presets);
        _loaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.presetLoadFailed);
      }
    }
  }

  @override
  void dispose() {
    _color.dispose();
    super.dispose();
  }

  void _apply(StrokeProperty property) {
    _color.text = _hex(property);
    widget.controller.setPenProperty(property);
  }

  Future<void> _savePersonal() async {
    var draftName = '';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.savePersonalTitle),
        content: TextField(
          onChanged: (value) => draftName = value,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(labelText: context.l10n.presetName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftName.trim()),
            child: Text(context.l10n.savePreset),
          ),
        ],
      ),
    );
    if (!mounted || name == null) return;
    final reservedNames = [
      ...PenPreset.defaults.map((p) => p.name),
      ...PenPreset.defaults.map(context.presetLabel),
      ..._personal.map((p) => p.name),
    ];
    final validation = name.isEmpty
        ? context.l10n.presetNameRequired
        : name.length > 40
        ? context.l10n.presetNameTooLong
        : reservedNames.any(
            (existing) => existing.toLowerCase() == name.toLowerCase(),
          )
        ? context.l10n.presetNameExists
        : null;
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    final preset = PenPreset(name, widget.controller.penProperty);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _store.save([..._personal, preset]);
      if (!mounted) return;
      setState(() {
        _personal.add(preset);
        _selected = preset;
      });
    } on FormatException catch (_) {
      if (mounted) setState(() => _error = context.l10n.presetInvalid);
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.presetSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _slider(
    String id,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Row(
    children: [
      SizedBox(width: 110, child: Text(label)),
      Expanded(
        child: Slider(
          key: ValueKey('pen-$id'),
          value: value.clamp(min, max),
          min: min,
          max: max,
          label: context.uiDecimal(value),
          onChanged: onChanged,
        ),
      ),
      SizedBox(width: 48, child: Text(context.uiDecimal(value))),
    ],
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final property = widget.controller.penProperty;
      final customized =
          _selected == null ||
          !mapEquals(_selected!.property.toJson(), property.toJson());
      return ConfigurationPanel(
        title: context.l10n.penStudioTitle,
        closeTooltip: context.l10n.closePenStudio,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              customized ? context.l10n.presetCustomized : context.l10n.preset,
            ),
            DropdownButton<PenPreset>(
              key: const ValueKey('pen-preset'),
              value: _selected,
              isExpanded: true,
              hint: Text(context.l10n.currentPen),
              items: [
                for (final preset in [...PenPreset.defaults, ..._personal])
                  DropdownMenuItem(
                    value: preset,
                    child: Text(
                      context.presetLabel(preset),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (preset) {
                if (preset == null) return;
                setState(() => _selected = preset);
                _apply(preset.property);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(context.l10n.fountainExplanation),
            ),
            PenPreview(property: property),
            _slider(
              'Width',
              context.l10n.width,
              property.strokeWidth,
              0.5,
              24,
              (v) => _apply(property.copyWith(strokeWidth: v)),
            ),
            _slider(
              'Opacity',
              context.l10n.opacity,
              property.opacity,
              0,
              1,
              (v) => _apply(property.copyWith(opacity: v)),
            ),
            _slider(
              'Thinning',
              context.l10n.thinning,
              property.thinning,
              -1,
              1,
              (v) => _apply(property.copyWith(thinning: v)),
            ),
            _slider(
              'Smoothing',
              context.l10n.smoothing,
              property.smoothing,
              0,
              1,
              (v) => _apply(property.copyWith(smoothing: v)),
            ),
            _slider(
              'Streamline',
              context.l10n.streamline,
              property.streamline,
              0,
              1,
              (v) => _apply(property.copyWith(streamline: v)),
            ),
            Wrap(
              spacing: 4,
              children: [
                for (final entry in inkPalette.entries)
                  IconButton(
                    tooltip: inkColorLabel(context.l10n, entry.key),
                    isSelected:
                        (property.colorValue & 0xFFFFFF) ==
                        (entry.value.toARGB32() & 0xFFFFFF),
                    onPressed: () => _apply(
                      property.copyWith(colorValue: entry.value.toARGB32()),
                    ),
                    icon: InkSwatch(
                      color: entry.value,
                      selected:
                          (property.colorValue & 0xFFFFFF) ==
                          (entry.value.toARGB32() & 0xFFFFFF),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('pen-color'),
              controller: _color,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: context.l10n.colorHex,
                prefixText: '#',
                suffixIcon: Icon(Icons.circle, color: property.color),
                helperText: context.l10n.colorHexHint,
              ),
              onChanged: (value) {
                if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) {
                  return;
                }
                widget.controller.setPenProperty(
                  property.copyWith(
                    colorValue: 0xFF000000 | int.parse(value, radix: 16),
                  ),
                );
              },
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selected ??= PenPreset.defaults.first);
              _apply(_selected!.property);
            },
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(context.l10n.resetPreset),
          ),
          FilledButton.tonal(
            onPressed: _loaded && !_saving ? _savePersonal : null,
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(
              _saving ? context.l10n.saving : context.l10n.savePersonal,
            ),
          ),
        ],
      );
    },
  );
}
