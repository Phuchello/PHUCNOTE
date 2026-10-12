import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/ui/canvas_view.dart';

import 'support/localized_app.dart';

void main() {
  test('first-run default stylusOnlyMode is true', () {
    final controller = CanvasController();
    addTearDown(controller.dispose);

    expect(controller.stylusOnlyMode, isTrue);
  });

  testWidgets('real touch gesture pans with zero strokes', (tester) async {
    final controller = CanvasController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      localizedApp(
        home: Scaffold(
          body: CanvasView(controller: controller),
        ),
      ),
    );

    final origin = tester.getTopLeft(find.byType(CanvasView));
    final initialOffset = controller.viewportOffset;

    final gesture = await tester.startGesture(
      origin + const Offset(100, 100),
      pointer: 1,
    );
    await gesture.moveBy(const Offset(50, 50));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(controller.document.strokes.isEmpty, isTrue);
    expect(controller.viewportOffset, isNot(equals(initialOffset)));
  });

  testWidgets('real stylus gesture commits one stroke', (tester) async {
    final controller = CanvasController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      localizedApp(
        home: Scaffold(
          body: CanvasView(controller: controller),
        ),
      ),
    );

    final origin = tester.getTopLeft(find.byType(CanvasView));

    final gesture = await tester.startGesture(
      origin + const Offset(100, 100),
      pointer: 2,
      kind: PointerDeviceKind.stylus,
    );
    await gesture.moveBy(const Offset(30, 30));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(controller.document.strokes.length, equals(1));
  });

  testWidgets('real pinch zoom changes scale with zero strokes', (tester) async {
    final controller = CanvasController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      localizedApp(
        home: Scaffold(
          body: CanvasView(controller: controller),
        ),
      ),
    );

    final origin = tester.getTopLeft(find.byType(CanvasView));
    final initialScale = controller.zoomScale;

    final finger1 = await tester.startGesture(
      origin + const Offset(120, 150),
      pointer: 3,
    );
    final finger2 = await tester.startGesture(
      origin + const Offset(220, 150),
      pointer: 4,
    );

    await finger1.moveBy(const Offset(-40, 0));
    await finger2.moveBy(const Offset(40, 0));
    await tester.pump();

    await finger1.up();
    await finger2.up();
    await tester.pump();

    expect(controller.document.strokes.isEmpty, isTrue);
    expect(controller.zoomScale, isNot(equals(initialScale)));
  });
}
