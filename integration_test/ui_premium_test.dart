import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

import '../test/support/editor_interactions.dart';
import '../test/support/localized_app.dart';

class _Storage extends NoteStorage {
  bool failSave = false;
  _Storage(Directory root) : super(customRootDirectory: root);
  @override
  Future<File> saveNote(NoteDocument document) async {
    if (failSave) throw const FileSystemException('Technical save failure');
    return super.saveNote(document);
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final landscape in [true, false]) {
      final name = '${mode.name}_${landscape ? 'landscape' : 'portrait'}';
      testWidgets('Premium Vietnamese editor and preserved flows: $name', (
        tester,
      ) async {
        final root = await Directory.systemTemp.createTemp('premium_');
        final storage = _Storage(root);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await root.delete(recursive: true);
          await SystemChrome.setPreferredOrientations([]);
        });
        await SystemChrome.setPreferredOrientations([
          landscape
              ? DeviceOrientation.landscapeLeft
              : DeviceOrientation.portraitUp,
        ]);
        await tester.pumpWidget(
          PhucNoteApp(noteStorage: storage, themeMode: mode),
        );
        for (var i = 0; i < 40; i++) {
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
        expect(
          Localizations.localeOf(tester.element(find.byType(CanvasView))),
          const Locale('vi', 'VN'),
        );
        expect(find.text(vi.noChanges), findsOneWidget);
        final controller = tester
            .widget<CanvasView>(find.byType(CanvasView))
            .controller;
        var converted = false;
        Future<void> capture(String state) async {
          if (!converted) {
            await binding.convertFlutterSurfaceToImage();
            converted = true;
          }
          await tester.pumpAndSettle();
          await binding.takeScreenshot('${name}_$state');
        }

        await tester.tap(find.byTooltip(vi.newNote));
        await tester.pumpAndSettle();
        const title = 'Đại số tuyến tính – học kỳ I';
        await tester.enterText(find.byType(TextField), title);
        await capture('create');
        await tester.tap(find.text(vi.create));
        await tester.pumpAndSettle();
        expect(controller.document.title, title);
        for (final label in [
          vi.pen,
          vi.highlighter,
          vi.eraser,
          vi.undo,
          vi.redo,
        ]) {
          expect(tester.getSize(find.byTooltip(label)), const Size(48, 48));
        }
        await tapDrawingOption(tester, vi.continuousPaperHint);
        await tapDrawingOption(tester, vi.fitToWidth);
        final width = MediaQuery.sizeOf(tester.element(find.byType(CanvasView)))
            .width;
        expect(
          controller.canvasToScreen(const Offset(800, 0)).dx,
          lessThan(width),
        );
        for (var j = 0; j < 3; j++) {
          await stylusTap(
            tester,
            find.byTooltip(j == 1 ? vi.highlighter : vi.pen),
          );
          await tester.pump();
          final origin =
              tester.getTopLeft(find.byType(CanvasView)) +
              Offset(120, 220.0 + j * 70);
          final gesture = await tester.startGesture(
            origin,
            kind: PointerDeviceKind.stylus,
          );
          for (var i = 1; i < 16; i++) {
            await gesture.moveTo(origin + Offset(i * 16.0, (i % 4 - 2) * 8.0));
          }
          await gesture.up();
          await tester.pump();
        }
        expect(controller.document.strokes, hasLength(3));
        final strokes = controller.document.strokes
            .map((s) => s.toJson())
            .toList();
        await stylusTap(tester, find.byTooltip(vi.undo));
        await tester.pump();
        expect(controller.document.strokes, hasLength(2));
        await stylusTap(tester, find.byTooltip(vi.redo));
        await tester.pump();
        expect(controller.document.strokes.map((s) => s.toJson()), strokes);
        await tester.tap(find.text(vi.save));
        await tester.pumpAndSettle();
        expect(controller.isModified, isFalse);
        await capture('editor');
        await openDrawingOptions(tester);
        await capture('menu');
        await tester.ensureVisible(find.byKey(const ValueKey('a4-option')));
        await capture('menu_modes');
        await tester.tapAt(const Offset(10, 150));
        await tester.pumpAndSettle();
        await stylusTap(tester, find.byTooltip(vi.penStudio));
        await tester.pumpAndSettle();
        await capture('studio');
        await tester.tap(find.byTooltip(vi.closePenStudio));
        await tester.pumpAndSettle();
        final canvasState = tester.state(find.byType(CanvasView));
        final document = controller.document;
        final zoom = controller.zoomScale;
        final offset = controller.viewportOffset;
        await stylusTap(tester, find.byTooltip(vi.enterZen));
        await tester.pumpAndSettle();
        expect(find.byType(ToolbarWidget), findsNothing);
        final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byWidgetPredicate(
            (widget) =>
                widget is AnnotatedRegion<SystemUiOverlayStyle> &&
                widget.value.statusBarIconBrightness == Brightness.dark,
          ),
        );
        expect(
          overlay.value.systemNavigationBarIconBrightness,
          Brightness.dark,
        );

        await capture('zen');
        await tester.tap(find.byTooltip(vi.exitZen));
        await tester.pumpAndSettle();
        expect(
          identical(canvasState, tester.state(find.byType(CanvasView))),
          isTrue,
        );
        expect(identical(document, controller.document), isTrue);
        expect(controller.zoomScale, zoom);
        expect(controller.viewportOffset, offset);
        expect(controller.document.strokes.map((s) => s.toJson()), strokes);
        await tester.tap(find.byTooltip(vi.openNotes));
        await tester.pumpAndSettle();
        final files = await storage.listSavedNotes();
        expect(files, hasLength(1));
        await capture('open');
        await tester.tap(find.text(files.single.uri.pathSegments.last));
        await tester.pumpAndSettle();
        expect(controller.document.title, title);
        expect(controller.document.strokes.map((s) => s.toJson()), strokes);
        ScaffoldMessenger.of(tester.element(find.byType(CanvasView)))
            .clearSnackBars();
        await tester.pumpAndSettle();
        controller.renameDocument('$title – bản sửa');
        storage.failSave = true;
        await tester.tap(find.text(vi.save));
        await tester.pumpAndSettle();
        expect(find.text(vi.noteSaveFailed), findsOneWidget);
        expect(find.textContaining('Technical save'), findsNothing);
        expect(controller.isModified, isTrue);
        await capture('error');
        storage.failSave = false;
        await tester.tap(find.text(vi.save));
        await tester.pumpAndSettle();
        expect(controller.isModified, isFalse);
        controller.resetViewport();
        controller.zoomAt(Offset.zero, 0.5);
        await tester.pumpAndSettle();
        await capture('pages');
        expect(tester.takeException(), isNull);
      });
    }
  }
}
