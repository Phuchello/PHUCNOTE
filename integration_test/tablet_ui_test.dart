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

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  for (final landscape in [true, false]) {
    final orientation = landscape ? 'landscape' : 'portrait';
    testWidgets('Tablet editor, Zen and resume in $orientation', (
      tester,
    ) async {
      final directory = await Directory.systemTemp.createTemp(
        'phucnote_tablet_ui_',
      );
      final storage = NoteStorage(customRootDirectory: directory);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await directory.delete(recursive: true);
        await SystemChrome.setPreferredOrientations([]);
      });
      await SystemChrome.setPreferredOrientations([
        landscape
            ? DeviceOrientation.landscapeLeft
            : DeviceOrientation.portraitUp,
      ]);
      await tester.pumpWidget(PhucNoteApp(noteStorage: storage));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if ((tester.view.physicalSize.width >
                tester.view.physicalSize.height) ==
            landscape) {
          break;
        }
      }
      expect(
        tester.view.physicalSize.width > tester.view.physicalSize.height,
        landscape,
      );
      await tester.pumpAndSettle();
      final canvas = find.byType(CanvasView);
      final state = tester.state(canvas);
      final controller = tester.widget<CanvasView>(canvas).controller;
      final document = controller.document;
      final normalHeight = tester.getSize(canvas).height;
      expect(tester.getSize(find.byType(ToolbarWidget)).height, 56);

      for (final entry in {
        'Highlighter': CanvasTool.highlighter,
        'Stroke Eraser': CanvasTool.eraser,
        'Pen': CanvasTool.pen,
      }.entries) {
        await stylusTap(tester, find.byTooltip(entry.key));
        await tester.pumpAndSettle();
        expect(controller.tool, entry.value);
      }
      await tapDrawingOption(tester, ToolbarWidget.continuousPaperTooltip);
      await tapDrawingOption(tester, 'Fit to Width');
      expect(
        controller.zoomScale,
        closeTo(tester.getSize(canvas).width / 840, 1e-6),
      );
      await tapDrawingOption(tester, 'Clear Canvas');
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(controller.document, same(document));

      Future<void> ink(Offset start) async {
        final origin = tester.getTopLeft(canvas);
        final gesture = await tester.startGesture(
          origin + start,
          kind: PointerDeviceKind.stylus,
        );
        await gesture.moveBy(const Offset(80, 40));
        await gesture.up();
        await tester.pumpAndSettle();
      }

      await ink(const Offset(200, 250));
      final original = controller.document.strokes.single.toJson();
      await stylusTap(tester, find.byTooltip('Undo'));
      await tester.pumpAndSettle();
      expect(controller.document.strokes, isEmpty);
      await stylusTap(tester, find.byTooltip('Redo'));
      await tester.pumpAndSettle();
      expect(controller.document.strokes.single.toJson(), original);
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('automated_${orientation}_editor');

      controller.panViewport(const Offset(20, -60));
      controller.zoomAt(Offset.zero, 0.9);
      final zoom = controller.zoomScale;
      final offset = controller.viewportOffset;
      final origin = tester.getTopLeft(canvas);
      final activeGesture = await tester.startGesture(
        origin + const Offset(200, 350),
        kind: PointerDeviceKind.stylus,
      );
      final active = controller.activePoints.map((p) => p.toJson()).toList();
      await stylusTap(tester, find.byTooltip('Enter Zen'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(ToolbarWidget), findsNothing);
      expect(find.byTooltip('Exit Zen'), findsOneWidget);
      expect(tester.state(canvas), same(state));
      expect(tester.getSize(canvas).height, greaterThan(normalHeight));
      expect(controller.document, same(document));
      expect(controller.activePoints.map((p) => p.toJson()), active);
      expect(controller.zoomScale, zoom);
      expect(controller.viewportOffset, offset);
      expect(controller.canUndo, isTrue);
      await activeGesture.moveTo(
        tester.getTopLeft(canvas) + const Offset(260, 380),
      );
      await activeGesture.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes, hasLength(2));
      await binding.takeScreenshot('automated_${orientation}_zen');

      for (var i = 0; i < 30 && controller.isModified; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
      }
      expect(controller.isModified, isFalse);
      final files = await storage.listSavedNotes();
      expect(files, hasLength(1));
      expect(
        (await storage.loadNote(files.single)).strokes.map((s) => s.toJson()),
        controller.document.strokes.map((s) => s.toJson()),
      );
      await stylusTap(tester, find.byTooltip('Exit Zen'));
      await tester.pumpAndSettle();
      expect(find.byType(ToolbarWidget), findsOneWidget);
      expect(find.byTooltip('Open Notes'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(controller.zoomScale, zoom);
      expect(controller.viewportOffset, offset);
      await ink(const Offset(300, 450));
      expect(controller.document.strokes, hasLength(3));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(controller.isModified, isFalse);
      expect(tester.takeException(), isNull);
      await binding.takeScreenshot('automated_${orientation}_resumed');
    });
  }
}
