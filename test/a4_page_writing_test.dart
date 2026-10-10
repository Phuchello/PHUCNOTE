// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/drawing/view_painter.dart';

import 'a4_notebook_guides_test.dart' show A4SpyCanvas;

void draw(CanvasController controller, List<Offset> positions) {
  controller.handlePointerDown(
    PointerDownEvent(
      position: controller.canvasToScreen(positions.first),
      kind: PointerDeviceKind.stylus,
      pressure: 0.7,
      tilt: 0.2,
    ),
  );
  for (final point in positions.skip(1)) {
    controller.handlePointerMove(
      PointerMoveEvent(
        position: controller.canvasToScreen(point),
        kind: PointerDeviceKind.stylus,
        pressure: 0.8,
        tilt: 0.3,
      ),
    );
  }
  controller.handlePointerUp(
    PointerUpEvent(
      position: controller.canvasToScreen(positions.last),
      kind: PointerDeviceKind.stylus,
    ),
  );
}

void main() {
  test(
    'A4 rejects starts outside page width and in gaps, even after reentry',
    () {
      final controller = CanvasController()..setShowA4Guides(true);
      addTearDown(controller.dispose);
      controller.panViewport(const Offset(30, -1100));
      controller.zoomAt(Offset.zero, 1.5);

      for (final start in [
        const Offset(-1, 200),
        const Offset(840, 200),
        const Offset(900, 1500),
        const Offset(200, -0.01),
        const Offset(200, 1188),
        const Offset(200, 1200),
        const Offset(200, 1211.99),
        const Offset(200, 2400),
      ]) {
        draw(controller, [start, const Offset(200, 1500)]);
        expect(controller.document.strokes, isEmpty, reason: '$start');
        expect(controller.activePoints, isEmpty);
        expect(controller.canUndo, isFalse);
        expect(controller.isModified, isFalse);
        expect(controller.isStylusActive, isFalse);
      }
    },
  );

  test('Page 1 and Page 2 accept global coordinates after pan and zoom', () {
    final controller = CanvasController()..setShowA4Guides(true);
    addTearDown(controller.dispose);
    controller.panViewport(const Offset(-30, -900));
    controller.zoomAt(Offset.zero, 0.75);
    final strokes = [
      [const Offset(100, 200), const Offset(130, 240)],
      [const Offset(100, 1212), const Offset(150, 1500)],
    ];
    for (final positions in strokes) {
      draw(controller, positions);
    }
    expect(controller.document.strokes.length, 2);
    for (var i = 0; i < strokes.length; i++) {
      expect(
        controller.document.strokes[i].points.map((p) => p.toOffset()),
        strokes[i],
      );
      expect(controller.document.strokes[i].points.first.pressure, 0.7);
      expect(controller.document.strokes[i].points.last.tilt, 0.3);
    }
  });

  test(
    'Accepted stroke crosses page edges and gaps as one intact undo action',
    () {
      final controller = CanvasController()..setShowA4Guides(true);
      addTearDown(controller.dispose);
      final positions = [
        const Offset(800, 1180),
        const Offset(845, 1188),
        const Offset(850, 1200),
        const Offset(800, 1212),
        const Offset(790, 1250),
      ];
      draw(controller, positions);
      final original = controller.document.strokes.single.toJson();
      expect(
        controller.document.strokes.single.points.map((p) => p.toOffset()),
        positions,
      );
      for (var cycle = 0; cycle < 3; cycle++) {
        controller.undo();
        expect(controller.document.strokes, isEmpty);
        expect(controller.canUndo, isFalse);
        final revision = controller.revision;
        draw(controller, [const Offset(900, 1200), const Offset(200, 1250)]);
        expect(controller.revision, revision);
        expect(controller.canRedo, isTrue);
        controller.redo();
        expect(controller.document.strokes.single.toJson(), original);
      }
    },
  );

  test('Continuous Paper accepts the same outside and gap starts', () {
    final controller = CanvasController();
    addTearDown(controller.dispose);
    for (final start in [
      const Offset(-10, 200),
      const Offset(900, 200),
      const Offset(200, 1200),
    ]) {
      draw(controller, [start, start + const Offset(20, 20)]);
    }
    expect(controller.document.strokes.length, 3);
  });

  test(
    'Eraser remains unrestricted after pan and zoom, with intact undo/redo',
    () {
      final controller = CanvasController();
      addTearDown(controller.dispose);
      // Existing continuous ink may lie in a gap or beyond the page width.
      draw(controller, [const Offset(900, 1200), const Offset(910, 1205)]);
      controller.setShowA4Guides(true);
      draw(controller, [const Offset(100, 1500), const Offset(140, 1540)]);
      final originals = controller.document.strokes
          .map((s) => s.toJson())
          .toList();
      controller.panViewport(const Offset(-400, -1100));
      controller.zoomAt(Offset.zero, 1.5);
      controller.setTool(CanvasTool.eraser);
      draw(controller, [const Offset(900, 1200)]);
      expect(controller.document.strokes.length, 1);
      controller.undo();
      expect(controller.document.strokes.map((s) => s.toJson()), originals);
      controller.redo();
      expect(controller.document.strokes.single.toJson(), originals.last);
    },
  );

  test(
    'Save/reopen preserves page-aware and legacy out-of-bounds ink exactly',
    () async {
      final directory = await Directory.systemTemp.createTemp('phucnote_a4_');
      addTearDown(() => directory.delete(recursive: true));
      final storage = NoteStorage(customRootDirectory: directory);
      final controller = CanvasController();
      addTearDown(controller.dispose);
      draw(controller, [const Offset(-50, 100), const Offset(-30, 130)]);
      draw(controller, [const Offset(900, 1200), const Offset(920, 1210)]);
      controller.setShowA4Guides(true);
      controller.panViewport(const Offset(40, -1000));
      controller.zoomAt(Offset.zero, 0.75);
      draw(controller, [const Offset(100, 200), const Offset(150, 250)]);
      draw(controller, [
        const Offset(800, 1180),
        const Offset(850, 1200),
        const Offset(800, 1250),
      ]);
      final original = controller.document.toJson();
      final file = await storage.saveNote(controller.document);
      final reloaded = await storage.loadNote(file);
      expect(reloaded.toJson(), original);
      controller.setDocument(reloaded);
      controller.setShowA4Guides(true);
      controller.fitToWidth(800);
      expect(controller.document.toJson(), original);
      final canvas = A4SpyCanvas();
      PhucNoteViewPainter(
        document: reloaded,
        backgroundColor: Colors.white,
        repaintCounter: 0,
        viewportOffset: const Offset(100, 0),
        showA4Guides: true,
      ).paint(canvas, const Size(1200, 1300));
      expect(canvas.drawPathCount, reloaded.strokes.length);
    },
  );

  test('Existing legacy .bfly fixture remains unchanged when A4 writing is enabled', () {
    final legacy = BflySerializer.decode(
      File('test/fixtures/document_v1.bfly').readAsBytesSync(),
    );
    final original = legacy.toJson();
    expect(
      legacy.strokes.any(
        (s) => s.points.any((p) => p.x >= 840 || p.x < 0 || p.y >= 1188),
      ),
      isTrue,
    );
    final controller = CanvasController(document: legacy);
    addTearDown(controller.dispose);
    controller.setShowA4Guides(true);
    controller.fitToWidth(800);
    controller.toggleA4Guides();
    expect(controller.document.toJson(), original);
    expect(
      BflySerializer.decode(BflySerializer.encode(legacy)).toJson(),
      original,
    );
  });
}
