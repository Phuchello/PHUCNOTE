import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/l10n/l10n.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/toolbar_widget.dart';
import 'package:phucnote/ui/ink_palette.dart';

import 'support/editor_interactions.dart';
import 'support/localized_app.dart';

// Technical identifiers are explicit; new text literals require audit.
const technical = <String>{
  'vi',
  'VN',
  'vi_VN',
  'Roboto',
  'dd/MM/yyyy HH:mm',
  'Black',
  'Blue',
  'Red',
  'Green',
  'Orange',
  'Purple',
  'Fine',
  'Normal',
  'Bold',
  'Width',
  'Opacity',
  'Thinning',
  'Smoothing',
  'Streamline',
  'cancel',
  'discard',
  'save',
  'studio',
  'diagnostics',
  'stylus',
  'a4',
  'fit',
  'reset',
  'clear',
  'color:',
  'width:',
  'paper:',
  r'paper:${entry.key.name}',
  r'$prefix${entry.key}',
  'editor-canvas',
  'pen-preview',
  'pen-preset',
  'pen-color',
  r'pen-$id',
  'a4-option',
  r'^[0-9a-fA-F]{6}$',
};
List<String> unlocalizedLiterals(String source) {
  source = source.replaceAll(
    RegExp(r'^\s*(import|export|//).*$', multiLine: true),
    '',
  );
  final literals = RegExp(r"""(?:r)?(['"])(.*?)\1""", dotAll: true);
  final found = [
    for (final match in literals.allMatches(source))
      if (RegExp('[A-Za-z]').hasMatch(match[2]!) &&
          !technical.contains(match[2]))
        match[2]!,
  ];
  final sinks = RegExp(
    r"""(?:\bText\(\s*|\b(?:tooltip|message|labelText|helperText|hintText|semanticLabel|label)\s*:\s*)(?:r)?(['"])(.*?)\1""",
    dotAll: true,
  );
  for (final match in sinks.allMatches(source)) {
    if (RegExp('[A-Za-z]').hasMatch(match[2]!) && !found.contains(match[2])) {
      found.add(match[2]!);
    }
  }
  return found;
}

class _FileFailure extends NoteStorage {
  _FileFailure(Directory root) : super(customRootDirectory: root);
  @override
  Future<NoteDocument> loadNote(File file) async =>
      throw const FileSystemException('English load failure');
  @override
  Future<void> deleteNote(File file) async =>
      throw const FileSystemException('English delete failure');
}

class _ListFailure extends NoteStorage {
  @override
  Future<List<File>> listSavedNotes() async =>
      throw const FileSystemException('English technical failure');
}

