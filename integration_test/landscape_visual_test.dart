// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late NoteStorage noteStorage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('phucnote_landscape_');
    noteStorage = NoteStorage(customRootDirectory: tempDir);
  });

  tearDown(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  Future<void> capture(WidgetTester tester, String filename) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    final bytes = await binding.takeScreenshot(filename);
    final file = File('/data/user/0/com.phucnote.phucnote/files/$filename.png');
    await file.writeAsBytes(bytes);
  }

  CanvasController getController(WidgetTester tester) {
    return tester.widget<CanvasView>(find.byType(CanvasView)).controller;
  }

  group('PHUCNOTE A4 Landscape Visual Acceptance (V-05, V-06)', () {
    testWidgets('V-05: Page 2 and deep scrolling', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.setShowA4Guides(true);
      controller.resetViewport();

      // Pan down past page 1 separator (stride is 1212.0)
      controller.panViewport(const Offset(0, -1100));

      // Draw handwriting stroke on Page 2
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 400)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(500, 400)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(500, 400)));

      await tester.pumpAndSettle();

      expect(controller.viewportOffset.dy, equals(-1100.0));
      expect(controller.document.strokes.length, equals(1));
      expect(tester.takeException(), isNull);

      await capture(tester, '05_page_2');
    });

    testWidgets('V-06: Handwriting integrity', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.setShowA4Guides(true);
      controller.resetViewport();

      // 1. Draw stroke with A4 guides enabled
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 300)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(350, 450)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(350, 450)));
      expect(controller.document.strokes.length, equals(1));
      final initialStroke = controller.document.strokes.first;

      // 2. Pan and zoom
      controller.panViewport(const Offset(40, -80));
      controller.zoomAt(const Offset(200, 200), 1.5);
      await tester.pumpAndSettle();

      // 3. Erase a stroke and use Undo/Redo
      controller.setTool(CanvasTool.eraser);
      final screenPt = controller.canvasToScreen(Offset(initialStroke.points.first.x, initialStroke.points.first.y));
      controller.handlePointerDown(PointerDownEvent(position: screenPt));
      controller.handlePointerUp(PointerUpEvent(position: screenPt));
      expect(controller.document.strokes.isEmpty, isTrue);

      controller.undo();
      expect(controller.document.strokes.length, equals(1));

      controller.redo();
      expect(controller.document.strokes.isEmpty, isTrue);

      controller.undo();
      expect(controller.document.strokes.length, equals(1));

      // Reset view & switch back to pen
      controller.setTool(CanvasTool.pen);
      controller.resetViewport();

      // Draw second stroke
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 600)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(550, 600)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(550, 600)));

      // 4. Save and reopen note
      await noteStorage.saveNote(controller.document);
      final savedFiles = await noteStorage.listSavedNotes();
      expect(savedFiles.isNotEmpty, isTrue);
      final reloaded = await noteStorage.loadNote(savedFiles.first);

      // 5. Confirm logical stroke coordinates remain unchanged
      expect(reloaded.strokes.length, equals(controller.document.strokes.length));
      expect(reloaded.strokes.first.points.first.x, equals(controller.document.strokes.first.points.first.x));
      expect(reloaded.strokes.first.points.first.y, equals(controller.document.strokes.first.points.first.y));
      expect(reloaded.strokes.last.points.first.x, equals(controller.document.strokes.last.points.first.x));
      expect(reloaded.strokes.last.points.first.y, equals(controller.document.strokes.last.points.first.y));

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await capture(tester, '06_handwriting');
    });
  });
}
