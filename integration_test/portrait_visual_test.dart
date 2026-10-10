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
import 'package:phucnote/ui/toolbar_widget.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late NoteStorage noteStorage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('phucnote_portrait_');
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

  group('PHUCNOTE A4 Portrait Visual Acceptance (V-03, V-04)', () {
    testWidgets('V-03: Portrait at 1.0x', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.setShowA4Guides(true);
      controller.resetViewport();

      // Draw handwriting aligned with A4 page
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 400)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(450, 400)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(450, 400)));

      await tester.pumpAndSettle();

      expect(controller.showA4Guides, isTrue);
      expect(controller.zoomScale, equals(1.0));
      expect(find.byType(ToolbarWidget), findsOneWidget);
      expect(find.byType(CanvasView), findsOneWidget);
      expect(tester.takeException(), isNull);

      await capture(tester, '03_portrait_1x');
    });

    testWidgets('V-04: Portrait at 0.5x', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.setShowA4Guides(true);
      controller.resetViewport();

      // Draw handwriting
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 400)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(450, 400)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(450, 400)));

      // Zoom out to 0.5x
      controller.zoomAt(Offset.zero, 0.5);
      await tester.pumpAndSettle();

      expect(controller.showA4Guides, isTrue);
      expect(controller.zoomScale, equals(0.5));
      expect(find.byType(ToolbarWidget), findsOneWidget);
      expect(tester.takeException(), isNull);

      await capture(tester, '04_portrait_0_5x');
    });
  });
}
