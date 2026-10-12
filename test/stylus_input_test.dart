// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/drawing/canvas_controller.dart';

void main() {
  group('Stylus Input & Palm Rejection Handling', () {
    test('when stylusOnlyMode is false, standard touch produces strokes', () {
      final controller = CanvasController()..setStylusOnlyMode(false);
      expect(controller.stylusOnlyMode, isFalse);

      // Simulate touch down, move, up
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(10, 10),
        kind: PointerDeviceKind.touch,
      ));
      expect(controller.activePoints, isNotEmpty);

      controller.handlePointerMove(const PointerMoveEvent(
        position: Offset(20, 20),
        kind: PointerDeviceKind.touch,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(20, 20),
        kind: PointerDeviceKind.touch,
      ));

      expect(controller.document.strokes.length, 1);
    });

    test('when stylusOnlyMode is true, touch events are rejected from inking', () {
      final controller = CanvasController()..setStylusOnlyMode(false);
      controller.setStylusOnlyMode(true);
      expect(controller.stylusOnlyMode, isTrue);

      // Simulate accidental palm or finger touch
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(50, 50),
        kind: PointerDeviceKind.touch,
      ));
      expect(controller.activePoints, isEmpty);

      controller.handlePointerMove(const PointerMoveEvent(
        position: Offset(60, 60),
        kind: PointerDeviceKind.touch,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(60, 60),
        kind: PointerDeviceKind.touch,
      ));

      expect(controller.document.strokes, isEmpty);
    });

    test('when stylusOnlyMode is true, stylus events are accepted for inking', () {
      final controller = CanvasController()..setStylusOnlyMode(false);
      controller.setStylusOnlyMode(true);

      // Simulate active stylus drawing
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(100, 100),
        kind: PointerDeviceKind.stylus,
        pressure: 0.75,
      ));
      expect(controller.activePoints, isNotEmpty);
      expect(controller.isStylusActive, isTrue);

      controller.handlePointerMove(const PointerMoveEvent(
        position: Offset(120, 120),
        kind: PointerDeviceKind.stylus,
        pressure: 0.85,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(120, 120),
        kind: PointerDeviceKind.stylus,
      ));

      expect(controller.document.strokes.length, 1);
      expect(controller.isStylusActive, isFalse);
    });

    test('palm touch is rejected when active stylus is in contact with screen', () {
      final controller = CanvasController()..setStylusOnlyMode(false);
      expect(controller.stylusOnlyMode, isFalse); // Stylus-only off

      // Stylus touches screen
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(200, 200),
        kind: PointerDeviceKind.stylus,
      ));
      expect(controller.isStylusActive, isTrue);

      // Simultaneous palm touch arrives while stylus is down
      const palmEvent = PointerDownEvent(
        position: Offset(250, 300),
        kind: PointerDeviceKind.touch,
      );
      expect(controller.shouldAcceptPointerForInking(palmEvent), isFalse);

      // Lift stylus
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(210, 210),
        kind: PointerDeviceKind.stylus,
      ));
      expect(controller.isStylusActive, isFalse);
    });

    test('abnormal palm contact size touch is rejected even when stylusOnlyMode is off', () {
      final controller = CanvasController()..setStylusOnlyMode(false);
      expect(controller.stylusOnlyMode, isFalse);

      // Touch with large palm radius/size
      const palmContactEvent = PointerDownEvent(
        position: Offset(150, 150),
        kind: PointerDeviceKind.touch,
        size: 0.8,
        radiusMajor: 50.0,
        radiusMinor: 40.0,
      );
      expect(controller.shouldAcceptPointerForInking(palmContactEvent), isFalse);
    });

    test('invertedStylus tip routes to eraser mode automatically', () {
      final controller = CanvasController()..setStylusOnlyMode(false);
      // Draw stroke first
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(10, 10),
        kind: PointerDeviceKind.stylus,
      ));
      controller.handlePointerMove(const PointerMoveEvent(
        position: Offset(20, 20),
        kind: PointerDeviceKind.stylus,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(20, 20),
        kind: PointerDeviceKind.stylus,
      ));
      expect(controller.document.strokes.length, 1);

      // Inverted stylus touches stroke
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(15, 15),
        kind: PointerDeviceKind.invertedStylus,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(15, 15),
        kind: PointerDeviceKind.invertedStylus,
      ));

      // Stroke was erased by inverted stylus
      expect(controller.document.strokes, isEmpty);
    });

    test('panViewport translates viewport without corrupting stroke document coordinates', () {
      final controller = CanvasController()..setStylusOnlyMode(false);
      controller.panViewport(const Offset(50, -30));
      expect(controller.viewportOffset, const Offset(50, -30));

      // Stylus draws at screen position (100, 100)
      controller.handlePointerDown(const PointerDownEvent(
        position: Offset(100, 100),
        kind: PointerDeviceKind.stylus,
      ));
      controller.handlePointerMove(const PointerMoveEvent(
        position: Offset(110, 110),
        kind: PointerDeviceKind.stylus,
      ));
      controller.handlePointerUp(const PointerUpEvent(
        position: Offset(110, 110),
        kind: PointerDeviceKind.stylus,
      ));

      // Canvas coordinates should be (100 - 50, 100 - (-30)) = (50, 130)
      final stroke = controller.document.strokes.first;
      expect(stroke.points.first.x, 50.0);
      expect(stroke.points.first.y, 130.0);
    });
  });
}
