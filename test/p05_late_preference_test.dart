import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/storage/input_preferences_store.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/home_screen.dart';
import 'support/localized_app.dart';

class Delayed extends InputPreferencesStore {
  final completer = Completer<bool>();
  final saves = <bool>[];
  @override
  Future<bool> load() => completer.future;
  @override
  Future<void> save(bool stylusOnlyMode) async { saves.add(stylusOnlyMode); }
}

void main() {
  testWidgets('late restoration preserves explicit choice across document and orientation changes', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      await tester.pumpWidget(const SizedBox.shrink());
    });
    final store = Delayed();
    await tester.pumpWidget(localizedApp(home: HomeScreen(noteStorage: NoteStorage(), inputPreferences: store)));
    final c = tester.widget<CanvasView>(find.byType(CanvasView)).controller;
    c.setStylusOnlyMode(false);
    store.completer.complete(true);
    await tester.pumpAndSettle();
    expect(c.stylusOnlyMode, isFalse);
    expect(store.saves.last, isFalse);
    c.setDocument(NoteDocument());
    await tester.pump();
    expect(c.stylusOnlyMode, isFalse);
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pump();
    expect(c.stylusOnlyMode, isFalse);
  });
}
