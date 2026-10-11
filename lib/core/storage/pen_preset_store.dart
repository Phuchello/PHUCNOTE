import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/pen_preset.dart';

/// Independent app settings; never reads or writes a .bfly document.
class PenPresetStore {
  static final instance = PenPresetStore();
  final Directory? directory;
  Future<void> _writes = Future.value();

  PenPresetStore({this.directory});

  Future<File> _file() async {
    final root = directory ?? await getApplicationSupportDirectory();
    return File('${root.path}/settings/pen_presets.json');
  }

  Future<List<PenPreset>> load() async {
    await _writes;
    final file = await _file();
    if (!await file.exists()) return [];
    final json = jsonDecode(await file.readAsString()) as List<dynamic>;
    final presets = json
        .map((value) => PenPreset.fromJson(value as Map<String, dynamic>))
        .toList();
    _validate(presets);
    return presets;
  }

  static void _validate(List<PenPreset> presets) {
    final names = PenPreset.defaults
        .map((preset) => preset.name.toLowerCase())
        .toSet();
    for (final preset in presets) {
      preset.validate();
      if (!names.add(preset.name.toLowerCase())) {
        throw const FormatException('Choose a unique preset name.');
      }
    }
  }

  Future<void> save(List<PenPreset> presets) {
    final snapshot = List<PenPreset>.of(presets);
    final write = _writes.then((_) async {
      _validate(snapshot);
      final file = await _file();
      await file.parent.create(recursive: true);
      final temporary = File('${file.path}.tmp');
      try {
        await temporary.writeAsString(
          jsonEncode(snapshot.map((p) => p.toJson()).toList()),
          flush: true,
        );
        await temporary.rename(file.path);
      } finally {
        if (await temporary.exists()) await temporary.delete();
      }
    });
    _writes = write.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return write;
  }
}
