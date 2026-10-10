// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/drawing/canvas_action.dart';
import 'package:phucnote/drawing/canvas_controller.dart';

void main() {
  group('CanvasAction & Action-History Engine', () {
    test('AddStrokeAction execute, undo, and redo', () {
      final doc = NoteDocument();
      final stroke = StrokeElement(
        id: '1',
        points: const [StrokePoint(x: 10, y: 10)],
        property: const StrokeProperty(colorValue: 0xFF000000),
      );

      final action = AddStrokeAction(stroke);
      expect(doc.strokes, isEmpty);

      action.execute(doc);
      expect(doc.strokes.length, 1);
      expect(doc.strokes.first.id, '1');

      action.undo(doc);
      expect(doc.strokes, isEmpty);

      action.redo(doc);
      expect(doc.strokes.length, 1);
    });

    test('EraseStrokesAction restores strokes to their exact original indices', () {
      final doc = NoteDocument();
      final s0 = StrokeElement(
        id: 's0',
        points: const [StrokePoint(x: 0, y: 0)],
        property: const StrokeProperty(colorValue: 0xFF000000),
      );
      final s1 = StrokeElement(
        id: 's1',
        points: const [StrokePoint(x: 50, y: 50)],
        property: const StrokeProperty(colorValue: 0xFF000000),
      );
      final s2 = StrokeElement(
        id: 's2',
        points: const [StrokePoint(x: 100, y: 100)],
        property: const StrokeProperty(colorValue: 0xFF000000),
      );

      doc.addStroke(s0);
      doc.addStroke(s1);
      doc.addStroke(s2);
      expect(doc.strokes.map((s) => s.id).toList(), ['s0', 's1', 's2']);

      // Erase s1 (index 1)
      final action = EraseStrokesAction(
        erasedStrokes: [s1],
        originalIndices: [1],
      );
      action.execute(doc);
      expect(doc.strokes.map((s) => s.id).toList(), ['s0', 's2']);

      // Undo restore preserves index 1
      action.undo(doc);
      expect(doc.strokes.map((s) => s.id).toList(), ['s0', 's1', 's2']);

      // Redo re-erases s1
      action.redo(doc);
      expect(doc.strokes.map((s) => s.id).toList(), ['s0', 's2']);
    });

    test('ClearCanvasAction restores full canvas on undo', () {
      final doc = NoteDocument();
      doc.addStroke(StrokeElement(
        id: 'a',
        points: const [StrokePoint(x: 1, y: 1)],
        property: const StrokeProperty(colorValue: 0xFF000000),
      ));
      doc.addStroke(StrokeElement(
        id: 'b',
        points: const [StrokePoint(x: 2, y: 2)],
        property: const StrokeProperty(colorValue: 0xFF000000),
      ));

      final action = ClearCanvasAction(doc.strokes);
      action.execute(doc);
      expect(doc.strokes, isEmpty);

      action.undo(doc);
      expect(doc.strokes.length, 2);
      expect(doc.strokes.map((s) => s.id).toList(), ['a', 'b']);

      action.redo(doc);
      expect(doc.strokes, isEmpty);
    });

    test('CanvasController handles complex mixed action sequences (Add, Erase, Clear, Undo, Redo)', () {
      final controller = CanvasController();

      // 1. Draw Stroke A
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(10, 10),
        kind: PointerDeviceKind.mouse,
      ));
      controller.handlePointerMove(const PointerMoveEvent(
        position: Offset(20, 20),
        kind: PointerDeviceKind.mouse,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(20, 20),
        kind: PointerDeviceKind.mouse,
      ));

      expect(controller.document.strokes.length, 1);
      final strokeA = controller.document.strokes.first;

      // 2. Draw Stroke B
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(100, 100),
        kind: PointerDeviceKind.mouse,
      ));
      controller.handlePointerMove(const PointerMoveEvent(
        position: Offset(120, 120),
        kind: PointerDeviceKind.mouse,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(120, 120),
        kind: PointerDeviceKind.mouse,
      ));

      expect(controller.document.strokes.length, 2);
      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);

      // 3. Switch to Eraser and erase Stroke A (near 15, 15)
      controller.setTool(CanvasTool.eraser);
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(15, 15),
        kind: PointerDeviceKind.mouse,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(15, 15),
        kind: PointerDeviceKind.mouse,
      ));

      expect(controller.document.strokes.length, 1);
      expect(controller.document.strokes.first.id, isNot(strokeA.id));

      // 4. Undo the erasure -> Stroke A must be restored!
      controller.undo();
      expect(controller.document.strokes.length, 2);
      expect(controller.document.strokes.first.id, strokeA.id);
      expect(controller.canRedo, isTrue);

      // 5. Redo the erasure -> Stroke A is erased again!
      controller.redo();
      expect(controller.document.strokes.length, 1);

      // 6. Clear canvas
      controller.clearCanvas();
      expect(controller.document.strokes, isEmpty);

      // 7. Undo clear canvas -> Stroke B is restored!
      controller.undo();
      expect(controller.document.strokes.length, 1);

      // 8. Draw a new stroke -> redo stack must be cleared
      controller.setTool(CanvasTool.pen);
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(200, 200),
        kind: PointerDeviceKind.mouse,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(200, 200),
        kind: PointerDeviceKind.mouse,
      ));

      expect(controller.document.strokes.length, 2);
      expect(controller.canRedo, isFalse); // Redo stack cleared on new mutation
    });
  });
}
