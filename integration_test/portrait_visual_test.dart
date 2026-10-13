// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

import '../test/support/editor_interactions.dart';

import '../test/support/localized_app.dart';

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

  Future<void> openPortrait(WidgetTester tester) async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    addTearDown(() => SystemChrome.setPreferredOrientations([]));
    await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (tester.view.physicalSize.height > tester.view.physicalSize.width) {
        break;
      }
    }
    await tester.pumpAndSettle();
    expect(tester.view.physicalSize.height, greaterThan(tester.view.physicalSize.width));
  }

  group('PHUCNOTE A4 Portrait Visual Acceptance (V-03, V-04)', () {
    testWidgets('V-03: Portrait with fit-to-width', (tester) async {
      await openPortrait(tester);

      final controller = getController(tester);
      final viewportWidth = MediaQuery.sizeOf(tester.element(find.byType(CanvasView))).width;
      controller.setShowA4Guides(true);
      controller.resetViewport();
      await tester.pumpAndSettle();

      // Find and tap the Fit to Width button on toolbar
      await openDrawingOptions(tester);
      final fitBtn = find.byTooltip(vi.fitToWidth);
      expect(fitBtn, findsOneWidget);
      await tester.tap(fitBtn);
      await tester.pumpAndSettle();

      // Draw handwriting aligned with fitted A4 page
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 400), kind: PointerDeviceKind.stylus));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(450, 400), kind: PointerDeviceKind.stylus));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(450, 400), kind: PointerDeviceKind.stylus));
      expect(controller.document.strokes, hasLength(1));
      await tester.pumpAndSettle();

      expect(controller.showA4Guides, isTrue);
      expect(controller.zoomScale, closeTo(viewportWidth / 840.0, 1e-4));
      expect(find.byType(ToolbarWidget), findsOneWidget);
      expect(find.byType(CanvasView), findsOneWidget);

      // Verify page boundaries against the actual portrait viewport
      final pageLeft = controller.canvasToScreen(const Offset(0, 0)).dx;
      final pageRight = controller.canvasToScreen(const Offset(CanvasController.a4Width, 0)).dx;
      final footerRight = controller.canvasToScreen(const Offset(CanvasController.a4Width - 24.0, 0)).dx;

      expect(pageLeft, greaterThanOrEqualTo(0.0));
      expect(pageRight, lessThanOrEqualTo(viewportWidth + 0.01));
      expect(footerRight, lessThanOrEqualTo(viewportWidth));
      expect(tester.takeException(), isNull);

      await capture(tester, '03_portrait_1x');
    });

    testWidgets('V-04: Portrait at 0.5x', (tester) async {
      await openPortrait(tester);

      final controller = getController(tester);
      controller.setShowA4Guides(true);
      controller.resetViewport();

      // Draw handwriting
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 400), kind: PointerDeviceKind.stylus));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(450, 400), kind: PointerDeviceKind.stylus));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(450, 400), kind: PointerDeviceKind.stylus));
      expect(controller.document.strokes, hasLength(1));

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
