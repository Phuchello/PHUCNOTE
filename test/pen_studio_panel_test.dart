import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/storage/pen_preset_store.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/ui/pen_preview.dart';
import 'package:phucnote/ui/pen_studio_panel.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

import 'support/localized_app.dart';

void main() {
  late CanvasController controller;
  late Directory directory;
  late PenPresetStore store;
  setUp(() async {
    controller = CanvasController();
    directory = await Directory.systemTemp.createTemp('pen_panel_');
    store = PenPresetStore(directory: directory);
  });
  tearDown(() async {
    controller.dispose();
    await directory.delete(recursive: true);
  });

  Future<void> settleSettings(WidgetTester tester) async {
    for (var i = 0; i < 500; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
      final save = find.widgetWithText(FilledButton, vi.savePersonal);
      if (save.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(save).onPressed != null) {
        return;
      }
      if (find
          .textContaining(vi.presetLoadFailed)
          .evaluate()
          .isNotEmpty) {
        return;
      }
    }
    fail('Personal preset I/O did not finish.');
  }

  Future<void> open(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      localizedApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      PenStudioPanel(controller: controller, store: store),
                ),
                child: const Text('Open studio'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open studio'));
    await tester.pumpAndSettle();
    await settleSettings(tester);
  }

  Future<void> select(WidgetTester tester, String name) async {
    await tester.ensureVisible(find.byKey(const ValueKey('pen-preset')));
    await tester.tap(find.byKey(const ValueKey('pen-preset')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  for (final size in [
    const Size(1024, 640),
    const Size(640, 1024),
    const Size(360, 640),
  ]) {
    testWidgets('Studio controls fit and remain accessible at $size', (
      tester,
    ) async {
      await open(tester, size);
      await select(tester, vi.gelPen);
      expect(
        controller.penProperty.toJson(),
        PenPreset.defaults[1].property.toJson(),
      );
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
        final slider = tester.widget<Slider>(finder);
        final value = slider.min + (slider.max - slider.min) * 0.637;
        slider.onChanged!(value);
        await tester.pump();
        expect(tester.widget<Slider>(finder).value, value);
        final preview = tester.widget<PenPreview>(find.byType(PenPreview));
        expect(preview.property.toJson(), controller.penProperty.toJson());
      }
      await tester.ensureVisible(find.byKey(const ValueKey('pen-color')));
      await tester.enterText(find.byKey(const ValueKey('pen-color')), '1565C0');
      await tester.pump();
      expect(controller.penProperty.colorValue, 0xFF1565C0);
      expect(controller.isModified, isFalse);
      expect(controller.document.strokes, isEmpty);
      await tester.tap(find.text(vi.resetPreset));
      await tester.pump();
      expect(
        controller.penProperty.toJson(),
        PenPreset.defaults[1].property.toJson(),
      );
      final close = tester.getRect(find.byTooltip(vi.closePenStudio));
      expect(close.size, const Size(48, 48));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip(vi.closePenStudio));
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'Interactive preview stays independent of document and updates existing sample ink',
    (tester) async {
      await open(tester, const Size(640, 1024));
      final finder = find.byKey(const ValueKey('pen-preview'));
      final origin = tester.getTopLeft(finder);
      final gesture = await tester.startGesture(
        origin + const Offset(20, 50),
        kind: PointerDeviceKind.stylus,
      );
      await gesture.moveBy(const Offset(40, -20));
      await gesture.moveBy(const Offset(40, 40));
      await gesture.up();
      await tester.pump();
      PenPreviewPainter painter() =>
          tester.widget<CustomPaint>(finder).painter! as PenPreviewPainter;
      final points = painter().strokes.single.map((p) => p.toJson()).toList();
      expect(points, hasLength(3));
      controller.setPenProperty(PenPreset.defaults.last.property);
      await tester.pump();
      expect(painter().strokes.single.map((p) => p.toJson()), points);
      expect(painter().property.toJson(), controller.penProperty.toJson());
      expect(controller.canUndo, isFalse);
      expect(controller.isModified, isFalse);
      await tester.tap(find.byTooltip(vi.resetPreview));
      await tester.pump();
      expect(painter().strokes, isEmpty);
    },
  );

  testWidgets(
    'Save named preset, reopen studio, select and reset its exact settings',
    (tester) async {
      await open(tester, const Size(640, 1024));
      await select(tester, vi.fountainPen);
      controller.setPenProperty(
        controller.penProperty.copyWith(strokeWidth: 7.137, opacity: 0.637),
      );
      final original = controller.penProperty.toJson();
      await tester.pump();
      await tester.tap(find.text(vi.savePersonal));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Study ink');
      await tester.tap(find.text(vi.savePreset));
      await tester.pumpAndSettle();
      await settleSettings(tester);
      expect(
        (await tester.runAsync(
          () => PenPresetStore(directory: directory).load(),
        ))!.single.property.toJson(),
        original,
      );
      await tester.tap(find.byTooltip(vi.closePenStudio));
      await tester.pumpAndSettle();
      controller.setPenProperty(PenPreset.defaults.first.property);
      await tester.tap(find.text('Open studio'));
      await tester.pumpAndSettle();
      await settleSettings(tester);
      await select(tester, 'Study ink');
      expect(controller.penProperty.toJson(), original);
      controller.setStrokeWidth(12);
      await tester.pump();
      await tester.tap(find.text(vi.resetPreset));
      await tester.pump();
      expect(controller.penProperty.toJson(), original);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Corrupt personal settings disable writes and keep built-in presets usable',
    (tester) async {
      final file = File('${directory.path}/settings/pen_presets.json');
      await tester.runAsync(() async {
        await file.parent.create();
        await file.writeAsString('corrupt');
      });
      await open(tester, const Size(640, 1024));
      await select(tester, vi.ballpoint);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, vi.savePersonal),
            )
            .onPressed,
        isNull,
      );
      expect(
        find.textContaining(vi.presetLoadFailed),
        findsOneWidget,
      );
      expect(await tester.runAsync(() => file.readAsString()), 'corrupt');
    },
  );

  testWidgets(
    'Responsive toolbar exposes Studio without increasing its height or tool targets',
    (tester) async {
      for (final width in [720.0, 480.0, 352.0]) {
        await tester.pumpWidget(
          localizedApp(
            home: Scaffold(
              body: SizedBox(
                width: width,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ToolbarWidget(controller: controller),
                ),
              ),
            ),
          ),
        );
        final toolbar = tester.getRect(find.byType(ToolbarWidget));
        expect(toolbar.height, width < 360 ? 104 : 56);
        for (final tooltip in [
          vi.pen,
          vi.highlighter,
          vi.eraser,
          vi.undo,
          vi.redo,
        ]) {
          expect(tester.getSize(find.byTooltip(tooltip)), const Size(48, 48));
        }
        if (width >= 480) {
          expect(
            tester.getSize(find.byTooltip(vi.penStudio)),
            const Size(48, 48),
          );
        } else {
          await tester.tap(find.byTooltip(vi.drawingOptions));
          await tester.pumpAndSettle();
          expect(find.text(vi.penStudio), findsOneWidget);
          await tester.tapAt(const Offset(780, 580));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      }
    },
  );
}
