import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/home_screen.dart';

class _DelayedStorage extends NoteStorage {
  final snapshots = <NoteDocument>[];
  final completions = <Completer<File>>[];

  @override
  Future<File> saveNote(NoteDocument document) {
    snapshots.add(NoteDocument.fromJson(document.toJson()));
    final completion = Completer<File>();
    completions.add(completion);
    return completion.future;
  }

  void succeed(int index) => completions[index].complete(File('note.bfly'));
}

void _draw(CanvasController controller, double x) {
  controller.handlePointerDown(PointerDownEvent(position: Offset(x, 200)));
  controller.handlePointerUp(PointerUpEvent(position: Offset(x, 200)));
}

void main() {
  late _DelayedStorage storage;
  late CanvasController controller;

  Future<void> open(WidgetTester tester) async {
    storage = _DelayedStorage();
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(noteStorage: storage)),
    );
    controller = tester.widget<CanvasView>(find.byType(CanvasView)).controller;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      for (final completion in storage.completions) {
        if (!completion.isCompleted) completion.complete(File('note.bfly'));
      }
      await tester.pump();
    });
  }

  testWidgets('edits pending after a failed save are retried by autosave', (
    tester,
  ) async {
    await open(tester);
    _draw(controller, 100);
    await tester.pump(const Duration(milliseconds: 1501));
    _draw(controller, 200);
    await tester.pump(const Duration(milliseconds: 1600));
    storage.completions[0].completeError(const FileSystemException('failed'));
    await tester.pump();
    expect(controller.isModified, isTrue);
    await tester.pump(const Duration(milliseconds: 1501));
    expect(storage.snapshots.length, 2);
    expect(storage.snapshots.last.strokes.length, 2);
    storage.succeed(1);
    await tester.pump();
    expect(controller.isModified, isFalse);
  });

  testWidgets(
    'edits and a timer during a save are drained without clearing dirty',
    (tester) async {
      await open(tester);
      _draw(controller, 100);
      await tester.pump(const Duration(milliseconds: 1501));
      expect(storage.snapshots.single.strokes.length, 1);
      _draw(controller, 200);
      await tester.pump(const Duration(milliseconds: 1600));
      expect(storage.snapshots.length, 1);

      storage.succeed(0);
      await tester.pump();
      expect(controller.isModified, isTrue);
      expect(storage.snapshots.length, 2);
      expect(storage.snapshots.last.strokes.length, 2);
      storage.succeed(1);
      await tester.pump();
      expect(controller.isModified, isFalse);
    },
  );

  testWidgets('rename marks a clean document dirty and autosaves its title', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Untitled Note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Renamed');
    await tester.tap(find.text('Rename'));
    await tester.pump();
    expect(controller.isModified, isTrue);
    await tester.pump(const Duration(milliseconds: 1501));
    expect(storage.snapshots.single.title, 'Renamed');
    storage.succeed(0);
    await tester.pump();
    expect(controller.isModified, isFalse);
  });

  testWidgets(
    'old save completion cannot clean an edited replacement document',
    (tester) async {
      await open(tester);
      _draw(controller, 100);
      await tester.pump(const Duration(milliseconds: 1501));
      final oldId = controller.document.id;
      await tester.tap(find.byTooltip('New Note'));
      await tester.pump();
      await tester.tap(find.text('Discard Changes'));
      await tester.pump();
      await tester.tap(find.text('Create'));
      await tester.pump();
      expect(controller.document.id, isNot(oldId));
      _draw(controller, 200);
      await tester.pump(const Duration(milliseconds: 1600));
      storage.succeed(0);
      await tester.pump();
      expect(controller.isModified, isTrue);
      expect(storage.snapshots.length, 2);
      expect(storage.snapshots.last.id, controller.document.id);
      storage.succeed(1);
      await tester.pump();
      expect(controller.isModified, isFalse);
    },
  );

  testWidgets('Save & Proceed waits for an already active save', (
    tester,
  ) async {
    await open(tester);
    _draw(controller, 100);
    await tester.pump(const Duration(milliseconds: 1501));
    await tester.tap(find.byTooltip('New Note'));
    await tester.pump();
    await tester.tap(find.text('Save & Proceed'));
    await tester.pump();
    expect(find.text('Create New Note'), findsNothing);
    storage.succeed(0);
    await tester.pump();
    expect(find.text('Create New Note'), findsOneWidget);
    expect(storage.snapshots.length, 1);
  });

  testWidgets('failure keeps dirty state and a later retry can save it', (
    tester,
  ) async {
    await open(tester);
    _draw(controller, 100);
    await tester.pump(const Duration(milliseconds: 1501));
    storage.completions[0].completeError(const FileSystemException('failed'));
    await tester.pump();
    expect(controller.isModified, isTrue);
    expect(find.textContaining('Failed to save note:'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(storage.snapshots.length, 2);
    storage.succeed(1);
    await tester.pump();
    expect(controller.isModified, isFalse);
  });
}
