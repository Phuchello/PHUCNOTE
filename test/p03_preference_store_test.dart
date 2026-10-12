import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/storage/input_preferences_store.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('input_pref_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('defaults true, persists to new instance, and handles queued saves', () async {
    final store1 = InputPreferencesStore(directory: tempDir);
    expect(await store1.load(), isTrue);

    await store1.save(false);
    final store2 = InputPreferencesStore(directory: tempDir);
    expect(await store2.load(), isFalse);

    final saveTrue = store2.save(true);
    final saveFalse = store2.save(false);
    await Future.wait([saveTrue, saveFalse]);
    expect(await store2.load(), isFalse);
  });

  test('malformed json defaults true and preserves raw file', () async {
    final file = File('${tempDir.path}/settings/input_preferences.json');
    await file.parent.create(recursive: true);
    const rawMalformed = '{bad json:';
    await file.writeAsString(rawMalformed);

    final store = InputPreferencesStore(directory: tempDir);
    expect(await store.load(), isTrue);
    expect(await file.readAsString(), rawMalformed);
  });
}
