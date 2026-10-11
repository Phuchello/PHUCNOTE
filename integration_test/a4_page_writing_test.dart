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
import 'package:phucnote/drawing/a4_page_layout.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';

import '../test/support/editor_interactions.dart';

import '../test/support/localized_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final landscape in [true, false]) {
    final orientation = landscape ? 'landscape' : 'portrait';
    testWidgets('A4 writing, fit, navigation and persistence in $orientation', (
      tester,
    ) async {
      final directory = await Directory.systemTemp.createTemp(
        'phucnote_checkpoint09_',
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
      for (var attempt = 0; attempt < 30; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        final size = tester.view.physicalSize;
        if ((size.width > size.height) == landscape) break;
      }
      expect(
        tester.view.physicalSize.width > tester.view.physicalSize.height,
        landscape,
      );
      await tester.pumpAndSettle();

      final canvasFinder = find.byType(CanvasView);
      final controller = tester.widget<CanvasView>(canvasFinder).controller;
      await tapDrawingOption(tester, vi.continuousPaperHint);
      await tester.pumpAndSettle();
      await tapDrawingOption(tester, vi.fitToWidth);
      await tester.pumpAndSettle();
      final width = tester.getSize(canvasFinder).width;
      expect(controller.zoomScale, closeTo(width / A4PageLayout.width, 1e-6));
      expect(
        controller.canvasToScreen(const Offset(840, 0)).dx,
        closeTo(width, 1e-6),
      );
      expect(controller.canvasToScreen(Offset.zero).dx, closeTo(0, 1e-6));

      Future<void> ink(List<Offset> points) async {
        final origin = tester.getTopLeft(canvasFinder);
        final gesture = await tester.startGesture(
          origin + controller.canvasToScreen(points.first),
          kind: PointerDeviceKind.stylus,
        );
        for (final point in points.skip(1)) {
          await gesture.moveTo(origin + controller.canvasToScreen(point));
        }
        await gesture.up();
        await tester.pumpAndSettle();
      }

      void showY(double documentY, double screenY) {
        controller.panViewport(
          Offset(
            0,
            screenY - controller.canvasToScreen(Offset(0, documentY)).dy,
          ),
        );
      }

      await ink([const Offset(200, 300), const Offset(240, 330)]);
      expect(controller.document.strokes.length, 1);
      controller.panViewport(const Offset(100, 0));
      await tester.pumpAndSettle();
      await ink([const Offset(-20, 300), const Offset(200, 330)]);
      expect(controller.document.strokes.length, 1);
      controller.panViewport(const Offset(-100, 0));
      showY(1200, 250);
      await tester.pumpAndSettle();
      await ink([const Offset(200, 1200), const Offset(200, 1230)]);
      expect(controller.document.strokes.length, 1);

      showY(1500, 350);
      await tester.pumpAndSettle();
      await ink([const Offset(200, 1500), const Offset(240, 1530)]);
      expect(controller.document.strokes.length, 2);
      expect(
        controller.document.strokes.last.points.first.y,
        closeTo(1500, 1e-6),
      );
      showY(1180, 300);
      await tester.pumpAndSettle();
      final crossing = [
        const Offset(800, 1180),
        const Offset(850, 1200),
        const Offset(800, 1250),
      ];
      await ink(crossing);
      expect(controller.document.strokes.length, 3);
      final samples = controller.document.strokes.last.points;
      expect(samples.length, crossing.length);
      for (var i = 0; i < samples.length; i++) {
        expect(samples[i].x, closeTo(crossing[i].dx, 1e-6));
        expect(samples[i].y, closeTo(crossing[i].dy, 1e-6));
      }
      final strokes = controller.document.strokes
          .map((s) => s.toJson())
          .toList();

      // Two touch pointers zoom without creating an ink/history entry.
      final center = tester.getTopLeft(canvasFinder) + const Offset(350, 350);
      final first = await tester.startGesture(
        center - const Offset(50, 0),
        kind: PointerDeviceKind.touch,
      );
      final second = await tester.startGesture(
        center + const Offset(50, 0),
        kind: PointerDeviceKind.touch,
      );
      final oldZoom = controller.zoomScale;
      await first.moveBy(const Offset(-10, 0));
      await second.moveBy(const Offset(10, 0));
      await first.up();
      await second.up();
      await tester.pumpAndSettle();
      expect(controller.zoomScale, closeTo(oldZoom * 1.2, 1e-6));
      expect(controller.document.strokes.map((s) => s.toJson()), strokes);
      controller.zoomAt(Offset.zero, 0.8);
      showY(1180, 300);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(vi.eraser));
      await tester.pumpAndSettle();
      await ink([const Offset(800, 1180)]);
      expect(controller.document.strokes.length, 2);
      await tester.tap(find.byTooltip(vi.undo));
      await tester.pumpAndSettle();
      expect(controller.document.strokes.map((s) => s.toJson()), strokes);
      await tester.tap(find.byTooltip(vi.redo));
      await tester.pumpAndSettle();
      expect(controller.document.strokes.length, 2);
      await tester.tap(find.byTooltip(vi.undo));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(vi.pen));
      await tester.pumpAndSettle();

      for (var attempt = 0; attempt < 40 && controller.isModified; attempt++) {
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
      }
      expect(controller.isModified, isFalse, reason: 'A4 input must autosave');
      final saved = await storage.listSavedNotes();
      expect(saved, hasLength(1));
      expect(
        (await storage.loadNote(saved.single)).strokes.map((s) => s.toJson()),
        strokes,
      );
      await tester.tap(find.byTooltip(vi.openNotes));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.textContaining('.bfly'),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.document.strokes.map((s) => s.toJson()), strokes);
      await tapDrawingOption(tester, vi.fitToWidth);
      await tester.pumpAndSettle();
      showY(1180, 300);
      await tester.pumpAndSettle();
      expect(
        controller.canvasToScreen(const Offset(840, 0)).dx,
        closeTo(width, 1e-6),
      );
      expect(tester.takeException(), isNull);

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('checkpoint09_$orientation');
    });
  }
}