void main() {
  test('Localization guard rejects hard-coded UI and error messages', () {
    expect(
      unlocalizedLiterals(
        "Text('Undo'); tooltip: \"Open Notes\"; final error = 'Save failed';",
      ),
      ['Undo', 'Open Notes', 'Save failed'],
    );
    expect(unlocalizedLiterals("Text('Black');"), ['Black']);
    final files = [
      File('lib/main.dart'),
      File('lib/l10n/l10n.dart'),
      File('lib/drawing/view_painter.dart'),
      ...Directory('lib/ui')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
    ];
    for (final file in files) {
      expect(
        unlocalizedLiterals(file.readAsStringSync()),
        isEmpty,
        reason: file.path,
      );
    }
    final arb = jsonDecode(
      File('lib/l10n/app_vi.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(arb['@@locale'], 'vi');
    for (final key in [
      'pen',
      'undo',
      'save',
      'penStudio',
      'noteSaveFailed',
      'pageNumber',
    ]) {
      expect(arb[key], isNotEmpty);
    }
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [const Size(1024, 640), const Size(640, 1024)]) {
      testWidgets(
        'Vietnamese chrome, dialogs and targets: $mode $size at 1.3 text scale',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          tester.platformDispatcher.textScaleFactorTestValue = 1.3;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpWidget(
            PhucNoteApp(noteStorage: NoteStorage(), themeMode: mode),
          );
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(CanvasView));
          expect(Localizations.localeOf(context), const Locale('vi', 'VN'));
          expect(
            Theme.of(context).brightness,
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
          );
          expect(
            context.uiDateTime(DateTime(2026, 10, 11, 14, 5)),
            '11/10/2026 14:05',
          );
          expect(context.uiDecimal(3.5), '3,50');
          expect(find.text(vi.noChanges), findsOneWidget);
          expect(find.text(vi.saved), findsNothing);
          for (final label in [
            vi.pen,
            vi.highlighter,
            vi.eraser,
            vi.undo,
            vi.redo,
          ]) {
            expect(tester.getSize(find.byTooltip(label)), const Size(48, 48));
          }
          final swatch = tester.widget<InkSwatch>(
            find.descendant(
              of: find.byTooltip(vi.inkColor),
              matching: find.byType(InkSwatch),
            ),
          );
          expect(swatch.selected, isTrue);
          final colors = Theme.of(context).colorScheme;
          final contrast =
              (colors.primary.computeLuminance() + 0.05) /
              (colors.surface.computeLuminance() + 0.05);
          expect(
            contrast < 1 ? 1 / contrast : contrast,
            greaterThanOrEqualTo(3),
          );
          await tester.tap(find.byTooltip(vi.newNote));
          await tester.pumpAndSettle();
          expect(find.text(vi.createNote), findsOneWidget);
          const title = 'Đại số tuyến tính – học kỳ I / Physics';
          await tester.enterText(find.byType(TextField), title);
          await tester.tap(find.text(vi.create));
          await tester.pumpAndSettle();
          final controller = tester
              .widget<CanvasView>(find.byType(CanvasView))
              .controller;
          expect(controller.document.title, title);
          await openDrawingOptions(tester);
          expect(find.text(vi.paperTemplate), findsOneWidget);
          final heading = tester.widget<Text>(find.text(vi.paperTemplate));
          final headingContrast =
              (heading.style!.color!.computeLuminance() + 0.05) /
              (colors.surface.computeLuminance() + 0.05);
          expect(
            headingContrast < 1 ? 1 / headingContrast : headingContrast,
            greaterThanOrEqualTo(4.5),
          );
          await tester.ensureVisible(find.byTooltip(vi.continuousPaperHint));
          await stylusTap(tester, find.byTooltip(vi.continuousPaperHint));
          await tester.pumpAndSettle();
          await tapDrawingOption(tester, vi.fitToWidth);
          expect(controller.showA4Guides, isTrue);
          expect(
            controller.canvasToScreen(const Offset(800, 0)).dx,
            lessThan(size.width),
          );
          final viewport = controller.viewportOffset;
          final zoom = controller.zoomScale;
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

          expect(
            tester.getSize(find.byTooltip(vi.exitZen)).height,
            greaterThanOrEqualTo(48),
          );
          await tester.tap(find.byTooltip(vi.exitZen));
          await tester.pumpAndSettle();
          expect(controller.viewportOffset, viewport);
          expect(controller.zoomScale, zoom);
          expect(controller.document.title, title);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'List errors are Vietnamese and do not expose technical exceptions',
    (tester) async {
      await tester.pumpWidget(PhucNoteApp(noteStorage: _ListFailure()));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(vi.openNotes));
      await tester.pumpAndSettle();
      expect(find.text(vi.noteListFailed), findsOneWidget);
      expect(find.textContaining('English technical'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  for (final deleting in [false, true]) {
    testWidgets(
      'Localized ${deleting ? 'delete' : 'load'} error keeps the saved file',
      (tester) async {
        final root = (await tester.runAsync(
          () => Directory.systemTemp.createTemp('locale_failure_'),
        ))!;
        final normal = NoteStorage(customRootDirectory: root);
        final file = (await tester.runAsync(
          () => normal.saveNote(NoteDocument(title: 'Physics / Vật lý')),
        ))!;
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.runAsync(() => root.delete(recursive: true));
        });
        await tester.pumpWidget(PhucNoteApp(noteStorage: _FileFailure(root)));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await tester.tap(find.byTooltip(vi.openNotes));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();
        await tester.tap(
          deleting
              ? find.byTooltip(vi.deleteNote)
              : find.text(file.uri.pathSegments.last),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(deleting ? vi.noteDeleteFailed : vi.noteLoadFailed),
          findsOneWidget,
        );
        expect(find.textContaining('English'), findsNothing);
        expect(await tester.runAsync(file.exists), isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
