import 'package:flutter/gestures.dart';
// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

import 'support/editor_interactions.dart';

import 'support/localized_app.dart';

void main() {
  group('A4 Portrait Fit & Clipping Verification', () {
    test('Reproduce portrait clipping at 800px width with scale 1.0', () {
      final controller = CanvasController();
      controller.setShowA4Guides(true);
      controller.resetViewport();

      const viewportWidth = 800.0;
      const viewportHeight = 1280.0;
      final visibleRect = controller.getVisibleCanvasRect(const Size(viewportWidth, viewportHeight));

      // At scale 1.0 and offset zero, visible rect is 0..800
      expect(visibleRect.left, equals(0.0));
      expect(visibleRect.right, equals(800.0));

      // A4 page is 840 wide, from x=0 to x=840
      const a4Width = CanvasController.a4Width;
      expect(a4Width, equals(840.0));

      // Screen positions
      final pageLeftScreen = controller.canvasToScreen(const Offset(0, 0)).dx;
      final pageRightScreen = controller.canvasToScreen(const Offset(a4Width, 0)).dx;

      expect(pageLeftScreen, equals(0.0));
      // DEFECT CONFIRMED: pageRightScreen (840.0) is clipped beyond viewportWidth (800.0)
      expect(pageRightScreen > viewportWidth, isTrue);
      expect(pageRightScreen - viewportWidth, equals(40.0));

      // Footer bounds check:
      // Footer text right edge is at a4Width - 24.0 = 816.0
      const footerRightDoc = a4Width - 24.0;
      final footerRightScreen = controller.canvasToScreen(const Offset(footerRightDoc, 0)).dx;
      // DEFECT CONFIRMED: Footer extends 16px past screen width 800
      expect(footerRightScreen > viewportWidth, isTrue);
      expect(footerRightScreen - viewportWidth, equals(16.0));
    });

    test('REGRESSION: A4 preview is fully visible when fit-to-width is requested', () {
      final controller = CanvasController();
      controller.setShowA4Guides(true);

      const viewportWidth = 800.0;
      const viewportHeight = 1280.0;
      const a4Width = CanvasController.a4Width;
      const a4Height = CanvasController.a4Height;

      // Draw an initial stroke before fit-to-width to verify document coordinate preservation
      controller.handlePointerDown(const PointerDownEvent(kind: PointerDeviceKind.stylus, position: Offset(100, 200)));
      controller.handlePointerMove(const PointerMoveEvent(kind: PointerDeviceKind.stylus, position: Offset(200, 200)));
      controller.handlePointerUp(const PointerUpEvent(kind: PointerDeviceKind.stylus, position: Offset(200, 200)));

      expect(controller.document.strokes.length, equals(1));
      final initialStrokeDocX = controller.document.strokes.first.points.first.x;
      final initialStrokeDocY = controller.document.strokes.first.points.first.y;

      // Request fit-to-width
      controller.fitToWidth(viewportWidth);

      // Verify zoom and horizontal offset
      final expectedZoom = 800.0 / 840.0;
      expect(controller.zoomScale, closeTo(expectedZoom, 1e-4));
      expect(controller.viewportOffset.dx, closeTo(0.0, 1e-4));

      // Screen positions of A4 Page 1 borders
      final pageLeftScreen = controller.canvasToScreen(const Offset(0, 0)).dx;
      final pageRightScreen = controller.canvasToScreen(const Offset(a4Width, 0)).dx;
      final pageTopScreen = controller.canvasToScreen(const Offset(0, 0)).dy;
      final pageBottomScreen = controller.canvasToScreen(const Offset(0, a4Height)).dy;

      // Assert entire A4 page is fully visible within viewport bounds
      expect(pageLeftScreen, greaterThanOrEqualTo(0.0));
      expect(pageRightScreen, lessThanOrEqualTo(viewportWidth));
      expect(pageTopScreen, greaterThanOrEqualTo(0.0));
      expect(pageBottomScreen, lessThanOrEqualTo(viewportHeight));

      // Footer bounds check: Footer text must be fully on-screen
      const footerRightDoc = a4Width - 24.0;
      final footerRightScreen = controller.canvasToScreen(const Offset(footerRightDoc, 0)).dx;
      expect(footerRightScreen, lessThanOrEqualTo(viewportWidth));
      expect(viewportWidth - footerRightScreen, greaterThan(20.0)); // >20px margin from screen edge

      // Document coordinates preserved: original stroke points unchanged
      expect(controller.document.strokes.first.points.first.x, equals(initialStrokeDocX));
      expect(controller.document.strokes.first.points.first.y, equals(initialStrokeDocY));

      // Eraser accuracy: screen hit testing accurately maps back to canvas coordinates
      final screenPos = controller.canvasToScreen(Offset(initialStrokeDocX, initialStrokeDocY));
      final mappedBack = controller.screenToCanvas(screenPos);
      expect(mappedBack.dx, closeTo(initialStrokeDocX, 1e-4));
      expect(mappedBack.dy, closeTo(initialStrokeDocY, 1e-4));

      // Continuous paper mode preserved: toggling guides off leaves canvas fully functional
      controller.toggleA4Guides();
      expect(controller.showA4Guides, isFalse);
      expect(controller.document.strokes.length, equals(1));
    });

    testWidgets('ToolbarWidget displays Fit to Width button when A4 guides active', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;

      final controller = CanvasController();
      controller.resetViewport();

      await tester.pumpWidget(localizedApp(
        home: Scaffold(
          body: ToolbarWidget(controller: controller),
        ),
      ));

      // Initially A4 guides are inactive -> Fit to Width button not present
      await openDrawingOptions(tester);
      expect(find.byTooltip(vi.fitToWidth), findsNothing);

      // Toggle A4 guides active
      await tester.tap(find.byTooltip(vi.continuousPaperHint));
      await tester.pumpAndSettle();

      expect(controller.showA4Guides, isTrue);
      await openDrawingOptions(tester);
      expect(find.byTooltip(vi.fitToWidth), findsOneWidget);

      // Tap Fit to Width
      await tester.tap(find.byTooltip(vi.fitToWidth));
      await tester.pumpAndSettle();

      expect(controller.zoomScale, closeTo(800.0 / 840.0, 1e-4));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
