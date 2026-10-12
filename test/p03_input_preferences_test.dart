import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/home_screen.dart';

import 'support/localized_app.dart';

void main() {
  Future<void> drain(WidgetTester tester) async {
    for (int i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump();
    }
  }
  testWidgets('actual HomeScreen should preserve explicit false choice across recreation', (tester) async {
    final tempDir = await tester.runAsync(() => Directory.systemTemp.createTemp('input_preferences_test_'));
    final dir = tempDir!;

    try {
      await tester.pumpWidget(localizedApp(home: HomeScreen(noteStorage: NoteStorage(customRootDirectory: dir))));
      await drain(tester);

      final controller = tester.widget<CanvasView>(find.byType(CanvasView)).controller;
      controller.setStylusOnlyMode(false);
      await drain(tester);
      final settingsFile = File('${dir.path}/settings/input_preferences.json');
      final rawJson = await tester.runAsync(() => settingsFile.readAsString());
      final decoded = jsonDecode(rawJson!) as Map<String, dynamic>;
      expect(decoded['stylusOnlyMode'], isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await tester.pumpWidget(localizedApp(home: HomeScreen(noteStorage: NoteStorage(customRootDirectory: dir))));
      await drain(tester);

      final newController = tester.widget<CanvasView>(find.byType(CanvasView)).controller;
      expect(newController.stylusOnlyMode, isFalse);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.runAsync(() => dir.delete(recursive: true));
    }
  });
}
