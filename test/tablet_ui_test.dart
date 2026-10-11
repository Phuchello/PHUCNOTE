import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/home_screen.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

import 'support/editor_interactions.dart';

class _HeldStorage extends NoteStorage {
  final snapshots = <NoteDocument>[];
  final completions = <Completer<File>>[];

  @override
  Future<File> saveNote(NoteDocument document) {
    snapshots.add(NoteDocument.fromJson(document.toJson()));
    final completion = Completer<File>();
    completions.add(completion);
    return completion.future;
  }
}

void main() {
  late _HeldStorage storage;
  late CanvasController controller;

  Future<void> open(
    WidgetTester tester, [
    Size size = const Size(1024, 640),
  ]) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    storage = _HeldStorage();
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

  void stroke(double x) {
    controller.handlePointerDown(PointerDownEvent(position: Offset(x, 250)));
    controller.handlePointerMove(
      PointerMoveEvent(position: Offset(x + 20, 270)),
    );
    controller.handlePointerUp(PointerUpEvent(position: Offset(x + 20, 270)));
  }

  void checkToolbar(WidgetTester tester) {
    final toolbar = tester.getRect(find.byType(ToolbarWidget));
    expect(toolbar.height, lessThanOrEqualTo(64));
    final buttons = ['Pen', 'Highlighter', 'Stroke Eraser', 'Undo', 'Redo'];
    final y = tester.getCenter(find.byTooltip('Pen')).dy;
    for (final tooltip in buttons) {
      final rect = tester.getRect(find.byTooltip(tooltip));
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
      expect(rect.center.dy, y);
      expect(toolbar.contains(rect.center), isTrue);
    }
    expect(tester.takeException(), isNull);
  }

  testWidgets('UI-01: landscape toolbar keeps primary targets on one row', (
    tester,
  ) async {
    await open(tester);
    controller.setShowA4Guides(true);
    controller.zoomAt(Offset.zero, 1.5);
    await tester.pump();
    checkToolbar(tester);
  });

  testWidgets('UI-02: portrait and narrow layouts keep controls usable', (
    tester,
  ) async {
    await open(tester, const Size(640, 1024));
    checkToolbar(tester);
    await openDrawingOptions(tester);
    expect(find.byTooltip('Paper Template'), findsOneWidget);
    await stylusTap(tester, find.text('Grid / Graph Paper'));
    await tester.pumpAndSettle();
    expect(controller.document.paperTemplate, PaperTemplate.grid);
    tester.view.physicalSize = const Size(360, 640);
    await tester.pumpAndSettle();
    for (final tooltip in [
      'Pen',
      'Highlighter',
      'Stroke Eraser',
      'Undo',
      'Redo',
      'Enter Zen',
    ]) {
      await stylusTap(tester, find.byTooltip(tooltip));
      await tester.pump();
      if (tooltip == 'Enter Zen') {
        await tester.tap(find.byTooltip('Exit Zen'));
        await tester.pump();
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('UI-03: stylus tool selection exposes the selected tool', (
    tester,
  ) async {
    await open(tester);
    for (final entry in {
      'Highlighter': CanvasTool.highlighter,
      'Stroke Eraser': CanvasTool.eraser,
      'Pen': CanvasTool.pen,
    }.entries) {
      await stylusTap(tester, find.byTooltip(entry.key));
      await tester.pump();
      expect(controller.tool, entry.value);
      final button = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == entry.key,
        ),
      );
      expect(button.isSelected, isTrue);
    }
  });

  testWidgets('UI-04: Undo and Redo remain directly accessible and exact', (
    tester,
  ) async {
    await open(tester);
    stroke(100);
    final original = controller.document.strokes.single.toJson();
    await tester.pump();
    await stylusTap(tester, find.byTooltip('Undo'));
    await tester.pump();
    expect(controller.document.strokes, isEmpty);
    await stylusTap(tester, find.byTooltip('Redo'));
    await tester.pump();
    expect(controller.document.strokes.single.toJson(), original);
  });

  testWidgets('UI-05: Zen hides regular controls and expands the same canvas', (
    tester,
  ) async {
    await open(tester);
    final state = tester.state(find.byType(CanvasView));
    final height = tester.getSize(find.byType(CanvasView)).height;
    await tester.tap(find.byTooltip('Enter Zen'));
    await tester.pump();
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(ToolbarWidget), findsNothing);
    expect(find.byTooltip('Exit Zen'), findsOneWidget);
    expect(tester.getSize(find.byType(CanvasView)).height, greaterThan(height));
    expect(tester.state(find.byType(CanvasView)), same(state));
  });

  testWidgets('UI-06: Exit Zen and Android Back restore navigation and save', (
    tester,
  ) async {
    await open(tester);
    for (final useBack in [false, true]) {
      await tester.tap(find.byTooltip('Enter Zen'));
      await tester.pump();
      if (useBack) {
        await tester.binding.handlePopRoute();
      } else {
        await stylusTap(tester, find.byTooltip('Exit Zen'));
      }
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ToolbarWidget), findsOneWidget);
      expect(find.byTooltip('New Note'), findsOneWidget);
      expect(find.byTooltip('Open Notes'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    }
  });

  testWidgets(
    'UI-07: Zen preserves document, active stroke, dirty state and history',
    (tester) async {
      await open(tester);
      stroke(100);
      stroke(200);
      controller.undo();
      final document = controller.document;
      final revision = controller.revision;
      final original = document.toJson();
      controller.handlePointerDown(
        const PointerDownEvent(
          position: Offset(300, 250),
          kind: PointerDeviceKind.stylus,
        ),
      );
      final active = controller.activePoints.map((p) => p.toJson()).toList();
      for (final tooltip in ['Enter Zen', 'Exit Zen']) {
        await tester.tap(find.byTooltip(tooltip));
        await tester.pump();
        expect(controller.document, same(document));
        expect(controller.document.toJson(), original);
        expect(controller.revision, revision);
        expect(controller.isModified, isTrue);
        expect(controller.canUndo, isTrue);
        expect(controller.canRedo, isTrue);
        expect(controller.activePoints.map((p) => p.toJson()), active);
      }
      controller.handlePointerMove(
        const PointerMoveEvent(
          position: Offset(330, 270),
          kind: PointerDeviceKind.stylus,
        ),
      );
      controller.handlePointerUp(
        const PointerUpEvent(kind: PointerDeviceKind.stylus),
      );
      expect(controller.document.strokes.length, 2);
      controller.undo();
      expect(controller.document.toJson()['strokes'], original['strokes']);
      controller.redo();
      expect(controller.document.strokes.length, 2);
    },
  );

  testWidgets('UI-08: Zen preserves zoom, offset and active touch navigation', (
    tester,
  ) async {
    await open(tester);
    controller.setStylusOnlyMode(true);
    controller.panViewport(const Offset(40, -700));
    controller.zoomAt(const Offset(100, 100), 1.5);
    final zoom = controller.zoomScale;
    final offset = controller.viewportOffset;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CanvasView)),
    );
    await tester.tap(find.byTooltip('Enter Zen'));
    await tester.pump();
    expect(controller.zoomScale, zoom);
    expect(controller.viewportOffset, offset);
    await gesture.moveBy(const Offset(20, -30));
    await gesture.up();
    expect(controller.viewportOffset, offset + const Offset(20, -30));
    await tester.tap(find.byTooltip('Exit Zen'));
    await tester.pump();
    expect(controller.zoomScale, zoom);
    expect(controller.viewportOffset, offset + const Offset(20, -30));
  });

  testWidgets(
    'UI-09: secondary options preserve A4 Fit, reset and Continuous Paper',
    (tester) async {
      await open(tester, const Size(640, 1024));
      await tapDrawingOption(tester, ToolbarWidget.continuousPaperTooltip);
      expect(controller.showA4Guides, isTrue);
      await tapDrawingOption(tester, 'Fit to Width');
      expect(controller.zoomScale, closeTo(640 / 840, 1e-6));
      await openDrawingOptions(tester);
      expect(
        tester
            .widget<CheckedPopupMenuItem<String>>(
              find.byKey(const ValueKey('a4-option')),
            )
            .checked,
        isTrue,
      );
      await tester.tap(find.byTooltip('Reset View'));
      await tester.pumpAndSettle();
      expect(controller.zoomScale, 1);
      await tapDrawingOption(tester, ToolbarWidget.a4WritingTooltip);
      expect(controller.showA4Guides, isFalse);
      controller.handlePointerDown(
        const PointerDownEvent(position: Offset(900, 1200)),
      );
      controller.handlePointerUp(const PointerUpEvent());
      expect(controller.document.strokes, hasLength(1));
    },
  );

  testWidgets(
    'UI-10: Zen keeps autosave, lifecycle save and manual save working',
    (tester) async {
      await open(tester);
      stroke(100);
      await tester.tap(find.byTooltip('Enter Zen'));
      await tester.pump(const Duration(milliseconds: 1501));
      expect(storage.snapshots, hasLength(1));
      stroke(200);
      storage.completions[0].complete(File('note.bfly'));
      await tester.pump();
      expect(storage.snapshots.last.strokes, hasLength(2));
      expect(controller.isModified, isTrue);
      storage.completions[1].complete(File('note.bfly'));
      await tester.pump();
      expect(controller.isModified, isFalse);
      stroke(300);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(storage.snapshots.last.strokes, hasLength(3));
      storage.completions[2].complete(File('note.bfly'));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.tap(find.byTooltip('Exit Zen'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(storage.snapshots, hasLength(4));
      storage.completions[3].complete(File('note.bfly'));
      await tester.pump();
      expect(controller.isModified, isFalse);
    },
  );
}
