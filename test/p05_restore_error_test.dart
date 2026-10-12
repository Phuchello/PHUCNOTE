import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/storage/input_preferences_store.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/home_screen.dart';
import 'support/localized_app.dart';

class _FailingInputPreferencesStore extends InputPreferencesStore {
  @override
  Future<bool> load() async => throw const FileSystemException('failed');
}

class DelayedFailure extends InputPreferencesStore {
  final pending = Completer<bool>();
  final saves = <bool>[];
  @override
  Future<bool> load() => pending.future;
  @override
  Future<void> save(bool mode) async { saves.add(mode); }
}

void main() {
  testWidgets('explicit choice is persisted even when delayed restoration fails', (tester) async {
    final store = DelayedFailure();
    await tester.pumpWidget(localizedApp(home: HomeScreen(noteStorage: NoteStorage(), inputPreferences: store)));
    final c = tester.widget<CanvasView>(find.byType(CanvasView)).controller;
    c.setStylusOnlyMode(false);
    store.pending.completeError(const FileSystemException('failed'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(c.stylusOnlyMode, isFalse);
    expect(store.saves, [false]);
    expect(tester.widget<AbsorbPointer>(find.ancestor(of: find.byType(CanvasView), matching: find.byType(AbsorbPointer)).first).absorbing, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('handles input preferences load failure', (tester) async {
    await tester.pumpWidget(localizedApp(home: HomeScreen(noteStorage: NoteStorage(), inputPreferences: _FailingInputPreferencesStore())));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final absorbPointer = tester.widget<AbsorbPointer>(find.ancestor(of: find.byType(CanvasView), matching: find.byType(AbsorbPointer)).first);
    expect(absorbPointer.absorbing, isFalse);
    final canvasView = tester.widget<CanvasView>(find.byType(CanvasView));
    expect(canvasView.controller.stylusOnlyMode, isTrue);
    expect(find.text(vi.noteSaveFailed), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
