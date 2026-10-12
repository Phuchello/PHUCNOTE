import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/ui/canvas_view.dart';

import 'support/localized_app.dart';

PointerDownEvent down(
  int id,
  Offset p, {
  PointerDeviceKind kind = PointerDeviceKind.stylus,
  int time = 0,
}) => PointerDownEvent(
  pointer: id,
  kind: kind,
  position: p,
  pressure: .65,
  tilt: .3,
  timeStamp: Duration(milliseconds: time),
);
PointerMoveEvent move(
  int id,
  Offset p, {
  PointerDeviceKind kind = PointerDeviceKind.stylus,
  int time = 0,
}) => PointerMoveEvent(
  pointer: id,
  kind: kind,
  position: p,
  pressure: .7,
  tilt: .4,
  timeStamp: Duration(milliseconds: time),
);
PointerUpEvent up(
  int id,
  Offset p, {
  PointerDeviceKind kind = PointerDeviceKind.stylus,
  int time = 0,
}) => PointerUpEvent(
  pointer: id,
  kind: kind,
  position: p,
  pressure: 0,
  timeStamp: Duration(milliseconds: time),
);

void main() {
  for (final kind in [
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  ]) {
    test(
      'INPUT-01/04/05 unrelated $kind cannot replace, append, finish or cancel owner',
      () {
        final c = CanvasController();
        addTearDown(c.dispose);
        c.handlePointerDown(down(10, const Offset(10, 10)));
        c.handlePointerMove(move(10, const Offset(20, 10)));
        c.handlePointerDown(down(11, const Offset(90, 90), kind: kind));
        c.handlePointerMove(move(11, const Offset(95, 95), kind: kind));
        c.handlePointerUp(up(11, const Offset(99, 99), kind: kind));
        c.handlePointerCancel(PointerCancelEvent(pointer: 11, kind: kind));
        expect(c.isStylusActive, isTrue);
        expect(c.document.strokes, isEmpty);
        expect(c.activePoints.map((p) => p.toOffset()), [
          const Offset(10, 10),
          const Offset(20, 10),
        ]);
        c.handlePointerMove(move(10, const Offset(30, 10)));
        c.handlePointerUp(up(10, const Offset(40, 10)));
        expect(c.document.strokes.single.points.map((p) => p.toOffset()), [
          const Offset(10, 10),
          const Offset(20, 10),
          const Offset(30, 10),
          const Offset(40, 10),
        ]);
        expect(c.isStylusActive, isFalse);
      },
    );
  }
  for (final moves in [0, 1]) {
    test(
      'INPUT-02/03 tap or single move ($moves): identical UP stays unduplicated',
      () {
        final c = CanvasController();
        addTearDown(c.dispose);
        c.handlePointerDown(down(1, const Offset(10, 10)));
        if (moves == 1) c.handlePointerMove(move(1, const Offset(12, 10)));
        c.handlePointerUp(up(1, Offset(moves == 0 ? 10 : 12, 10)));
        expect(c.document.strokes.single.points, hasLength(1 + moves));
        expect(
          c.document.strokes.single.points.last.pressure,
          moves == 0 ? .65 : .7,
        );
      },
    );
  }
  test('INPUT-02 rapid lift uses transformed final location and last accepted axes', () {
    final c = CanvasController();
    addTearDown(c.dispose);
    c.panViewport(const Offset(30, -40));
    c.zoomAt(Offset.zero, 2);
    c.handlePointerDown(down(1, c.canvasToScreen(const Offset(10, 10))));
    c.handlePointerMove(move(1, c.canvasToScreen(const Offset(20, 10))));
    c.handlePointerUp(up(1, c.canvasToScreen(const Offset(35, 12))));
    final stroke = c.document.strokes.single;
    expect(stroke.points.last.toOffset(), const Offset(35, 12));
    expect(stroke.points.last.pressure, .7);
    expect(stroke.points.last.tilt, .4);
    final json = stroke.toJson();
    expect(
      BflySerializer.decode(BflySerializer.encode(c.document)).strokes.single
          .toJson(),
      json,
    );
    for (var i = 0; i < 3; i++) {
      c.undo();
      c.redo();
      expect(c.document.strokes.single.toJson(), json);
    }
  });
  test(
    'INPUT-02 lift without move captures endpoint without pressure taper',
    () {
      final c = CanvasController();
      addTearDown(c.dispose);
      c.handlePointerDown(down(1, const Offset(10, 10)));
      c.handlePointerUp(up(1, const Offset(25, 10)));
      expect(c.document.strokes.single.points, hasLength(2));
      expect(c.document.strokes.single.points.last.pressure, .65);
      expect(c.document.strokes.single.points.last.tilt, .3);
    },
  );
  test('INPUT-06 own cancel discards ink; late moves/up and missing down are inert', () {
    final c = CanvasController();
    addTearDown(c.dispose);
    c.handlePointerDown(down(1, const Offset(10, 10)));
    c.handlePointerCancel(
      const PointerCancelEvent(pointer: 1, kind: PointerDeviceKind.stylus),
    );
    c.handlePointerMove(move(1, const Offset(20, 10)));
    c.handlePointerUp(up(1, const Offset(30, 10)));
    c.handlePointerUp(up(2, const Offset(30, 10)));
    expect(c.document.strokes, isEmpty);
    expect(c.canUndo, isFalse);
    expect(c.isStylusActive, isFalse);
    c.handlePointerDown(down(2, const Offset(10, 10)));
    c.handlePointerUp(up(2, const Offset(10, 10)));
    c.handlePointerUp(up(2, const Offset(30, 10)));
    expect(c.document.strokes, hasLength(1));
  });
  test('INPUT-01 duplicate down, wrong kind and older timestamp cannot alter owner', () {
    final c = CanvasController();
    addTearDown(c.dispose);
    c.handlePointerDown(down(1, const Offset(10, 10), time: 10));
    c.handlePointerDown(down(1, const Offset(90, 90), time: 11));
    c.handlePointerMove(move(1, const Offset(20, 10), time: 20));
    c.handlePointerMove(move(1, const Offset(90, 90), time: 15));
    c.handlePointerUp(
      up(1, const Offset(90, 90), kind: PointerDeviceKind.touch, time: 30),
    );
    c.handlePointerCancel(
      const PointerCancelEvent(
        pointer: 1,
        kind: PointerDeviceKind.stylus,
        timeStamp: Duration(milliseconds: 15),
      ),
    );
    c.handlePointerUp(up(1, const Offset(90, 90), time: 15));
    expect(c.activePoints, hasLength(2));
    c.handlePointerUp(up(1, const Offset(30, 10), time: 30));
    expect(c.document.strokes.single.points, hasLength(3));
  });
  test(
    'INPUT-07 inverted eraser is owned; cancellation keeps undoable erase',
    () {
      final c = CanvasController();
      addTearDown(c.dispose);
      c.handlePointerDown(down(1, const Offset(10, 10)));
      c.handlePointerUp(up(1, const Offset(10, 10)));
      final stroke = c.document.strokes.single;
      c.handlePointerDown(
        down(2, const Offset(10, 10), kind: PointerDeviceKind.invertedStylus),
      );
      c.handlePointerUp(
        up(3, const Offset(10, 10), kind: PointerDeviceKind.invertedStylus),
      );
      expect(c.eraserPosition, isNotNull);
      c.handlePointerCancel(
        const PointerCancelEvent(
          pointer: 2,
          kind: PointerDeviceKind.invertedStylus,
        ),
      );
      expect(c.document.strokes, isEmpty);
      c.undo();
      expect(c.document.strokes.single, same(stroke));
      c.redo();
      expect(c.document.strokes, isEmpty);
    },
  );
  test(
    'INPUT-08 finger owns its stroke until release; stylus cannot preempt it',
    () {
      final c = CanvasController()..setStylusOnlyMode(false);
      addTearDown(c.dispose);
      c.handlePointerDown(
        down(1, const Offset(10, 10), kind: PointerDeviceKind.touch),
      );
      c.handlePointerDown(down(2, const Offset(90, 90)));
      c.handlePointerUp(up(2, const Offset(99, 99)));
      c.handlePointerUp(
        up(1, const Offset(20, 10), kind: PointerDeviceKind.touch),
      );
      expect(c.document.strokes.single.points.map((p) => p.toOffset()), [
        const Offset(10, 10),
        const Offset(20, 10),
      ]);
    },
  );
  test(
    'Document switch and explicit navigation cancel release pointer ownership',
    () {
      final c = CanvasController();
      addTearDown(c.dispose);
      for (final reset in [
        c.cancelActivePoints,
        () => c.setDocument(NoteDocument()),
      ]) {
        c.handlePointerDown(down(1, const Offset(10, 10)));
        reset();
        expect(c.isStylusActive, isFalse);
        c.handlePointerMove(move(1, const Offset(99, 99)));
        c.handlePointerUp(up(1, const Offset(99, 99)));
        c.handlePointerDown(down(2, const Offset(10, 10)));
        c.handlePointerUp(up(2, const Offset(10, 10)));
        expect(c.document.strokes, hasLength(1));
      }
    },
  );
  testWidgets(
    'INPUT-08 two-finger navigation cancels provisional finger ink and still zooms',
    (tester) async {
      final c = CanvasController();
      addTearDown(c.dispose);
      await tester.pumpWidget(
        localizedApp(
          home: Scaffold(body: CanvasView(controller: c)),
        ),
      );
      final origin = tester.getTopLeft(find.byType(CanvasView));
      final a = await tester.startGesture(
        origin + const Offset(100, 100),
        pointer: 41,
      );
      final b = await tester.startGesture(
        origin + const Offset(200, 100),
        pointer: 42,
      );
      await b.moveBy(const Offset(50, 20));
      await a.up();
      await b.up();
      expect(c.zoomScale, greaterThan(1));
      expect(c.document.strokes, isEmpty);
      final pen = await tester.startGesture(
        origin + const Offset(150, 150),
        pointer: 43,
        kind: PointerDeviceKind.stylus,
      );
      await pen.moveBy(const Offset(10, 0));
      await pen.up();
      expect(c.document.strokes, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );
}
