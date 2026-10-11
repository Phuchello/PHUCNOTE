import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/models/pen_preset.dart';
import '../core/models/stroke_property.dart';
import '../core/storage/pen_preset_store.dart';
import '../drawing/canvas_controller.dart';
import 'pen_preview.dart';

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
        setState(
          () => _error = 'Personal presets could not be loaded. Existing settings were kept.',
        );
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
        title: const Text('Save personal preset'),
        content: TextField(
          onChanged: (value) => draftName = value,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'Preset name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftName.trim()),
            child: const Text('Save preset'),
          ),
        ],
      ),
    );
    if (!mounted || name == null) return;
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
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message.toString());
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Preset could not be saved. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Row(
    children: [
      SizedBox(width: 82, child: Text(label)),
      Expanded(
        child: Slider(
          key: ValueKey('pen-$label'),
          value: value.clamp(min, max),
          min: min,
          max: max,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ),
      SizedBox(width: 38, child: Text(value.toStringAsFixed(2))),
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
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'PHUC PEN STUDIO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close Pen Studio',
                      constraints: const BoxConstraints.tightFor(
                        width: 48,
                        height: 48,
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(customized ? 'Preset · customized' : 'Preset'),
                        DropdownButton<PenPreset>(
                          key: const ValueKey('pen-preset'),
                          value: _selected,
                          isExpanded: true,
                          hint: const Text('Current pen'),
                          items: [
                            for (final preset in [
                              ...PenPreset.defaults,
                              ..._personal,
                            ])
                              DropdownMenuItem(
                                value: preset,
                                child: Text(
                                  preset.name,
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
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Fountain Pen: soft-nib pressure-width simulation with a round tip.',
                          ),
                        ),
                        PenPreview(property: property),
                        _slider(
                          'Width',
                          property.strokeWidth,
                          0.5,
                          24,
                          (v) => _apply(property.copyWith(strokeWidth: v)),
                        ),
                        _slider(
                          'Opacity',
                          property.opacity,
                          0,
                          1,
                          (v) => _apply(property.copyWith(opacity: v)),
                        ),
                        _slider(
                          'Thinning',
                          property.thinning,
                          -1,
                          1,
                          (v) => _apply(property.copyWith(thinning: v)),
                        ),
                        _slider(
                          'Smoothing',
                          property.smoothing,
                          0,
                          1,
                          (v) => _apply(property.copyWith(smoothing: v)),
                        ),
                        _slider(
                          'Streamline',
                          property.streamline,
                          0,
                          1,
                          (v) => _apply(property.copyWith(streamline: v)),
                        ),
                        TextField(
                          key: const ValueKey('pen-color'),
                          controller: _color,
                          maxLength: 6,
                          decoration: InputDecoration(
                            labelText: 'Color (RRGGBB)',
                            prefixText: '#',
                            suffixIcon: Icon(
                              Icons.circle,
                              color: property.color,
                            ),
                            helperText: 'Six hex digits; valid colors apply immediately.',
                          ),
                          onChanged: (value) {
                            if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) {
                              return;
                            }
                            widget.controller.setPenProperty(
                              property.copyWith(
                                colorValue:
                                    0xFF000000 | int.parse(value, radix: 16),
                              ),
                            );
                          },
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => _selected ??= PenPreset.defaults.first);
                        _apply(_selected!.property);
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      child: const Text('Reset preset'),
                    ),
                    FilledButton.tonal(
                      onPressed: _loaded && !_saving ? _savePersonal : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text(_saving ? 'Saving…' : 'Save personal'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
