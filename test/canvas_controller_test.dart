// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/drawing/canvas_controller.dart';

void main() {
  group('CanvasController Logic & State Management', () {
    test('Default tool and settings initialize properly', () {
      final controller = CanvasController();
      expect(controller.tool, equals(CanvasTool.pen));
      expect(controller.document.strokes, isEmpty);
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);
      expect(controller.isModified, isFalse);
    });

    test('Drawing lifecycle commits stroke to document and updates undo stack', () {
      final controller = CanvasController();

      // 1. Pointer Down
      controller.handlePointerDown(
        const PointerDownEvent(
          position: Offset(10, 10),
          pressure: 0.7,
        ),
      );
      expect(controller.activePoints.length, equals(1));

      // 2. Pointer Move
      controller.handlePointerMove(
        const PointerMoveEvent(
          position: Offset(20, 20),
          pressure: 0.8,
        ),
      );
      expect(controller.activePoints.length, equals(2));

      // 3. Pointer Up
      controller.handlePointerUp(
        const PointerUpEvent(
          position: Offset(20, 20),
        ),
      );

      expect(controller.activePoints, isEmpty);
      expect(controller.document.strokes.length, equals(1));
      expect(controller.canUndo, isTrue);
      expect(controller.isModified, isTrue);

      // Verify stroke points
      final stroke = controller.document.strokes.first;
      expect(stroke.points.length, equals(2));
      expect(stroke.points[0].x, equals(10));
      expect(stroke.points[1].x, equals(20));
    });

    test('Undo and redo functionality restores strokes correctly', () {
      final controller = CanvasController();

      // Draw stroke
      controller.handlePointerDown(const PointerDownEvent(position: Offset(5, 5)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(10, 10)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(10, 10)));

      expect(controller.document.strokes.length, equals(1));

      // Undo
      controller.undo();
      expect(controller.document.strokes.length, equals(0));
      expect(controller.canRedo, isTrue);

      // Redo
      controller.redo();
      expect(controller.document.strokes.length, equals(1));
      expect(controller.canRedo, isFalse);
    });

    test('Eraser tool deletes intersecting strokes', () {
      final controller = CanvasController();

      // Draw stroke across (50, 50) -> (60, 60)
      controller.handlePointerDown(const PointerDownEvent(position: Offset(50, 50)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(60, 60)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(60, 60)));

      expect(controller.document.strokes.length, equals(1));

      // Switch to eraser and erase near (55, 55)
      controller.setTool(CanvasTool.eraser);
      controller.handlePointerDown(const PointerDownEvent(position: Offset(55, 55)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(55, 55)));

      expect(controller.document.strokes, isEmpty);
    });

    test('Clear canvas empties all strokes and marks modified', () {
      final controller = CanvasController();
      controller.handlePointerDown(const PointerDownEvent(position: Offset(1, 1)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(2, 2)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(2, 2)));

      expect(controller.document.strokes.length, equals(1));

      controller.clearCanvas();
      expect(controller.document.strokes, isEmpty);
      expect(controller.isModified, isTrue);
    });
  });
}
