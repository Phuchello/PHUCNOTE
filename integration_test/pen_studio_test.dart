import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/core/storage/pen_preset_store.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/pen_preview.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

import '../test/support/editor_interactions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  for (final landscape in [true, false]) {
    final orientation = landscape ? 'landscape' : 'portrait';
    testWidgets('Pen Studio, exact saved ink and Zen in $orientation', (
      tester,
    ) async {
      final directory = await Directory.systemTemp.createTemp('cp10_');
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
      await tester.pumpAndSettle();
      expect(
        tester.view.physicalSize.width > tester.view.physicalSize.height,
        landscape,
      );
      final canvas = find.byType(CanvasView);
      final controller = tester.widget<CanvasView>(canvas).controller;
      final state = tester.state(canvas);
      final document = controller.document;
      final revision = controller.revision;
      await stylusTap(tester, find.byTooltip('Pen Studio'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pen-preset')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fountain Pen').last);
      await tester.pumpAndSettle();
      final preview = find.byKey(const ValueKey('pen-preview'));
      final previewGesture = await tester.startGesture(
        tester.getTopLeft(preview) + const Offset(25, 65),
        kind: PointerDeviceKind.stylus,
      );
      for (final delta in [
        const Offset(40, -25),
        const Offset(40, 45),
        const Offset(40, -45),
        const Offset(40, 25),
      ]) {
        await previewGesture.moveBy(delta);
      }
      await previewGesture.up();
      await tester.pump();
      expect(
        (tester.widget<CustomPaint>(preview).painter! as PenPreviewPainter)
            .strokes
            .single,
        hasLength(5),
      );
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('pen_studio_$orientation');
      for (final label in [
        'Width',
        'Opacity',
        'Thinning',
        'Smoothing',
        'Streamline',
      ]) {
        final finder = find.byKey(ValueKey('pen-$label'));
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await stylusTap(tester, finder);
        await tester.pump();
      }
      await tester.ensureVisible(find.byKey(const ValueKey('pen-color')));
      await tester.enterText(find.byKey(const ValueKey('pen-color')), '1565C0');
      await tester.pump();
      expect(controller.penProperty.colorValue, 0xFF1565C0);
      expect(controller.revision, revision);
      expect(controller.isModified, isFalse);
      final custom = controller.penProperty.toJson();
      final name = 'CP10 $orientation ${DateTime.now().millisecondsSinceEpoch}';
      await tester.tap(find.text('Save personal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, name);
      await tester.tap(find.text('Save preset'));
      await tester.pumpAndSettle();
      for (
        var i = 0;
        i < 30 && find.text('Saving…').evaluate().isNotEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Saving…'), findsNothing);
      final personal = await PenPresetStore().load();
      expect(
        personal.singleWhere((p) => p.name == name).property.toJson(),
        custom,
      );
      await tester.tap(find.byTooltip('Close Pen Studio'));
      await tester.pumpAndSettle();
      await stylusTap(tester, find.byTooltip('Pen Studio'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 30; i++) {
        final dropdown = tester.widget<DropdownButton>(
          find.byKey(const ValueKey('pen-preset')),
        );
        if (dropdown.items!.any((item) => (item.child as Text).data == name)) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.byKey(const ValueKey('pen-preset')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
      expect(controller.penProperty.toJson(), custom);
      await tester.tap(find.byTooltip('Close Pen Studio'));
      await tester.pumpAndSettle();
      final property = controller.penProperty.toJson();
      final origin = tester.getTopLeft(canvas);
      final gesture = await tester.startGesture(
        origin + const Offset(200, 220),
        kind: PointerDeviceKind.stylus,
      );
      await gesture.moveBy(const Offset(40, 20));
      controller.setColor(Colors.red);
      await gesture.moveBy(const Offset(40, -20));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.document.strokes.single.property.toJson(), property);
      final original = controller.document.strokes.single.toJson();
      await stylusTap(tester, find.byTooltip('Undo'));
      await tester.pump();
      await stylusTap(tester, find.byTooltip('Redo'));
      await tester.pump();
      expect(controller.document.strokes.single.toJson(), original);
      await tapDrawingOption(tester, ToolbarWidget.continuousPaperTooltip);
      await tapDrawingOption(tester, 'Fit to Width');
      final zoom = controller.zoomScale;
      final offset = controller.viewportOffset;
      await stylusTap(tester, find.byTooltip('Enter Zen'));
      await tester.pumpAndSettle();
      expect(find.byType(ToolbarWidget), findsNothing);
      expect(tester.state(canvas), same(state));
      expect(controller.document, same(document));
      expect(controller.zoomScale, zoom);
      expect(controller.viewportOffset, offset);
      await binding.takeScreenshot('pen_zen_$orientation');
      await stylusTap(tester, find.byTooltip('Exit Zen'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 30 && controller.isModified; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
      }
      expect(controller.isModified, isFalse);
      final files = await storage.listSavedNotes();
      expect(
        (await storage.loadNote(files.single)).strokes.single.toJson(),
        original,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
