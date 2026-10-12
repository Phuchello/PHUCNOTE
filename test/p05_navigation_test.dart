import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'support/localized_app.dart';

void main() {
  testWidgets('stylus gesture locks out lingering touch pan', (tester) async {
    final c = CanvasController();
    addTearDown(c.dispose);
    await tester.pumpWidget(localizedApp(home: Scaffold(body: CanvasView(controller: c))));
    await tester.pumpAndSettle();
    final origin = tester.getTopLeft(find.byType(CanvasView));
    final touch = await tester.startGesture(origin + const Offset(100, 100), pointer: 10, kind: PointerDeviceKind.touch);
    await touch.moveBy(const Offset(10, 10));
    await tester.pump();
    final stylus = await tester.startGesture(origin + const Offset(200, 200), pointer: 20, kind: PointerDeviceKind.stylus);
    await stylus.moveBy(const Offset(10, 0));
    await stylus.up();
    await tester.pump();
    final savedOffset = c.viewportOffset;
    await touch.moveBy(const Offset(20, 20));
    await tester.pump();
    expect(c.viewportOffset, savedOffset);
    expect(c.document.strokes.length, 1);
    await touch.up();
    await tester.pump();
    final newTouch = await tester.startGesture(origin + const Offset(150, 150), pointer: 11, kind: PointerDeviceKind.touch);
    await newTouch.moveBy(const Offset(10, 10));
    await tester.pump();
    expect(c.viewportOffset, isNot(savedOffset));
    await newTouch.up();
  });

  testWidgets('palm rejection ignores large touch events', (tester) async {
    final c = CanvasController();
    addTearDown(c.dispose);
    await tester.pumpWidget(localizedApp(home: Scaffold(body: CanvasView(controller: c))));
    await tester.pumpAndSettle();
    final origin = tester.getTopLeft(find.byType(CanvasView));
    await tester.sendEventToBinding(PointerDownEvent(pointer: 30, kind: PointerDeviceKind.touch, position: origin + const Offset(100, 100), size: .9, radiusMajor: 50, radiusMinor: 40));
    await tester.sendEventToBinding(PointerMoveEvent(pointer: 30, kind: PointerDeviceKind.touch, position: origin + const Offset(120, 120), delta: const Offset(20, 20), size: .9, radiusMajor: 50, radiusMinor: 40));
    await tester.sendEventToBinding(PointerUpEvent(pointer: 30, kind: PointerDeviceKind.touch, position: origin + const Offset(120, 120)));
    await tester.pump();
    expect(c.viewportOffset, Offset.zero);
    expect(c.document.strokes, isEmpty);
  });

  testWidgets('lingering contact cannot navigate a replacement document', (tester) async {
    final c = CanvasController();
    addTearDown(c.dispose);
    await tester.pumpWidget(localizedApp(home: Scaffold(body: CanvasView(controller: c))));
    final origin = tester.getTopLeft(find.byType(CanvasView));
    final touch = await tester.startGesture(origin + const Offset(100, 100), pointer: 40);
    await touch.moveBy(const Offset(10, 10));
    await tester.pump();
    c.setDocument(NoteDocument());
    expect(c.viewportOffset, Offset.zero);
    await touch.moveBy(const Offset(20, 20));
    await tester.pump();
    expect(c.viewportOffset, Offset.zero);
    await touch.up();
    expect(c.document.strokes, isEmpty);
  });
}
