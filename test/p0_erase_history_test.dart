import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/drawing/canvas_action.dart';
import 'package:phucnote/drawing/canvas_controller.dart';

StrokeElement _stroke(String id, double x) => StrokeElement(
  id: id,
  points: [StrokePoint(x: x, y: 100)],
  property: const StrokeProperty(colorValue: 0xff000000),
);

List<String> _ids(CanvasController controller) =>
    controller.document.strokes.map((stroke) => stroke.id).toList();

void main() {
  test(
    'erase action restores unsorted original indices through repeated cycles',
    () {
      final strokes = [for (var i = 0; i < 5; i++) _stroke('$i', i * 100)];
      final document = NoteDocument(strokes: List.of(strokes));
      final action = EraseStrokesAction(
        erasedStrokes: [strokes[3], strokes[1]],
        originalIndices: [3, 1],
      );
      action.execute(document);
      for (var cycle = 0; cycle < 3; cycle++) {
        action.undo(document);
        expect(document.strokes, orderedEquals(strokes));
        action.redo(document);
        expect(
          document.strokes,
          orderedEquals([strokes[0], strokes[2], strokes[4]]),
        );
      }
    },
  );

  test('multi-hit erase remembers indices before the entire gesture', () {
    final controller = CanvasController(
      document: NoteDocument(
        strokes: [
          _stroke('a', 0),
          _stroke('b', 100),
          _stroke('c', 100),
          _stroke('d', 300),
          _stroke('e', 400),
        ],
      ),
    );
    addTearDown(controller.dispose);
    controller.setTool(CanvasTool.eraser);
    controller.handlePointerDown(
      const PointerDownEvent(position: Offset(100, 100)),
    );
    controller.handlePointerMove(
      const PointerMoveEvent(position: Offset(300, 100)),
    );
    controller.handlePointerUp(
      const PointerUpEvent(position: Offset(300, 100)),
    );
    expect(_ids(controller), ['a', 'e']);
    for (var cycle = 0; cycle < 3; cycle++) {
      controller.undo();
      expect(_ids(controller), ['a', 'b', 'c', 'd', 'e']);
      controller.redo();
      expect(_ids(controller), ['a', 'e']);
    }
  });

  test('cancelled erase retains an undoable action and deterministic redo', () {
    final controller = CanvasController(
      document: NoteDocument(
        strokes: [_stroke('a', 0), _stroke('b', 100), _stroke('c', 200)],
      ),
    );
    addTearDown(controller.dispose);
    controller.setTool(CanvasTool.eraser);
    controller.handlePointerDown(
      const PointerDownEvent(position: Offset(100, 100)),
    );
    controller.handlePointerCancel(const PointerCancelEvent());
    expect(_ids(controller), ['a', 'c']);
    expect(controller.canUndo, isTrue);
    for (var cycle = 0; cycle < 3; cycle++) {
      controller.undo();
      expect(_ids(controller), ['a', 'b', 'c']);
      controller.redo();
      expect(_ids(controller), ['a', 'c']);
    }
  });

  test('clear during erase preserves both actions and exact ordering', () {
    final controller = CanvasController();
    addTearDown(controller.dispose);
    for (final x in [0.0, 100.0, 200.0]) {
      controller.handlePointerDown(PointerDownEvent(position: Offset(x, 100)));
      controller.handlePointerUp(PointerUpEvent(position: Offset(x, 100)));
    }
    final original = _ids(controller);
    controller.setTool(CanvasTool.eraser);
    controller.handlePointerDown(
      const PointerDownEvent(position: Offset(100, 100)),
    );
    controller.clearCanvas();
    controller.handlePointerCancel(const PointerCancelEvent());
    for (var cycle = 0; cycle < 3; cycle++) {
      controller.undo();
      expect(_ids(controller), [original[0], original[2]]);
      controller.undo();
      expect(_ids(controller), original);
      controller.redo();
      expect(_ids(controller), [original[0], original[2]]);
      controller.redo();
      expect(_ids(controller), isEmpty);
    }
    controller.undo();
    controller.undo();
    controller.undo();
    expect(_ids(controller), original.take(2));
    controller.redo();
    expect(_ids(controller), original);
  });
}
