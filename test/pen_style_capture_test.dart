import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/note_document.dart';

void main() {
  test('Stroke style is captured at pointer-down before toolbar changes', () {
    final controller = CanvasController();
    addTearDown(controller.dispose);
    final initial = controller.currentProperty.toJson();
    controller.handlePointerDown(
      const PointerDownEvent(position: Offset(100, 200)),
    );
    controller.setColor(Colors.blue);
    controller.setStrokeWidth(8);
    controller.handlePointerMove(
      const PointerMoveEvent(position: Offset(120, 230)),
    );
    controller.handlePointerUp(
      const PointerUpEvent(position: Offset(120, 230)),
    );
    expect(controller.document.strokes.single.property.toJson(), initial);
    expect(controller.document.strokes.single.points.map((p) => p.toOffset()), [
      const Offset(100, 200),
      const Offset(120, 230),
    ]);
  });

  test(
    'Live and committed ink retain all parameters across preset/tool changes',
    () {
      final controller = CanvasController();
      addTearDown(controller.dispose);
      controller.setPenProperty(
        PenPreset.defaults.last.property.copyWith(opacity: 0.637),
      );
      final initial = controller.currentProperty.toJson();
      controller.handlePointerDown(
        const PointerDownEvent(position: Offset(100, 200)),
      );
      controller.setPenProperty(PenPreset.defaults.first.property);
      controller.setTool(CanvasTool.eraser);
      expect(controller.activeProperty.toJson(), initial);
      controller.handlePointerMove(
        const PointerMoveEvent(position: Offset(120, 230)),
      );
      controller.handlePointerUp(
        const PointerUpEvent(position: Offset(120, 230)),
      );
      expect(controller.document.strokes.single.property.toJson(), initial);
      expect(controller.document.strokes.single.points, hasLength(2));
      expect(
        controller.activeProperty.toJson(),
        controller.currentProperty.toJson(),
      );
      controller.setTool(CanvasTool.highlighter);
      final highlighter = controller.currentProperty.toJson();
      controller.handlePointerDown(
        const PointerDownEvent(position: Offset(200, 200)),
      );
      controller.setPenProperty(PenPreset.defaults.last.property);
      controller.handlePointerUp(
        const PointerUpEvent(position: Offset(200, 200)),
      );
      expect(controller.document.strokes.last.property.toJson(), highlighter);
    },
  );

  test(
    'Cancel and document switch release style capture without leaking points',
    () {
      final controller = CanvasController();
      addTearDown(controller.dispose);
      for (final cancel in [
        () => controller.handlePointerCancel(const PointerCancelEvent()),
        controller.cancelActivePoints,
        () => controller.setDocument(NoteDocument()),
      ]) {
        controller.handlePointerDown(
          const PointerDownEvent(position: Offset(100, 200)),
        );
        cancel();
        controller.setPenProperty(PenPreset.defaults.last.property);
        controller.handlePointerUp(const PointerUpEvent());
        expect(controller.document.strokes, isEmpty);
        expect(
          controller.activeProperty.toJson(),
          controller.penProperty.toJson(),
        );
      }
      controller.handlePointerDown(
        const PointerDownEvent(position: Offset(100, 200)),
      );
      controller.handlePointerUp(
        const PointerUpEvent(position: Offset(100, 200)),
      );
      expect(
        controller.document.strokes.single.property.toJson(),
        controller.penProperty.toJson(),
      );
    },
  );
}
