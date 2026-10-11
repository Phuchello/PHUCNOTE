import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/ui/canvas_view.dart';

import 'support/localized_app.dart';

void main() {
  for (final trackedBeforeStylus in [false, true]) {
    testWidgets(
      'Touch cancellation preserves stylus (tracked=$trackedBeforeStylus)',
      (tester) async {
        final controller = CanvasController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          localizedApp(
            home: Scaffold(body: CanvasView(controller: controller)),
          ),
        );
        final origin = tester.getTopLeft(find.byType(CanvasView));
        TestGesture? touch;
        if (trackedBeforeStylus) {
          touch = await tester.startGesture(
            origin + const Offset(80, 80),
            pointer: 20,
          );
        }
        final pen = await tester.startGesture(
          origin + const Offset(120, 120),
          pointer: 21,
          kind: PointerDeviceKind.stylus,
        );
        await pen.moveBy(const Offset(20, 10));
        touch ??= await tester.startGesture(
          origin + const Offset(80, 80),
          pointer: 20,
        );
        await touch.cancel();
        expect(controller.isStylusActive, isTrue);
        expect(controller.activePoints, hasLength(2));
        await pen.moveBy(const Offset(20, -10));
        await pen.up();
        expect(controller.document.strokes.single.points, hasLength(3));
        controller.undo();
        controller.redo();
        expect(controller.document.strokes.single.points, hasLength(3));
      },
    );
  }
}
