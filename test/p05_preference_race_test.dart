import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/storage/input_preferences_store.dart';

void main() {
  test('write-queue error recovery across instances', () async {
    final tempDir = Directory.systemTemp.createTempSync('pref_recovery_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final blocker = File('${tempDir.path}/settings')..writeAsStringSync('occupied');
    final a = InputPreferencesStore(directory: tempDir);
    final b = InputPreferencesStore(directory: tempDir);
    await expectLater(a.save(false), throwsA(isA<FileSystemException>()));
    blocker.deleteSync();
    await b.save(false);
    expect(await a.load(), isFalse);
  });

  test('restoration across instances waits for pending preference write', () async {
    final dir = Directory.systemTemp.createTempSync('pref_race_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final first = InputPreferencesStore(directory: dir);
    final second = InputPreferencesStore(directory: dir);
    final pending = first.save(false);
    final restored = await second.load();
    await pending;
    expect(restored, isFalse);
  });
}
