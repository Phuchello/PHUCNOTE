import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class InputPreferencesStore {
  InputPreferencesStore({this.directory});

  final Directory? directory;
  Future<void> _writes = Future<void>.value();

  Future<File> _targetFile() async {
    final base = directory ?? await getApplicationSupportDirectory();
    return File('${base.path}/settings/input_preferences.json');
  }

  Future<bool> load() async {
    await _writes;
    try {
      final file = await _targetFile();
      if (!await file.exists()) return true;
      final data = jsonDecode(await file.readAsString());
      if (data is Map && data['stylusOnlyMode'] is bool) {
        return data['stylusOnlyMode'] as bool;
      }
    } catch (_) {}
    return true;
  }

  Future<void> save(bool stylusOnlyMode) {
    final task = _writes.catchError((_) {}).then((_) async {
      File? tmp;
      try {
        final file = await _targetFile();
        await file.parent.create(recursive: true);
        tmp = File('${file.path}.${DateTime.now().microsecondsSinceEpoch}.tmp');
        await tmp.writeAsString(
          jsonEncode({'stylusOnlyMode': stylusOnlyMode}),
          flush: true,
        );
        await tmp.rename(file.path);
      } catch (_) {
        if (tmp != null && await tmp.exists()) {
          await tmp.delete().catchError((_) => tmp!);
        }
        rethrow;
      }
    });

    _writes = task.catchError((_) {});
    return task;
  }
}
