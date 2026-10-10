// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/home_screen.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late NoteStorage noteStorage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('phucnote_test_');
    noteStorage = NoteStorage(customRootDirectory: tempDir);
  });

  tearDown(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  CanvasController getController(WidgetTester tester) {
    final canvasView = tester.widget<CanvasView>(find.byType(CanvasView));
    return canvasView.controller;
  }

  group('PHUCNOTE Automated Emulator Integration Test Suite (TC-01 to TC-14)', () {
    // TC-01: Application launch without crashes
    testWidgets('TC-01: Application launch without crashes', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(CanvasView), findsOneWidget);
      expect(find.byType(ToolbarWidget), findsOneWidget);
      expect(find.text('Untitled Note'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    // TC-02: Create notebook
    testWidgets('TC-02: Create notebook with specified title and template', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      // Tap 'New Note' action
      final newNoteButton = find.byTooltip('New Note');
      expect(newNoteButton, findsOneWidget);
      await tester.tap(newNoteButton);
      await tester.pumpAndSettle();

      // Fill in note title
      final titleField = find.widgetWithText(TextField, 'Note Title');
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Physics Mechanics 101');
      await tester.pumpAndSettle();

      // Tap 'Create'
      final createButton = find.widgetWithText(FilledButton, 'Create');
      expect(createButton, findsOneWidget);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Verify title updated
      expect(find.text('Physics Mechanics 101'), findsOneWidget);
      final controller = getController(tester);
      expect(controller.document.title, equals('Physics Mechanics 101'));
    });

    // TC-03: Draw and commit strokes
    testWidgets('TC-03: Draw and commit strokes to canvas', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      expect(controller.document.strokes, isEmpty);

      // In default mode (stylusOnlyMode == false), pointer drawing works directly
      final canvasFinder = find.byType(CanvasView);
      final canvasCenter = tester.getCenter(canvasFinder);

      final gesture = await tester.startGesture(canvasCenter);
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveBy(const Offset(50, 50));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveBy(const Offset(50, -20));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.document.strokes.length, equals(1));
      expect(controller.isModified, isTrue);
      expect(controller.canUndo, isTrue);
    });

    // TC-04: Pen, highlighter and eraser
    testWidgets('TC-04: Pen, highlighter and eraser switching', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      expect(controller.tool, equals(CanvasTool.pen));

      // Switch to Highlighter
      final highlighterBtn = find.byTooltip('Highlighter');
      expect(highlighterBtn, findsOneWidget);
      await tester.tap(highlighterBtn);
      await tester.pumpAndSettle();
      expect(controller.tool, equals(CanvasTool.highlighter));

      // Draw highlighter stroke
      final canvasCenter = tester.getCenter(find.byType(CanvasView));
      final gesture1 = await tester.startGesture(canvasCenter);
      await gesture1.moveBy(const Offset(30, 0));
      await gesture1.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes.length, equals(1));
      expect(controller.document.strokes.first.property.isHighlighter, isTrue);

      // Switch to Eraser
      final eraserBtn = find.byTooltip('Stroke Eraser');
      expect(eraserBtn, findsOneWidget);
      await tester.tap(eraserBtn);
      await tester.pumpAndSettle();
      expect(controller.tool, equals(CanvasTool.eraser));

      // Drag eraser across stroke
      final gesture2 = await tester.startGesture(canvasCenter);
      await gesture2.moveBy(const Offset(35, 0));
      await gesture2.up();
      await tester.pumpAndSettle();
      // Erased! Stroke count should now be 0
      expect(controller.document.strokes.length, equals(0));

      // Switch back to Pen
      final penBtn = find.byTooltip('Pen');
      expect(penBtn, findsOneWidget);
      await tester.tap(penBtn);
      await tester.pumpAndSettle();
      expect(controller.tool, equals(CanvasTool.pen));
    });

    // TC-05: Undo and Redo
    testWidgets('TC-05: Undo and Redo history stack verification', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      final canvasCenter = tester.getCenter(find.byType(CanvasView));

      // Draw first stroke
      final gesture1 = await tester.startGesture(canvasCenter);
      await gesture1.moveBy(const Offset(20, 20));
      await gesture1.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes.length, equals(1));

      // Undo
      final undoBtn = find.byTooltip('Undo');
      expect(undoBtn, findsOneWidget);
      await tester.tap(undoBtn);
      await tester.pumpAndSettle();
      expect(controller.document.strokes, isEmpty);
      expect(controller.canRedo, isTrue);

      // Redo
      final redoBtn = find.byTooltip('Redo');
      expect(redoBtn, findsOneWidget);
      await tester.tap(redoBtn);
      await tester.pumpAndSettle();
      expect(controller.document.strokes.length, equals(1));
    });

    // TC-06: Save and reopen notebook
    testWidgets('TC-06: Save and reopen notebook from storage', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.renameDocument('Saved Lecture Note');

      // Draw stroke
      final canvasCenter = tester.getCenter(find.byType(CanvasView));
      final gesture = await tester.startGesture(canvasCenter);
      await gesture.moveBy(const Offset(40, 40));
      await gesture.up();
      await tester.pumpAndSettle();

      // Tap Save
      final saveBtn = find.widgetWithText(FilledButton, 'Save');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final savedFiles = await noteStorage.listSavedNotes();
      expect(savedFiles.isNotEmpty, isTrue);

      // Open notes dialog
      final openBtn = find.byTooltip('Open Notes');
      await tester.tap(openBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Saved Notes'), findsOneWidget);
      // Tap on the saved note tile inside the bottom sheet list
      final noteTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.textContaining('.bfly'),
      );
      expect(noteTile, findsOneWidget);
      await tester.tap(noteTile);
      await tester.pumpAndSettle();

      expect(controller.document.title, equals('Saved Lecture Note'));
      expect(controller.document.strokes.length, equals(1));
    });

    // TC-07: Autosave after editing
    testWidgets('TC-07: Autosave triggers after debounce period', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.renameDocument('Autosave Note');

      // Draw stroke
      final canvasCenter = tester.getCenter(find.byType(CanvasView));
      final gesture = await tester.startGesture(canvasCenter);
      await gesture.moveBy(const Offset(30, 30));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.isModified, isTrue);

      // Advance clock past 1500ms debounce
      await tester.pump(const Duration(milliseconds: 1700));
      await tester.pumpAndSettle();

      expect(controller.isModified, isFalse);
      final savedFiles = await noteStorage.listSavedNotes();
      expect(savedFiles.isNotEmpty, isTrue);
    });

    // TC-08: Rapid editing during active save
    testWidgets('TC-08: Rapid editing during active save preserves pending changes', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.renameDocument('Rapid Save Note');

      final canvasCenter = tester.getCenter(find.byType(CanvasView));

      // Draw first stroke and trigger save
      final g1 = await tester.startGesture(canvasCenter);
      await g1.moveBy(const Offset(20, 20));
      await g1.up();
      await tester.pumpAndSettle();

      final saveBtn = find.widgetWithText(FilledButton, 'Save');
      await tester.tap(saveBtn);
      await tester.pump(const Duration(milliseconds: 5));

      // Rapidly draw second stroke while save might be in flight
      final g2 = await tester.startGesture(canvasCenter + const Offset(50, 50));
      await g2.moveBy(const Offset(30, 30));
      await g2.up();
      await tester.pumpAndSettle();

      // Wait for complete settle / autosave loop
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Verify both strokes are recorded and state is saved
      expect(controller.document.strokes.length, equals(2));
      expect(controller.isModified, isFalse);
    });

    // TC-09: Application restart and data recovery
    testWidgets('TC-09: Application restart and data recovery from storage', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.renameDocument('Persistent Recovery Doc');

      final canvasCenter = tester.getCenter(find.byType(CanvasView));
      final g1 = await tester.startGesture(canvasCenter);
      await g1.moveBy(const Offset(40, 20));
      await g1.up();
      await tester.pumpAndSettle();

      final saveBtn = find.widgetWithText(FilledButton, 'Save');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Simulate App Restart by destroying and rebuilding widget tree
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // Re-mount app with same noteStorage
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      // Open saved note
      final openBtn = find.byTooltip('Open Notes');
      await tester.tap(openBtn);
      await tester.pumpAndSettle();

      final noteTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.textContaining('.bfly'),
      );
      expect(noteTile, findsOneWidget);
      await tester.tap(noteTile);
      await tester.pumpAndSettle();

      final newController = getController(tester);
      expect(newController.document.title, equals('Persistent Recovery Doc'));
      expect(newController.document.strokes.length, equals(1));
    });

    // TC-10: Rename and persistence
    testWidgets('TC-10: Rename and persistence verification', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      // Tap title to trigger rename
      final titleWidget = find.text('Untitled Note');
      expect(titleWidget, findsOneWidget);
      await tester.tap(titleWidget);
      await tester.pumpAndSettle();

      expect(find.text('Rename Note'), findsOneWidget);
      final renameField = find.widgetWithText(TextField, 'Title');
      await tester.enterText(renameField, 'Renamed Academic Paper');
      await tester.pumpAndSettle();

      final confirmRenameBtn = find.widgetWithText(FilledButton, 'Rename');
      await tester.tap(confirmRenameBtn);
      await tester.pumpAndSettle();

      expect(find.text('Renamed Academic Paper'), findsOneWidget);
      final controller = getController(tester);
      expect(controller.document.title, equals('Renamed Academic Paper'));

      // Save and verify file name contains new title
      final saveBtn = find.widgetWithText(FilledButton, 'Save');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final notes = await noteStorage.listSavedNotes();
      expect(notes.any((f) => f.path.contains('Renamed Academic Paper')), isTrue);
    });

    // TC-11: Portrait and landscape layouts
    testWidgets('TC-11: Responsive layout adaptivity in portrait and landscape', (tester) async {
      tester.view.physicalSize = const Size(2560, 1600); // Landscape 16:10
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      expect(find.byType(ToolbarWidget), findsOneWidget);
      expect(find.byType(CanvasView), findsOneWidget);

      // Rotate to Portrait 16:10 (1600 x 2560)
      tester.view.physicalSize = const Size(1600, 2560);
      await tester.pumpAndSettle();

      expect(find.byType(ToolbarWidget), findsOneWidget);
      expect(find.byType(CanvasView), findsOneWidget);
      expect(tester.takeException(), isNull); // Zero layout overflows

      // Reset
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // TC-12: Offline basic operation
    testWidgets('TC-12: Offline core operations execute without network dependencies', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.renameDocument('Offline Validation Doc');

      // Drawing
      final canvasCenter = tester.getCenter(find.byType(CanvasView));
      final gesture = await tester.startGesture(canvasCenter);
      await gesture.moveBy(const Offset(30, 30));
      await gesture.up();
      await tester.pumpAndSettle();

      // Local save
      final saveBtn = find.widgetWithText(FilledButton, 'Save');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Local list and verify
      final notes = await noteStorage.listSavedNotes();
      expect(notes.isNotEmpty, isTrue);
      expect(controller.document.strokes.isNotEmpty, isTrue);
    });

    // TC-13: Finger navigation and viewport panning
    testWidgets('TC-13: Finger navigation and viewport panning in stylus-only mode', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);

      // Enable stylus-only mode
      final stylusToggle = find.byTooltip('Finger Inking Allowed (Tap to enable Stylus-Only)');
      expect(stylusToggle, findsOneWidget);
      await tester.tap(stylusToggle);
      await tester.pumpAndSettle();

      expect(controller.stylusOnlyMode, isTrue);
      final initialOffset = controller.viewportOffset;

      // Simulate finger touch pan
      final canvasCenter = tester.getCenter(find.byType(CanvasView));
      final touchGesture = await tester.startGesture(
        canvasCenter,
        kind: PointerDeviceKind.touch,
      );
      await touchGesture.moveBy(const Offset(-100, -80));
      await touchGesture.up();
      await tester.pumpAndSettle();

      // Viewport offset must have panned
      expect(controller.viewportOffset, isNot(equals(initialOffset)));
      expect(controller.document.strokes, isEmpty); // Finger touch did NOT ink
    });

    // TC-14: Stylus/touch discrimination using simulated input events
    testWidgets('TC-14: Stylus/touch discrimination gates inking vs panning', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);

      // Enable Stylus-Only mode
      final stylusToggle = find.byTooltip('Finger Inking Allowed (Tap to enable Stylus-Only)');
      await tester.tap(stylusToggle);
      await tester.pumpAndSettle();
      expect(controller.stylusOnlyMode, isTrue);

      final canvasCenter = tester.getCenter(find.byType(CanvasView));

      // 1. Touch event -> should NOT ink
      final touch = await tester.startGesture(canvasCenter, kind: PointerDeviceKind.touch);
      await touch.moveBy(const Offset(30, 30));
      await touch.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes, isEmpty);

      // 2. Stylus event -> MUST ink
      final stylus = await tester.startGesture(canvasCenter, kind: PointerDeviceKind.stylus);
      await stylus.moveBy(const Offset(40, 40));
      await stylus.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes.length, equals(1));

      // 3. Disable Stylus-Only mode -> touch event MUST now ink
      final stylusOnlyToggle = find.byTooltip('Stylus-Only Active (Fingers Pan Canvas)');
      await tester.tap(stylusOnlyToggle);
      await tester.pumpAndSettle();
      expect(controller.stylusOnlyMode, isFalse);

      final touch2 = await tester.startGesture(canvasCenter + const Offset(10, 10), kind: PointerDeviceKind.touch);
      await touch2.moveBy(const Offset(20, 20));
      await touch2.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes.length, equals(2));
    });

    // TC-15: Continuous vertical paper downward navigation and persistence
    testWidgets('TC-15: Continuous vertical paper downward navigation and persistence', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      controller.renameDocument('Continuous Paper Note');

      // Draw stroke near the top
      final canvasCenter = tester.getCenter(find.byType(CanvasView));
      final g1 = await tester.startGesture(canvasCenter);
      await g1.moveBy(const Offset(30, 30));
      await g1.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes.length, equals(1));
      final topStrokeY = controller.document.strokes.first.points.first.y;

      // Navigate down continuously by 3,000 pixels
      controller.panViewport(const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(controller.viewportOffset.dy, equals(-3000.0));

      // Draw stroke further down in continuous paper
      final g2 = await tester.startGesture(canvasCenter);
      await g2.moveBy(const Offset(40, 40));
      await g2.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes.length, equals(2));
      final bottomStrokeY = controller.document.strokes.last.points.first.y;

      // Bottom stroke Y should be approx topStrokeY + 3000
      expect(bottomStrokeY, greaterThan(topStrokeY + 2500));

      // Save document
      final saveBtn = find.widgetWithText(FilledButton, 'Save');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final savedFiles = await noteStorage.listSavedNotes();
      expect(savedFiles.isNotEmpty, isTrue);

      final reloaded = await noteStorage.loadNote(savedFiles.first);
      expect(reloaded.strokes.length, equals(2));
      expect(reloaded.strokes.first.points.first.y, equals(topStrokeY));
      expect(reloaded.strokes.last.points.first.y, equals(bottomStrokeY));
    });

    // TC-16: Two-finger pinch zoom adjusts scale and resets cleanly
    testWidgets('TC-16: Two-finger pinch zoom adjusts scale and resets cleanly', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      final canvasCenter = tester.getCenter(find.byType(CanvasView));

      // Simulate 2-finger pinch gesture
      final f1 = await tester.startGesture(canvasCenter - const Offset(60, 0), kind: PointerDeviceKind.touch);
      final f2 = await tester.startGesture(canvasCenter + const Offset(60, 0), kind: PointerDeviceKind.touch);
      await tester.pump(const Duration(milliseconds: 16));

      // Pinch out from 120px to 240px
      await f1.moveBy(const Offset(-60, 0));
      await f2.moveBy(const Offset(60, 0));
      await tester.pump(const Duration(milliseconds: 16));

      await f1.up();
      await f2.up();
      await tester.pumpAndSettle();

      expect(controller.zoomScale, greaterThan(1.5));
      expect(find.byTooltip('Reset View'), findsOneWidget);

      // Tap Reset View
      await tester.tap(find.byTooltip('Reset View'));
      await tester.pumpAndSettle();

      expect(controller.zoomScale, equals(1.0));
      expect(controller.viewportOffset, equals(Offset.zero));
    });

    // TC-17: Toggle A4 notebook page guides visual layout
    testWidgets('TC-17: Toggle A4 notebook page guides visual layout', (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
      await tester.pumpAndSettle();

      final controller = getController(tester);
      expect(controller.showA4Guides, isFalse);

      final a4Toggle = find.byTooltip('Continuous Paper (Tap for A4 Page Guides)');
      expect(a4Toggle, findsOneWidget);

      await tester.tap(a4Toggle);
      await tester.pumpAndSettle();

      expect(controller.showA4Guides, isTrue);
      expect(find.byTooltip('A4 Page Guides Active (Tap to disable)'), findsOneWidget);

      await tester.tap(find.byTooltip('A4 Page Guides Active (Tap to disable)'));
      await tester.pumpAndSettle();

      expect(controller.showA4Guides, isFalse);
    });
  });
}
