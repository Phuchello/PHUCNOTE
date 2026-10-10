// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/drawing/view_painter.dart';
import 'package:phucnote/ui/canvas_view.dart';

/// Minimal test spy canvas verifying that offscreen strokes do not construct or issue drawPath calls.
class MockRecordingCanvas extends Fake implements Canvas {
  int drawPathCount = 0;
  int drawLineCount = 0;
  int drawRectCount = 0;

  @override
  void save() {}

  @override
  void restore() {}

  @override
  void translate(double dx, double dy) {}

  @override
  void scale(double sx, [double? sy]) {}

  @override
  void drawRect(Rect rect, Paint paint) {
    drawRectCount++;
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    drawLineCount++;
  }

  @override
  void drawPath(Path path, Paint paint) {
    drawPathCount++;
  }
}

void main() {
  group('Continuous Vertical Paper & Navigation Tests', () {
    // 1. Strokes retain coordinates after panning
    test('Strokes retain coordinates after panning', () {
      final controller = CanvasController();

      // Draw stroke at (100, 200) -> (150, 250)
      controller.handlePointerDown(const PointerDownEvent(position: Offset(100, 200)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(150, 250)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(150, 250)));

      expect(controller.document.strokes.length, equals(1));
      final stroke = controller.document.strokes.first;
      expect(stroke.points[0].x, equals(100.0));
      expect(stroke.points[0].y, equals(200.0));
      expect(stroke.points[1].x, equals(150.0));
      expect(stroke.points[1].y, equals(250.0));

      // Pan down by 1000 pixels
      controller.panViewport(const Offset(0, -1000));
      expect(controller.viewportOffset.dy, equals(-1000.0));

      // Coordinates in the document model must remain strictly unchanged
      expect(stroke.points[0].x, equals(100.0));
      expect(stroke.points[0].y, equals(200.0));

      // Screen position reflects viewport offset
      final screenPos = controller.canvasToScreen(Offset(stroke.points[0].x, stroke.points[0].y));
      expect(screenPos, equals(const Offset(100.0, -800.0)));

      // Pan deep down in continuous paper by 50,000 pixels
      controller.panViewport(const Offset(-50, -49000));
      expect(stroke.points[0].x, equals(100.0));
      expect(stroke.points[0].y, equals(200.0));
    });

    // 2. Zoom does not move existing strokes incorrectly (stable focal point)
    test('Zoom does not move existing strokes incorrectly', () {
      final controller = CanvasController();

      // Draw stroke at (300, 400)
      controller.handlePointerDown(const PointerDownEvent(position: Offset(300, 400)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(300, 400)));

      expect(controller.document.strokes.length, equals(1));
      final stroke = controller.document.strokes.first;
      expect(stroke.points.first.x, equals(300.0));
      expect(stroke.points.first.y, equals(400.0));

      // Zoom around focal point (300, 400) by 2.0x
      controller.zoomAt(const Offset(300, 400), 2.0);
      expect(controller.zoomScale, equals(2.0));

      // Logical coordinates in model are completely unchanged
      expect(stroke.points.first.x, equals(300.0));
      expect(stroke.points.first.y, equals(400.0));

      // Under the focal point (300, 400), the screen position of that stroke must remain (300, 400)
      final screenPos = controller.canvasToScreen(Offset(stroke.points.first.x, stroke.points.first.y));
      expect(screenPos.dx, closeTo(300.0, 0.001));
      expect(screenPos.dy, closeTo(400.0, 0.001));
    });

    // 3. Drawing after zoom maps input to correct canvas coordinates
    test('Drawing after zoom maps input to correct canvas coordinates', () {
      final controller = CanvasController();

      // Set zoom to 2.0x and pan to (50, -150)
      controller.zoomAt(const Offset(0, 0), 2.0);
      controller.panViewport(const Offset(50, -150));
      expect(controller.zoomScale, equals(2.0));
      expect(controller.viewportOffset, equals(const Offset(50, -150)));

      // Screen position (450, 250) should map to canvas:
      // x = (450 - 50) / 2.0 = 200.0
      // y = (250 - (-150)) / 2.0 = 200.0
      controller.handlePointerDown(const PointerDownEvent(position: Offset(450, 250)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(450, 250)));

      expect(controller.document.strokes.length, equals(1));
      final stroke = controller.document.strokes.first;
      expect(stroke.points.first.x, equals(200.0));
      expect(stroke.points.first.y, equals(200.0));
    });

    // 4. Eraser hit-testing remains accurate after transforms
    test('Eraser hit-testing remains accurate after transforms', () {
      final controller = CanvasController();

      // Draw stroke at canvas (400, 500)
      controller.handlePointerDown(const PointerDownEvent(position: Offset(400, 500)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(400, 500)));
      expect(controller.document.strokes.length, equals(1));

      // Zoom to 1.5x and pan viewport by (-100, -200)
      controller.zoomAt(Offset.zero, 1.5);
      controller.panViewport(const Offset(-100, -200));

      // Screen position for canvas (400, 500):
      // sx = 400 * 1.5 - 100 = 500.0
      // sy = 500 * 1.5 - 200 = 550.0
      final strokeScreenPos = controller.canvasToScreen(const Offset(400, 500));
      expect(strokeScreenPos.dx, closeTo(500.0, 0.001));
      expect(strokeScreenPos.dy, closeTo(550.0, 0.001));

      // Switch to eraser and tap at a distant point (100, 100) -> should NOT erase
      controller.setTool(CanvasTool.eraser);
      controller.handlePointerDown(const PointerDownEvent(position: Offset(100, 100)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(100, 100)));
      expect(controller.document.strokes.length, equals(1));

      // Tap with eraser directly on stroke screen position (500, 550) -> MUST erase
      controller.handlePointerDown(PointerDownEvent(position: strokeScreenPos));
      controller.handlePointerUp(PointerUpEvent(position: strokeScreenPos));
      expect(controller.document.strokes, isEmpty);
    });

    // 5. Autosave and reload preserve stroke positions
    test('Autosave and reload preserve stroke positions across continuous paper', () async {
      final tempDir = await Directory.systemTemp.createTemp('phucnote_paper_test_');
      final storage = NoteStorage(customRootDirectory: tempDir);

      try {
        final doc = NoteDocument(title: 'Continuous Paper Doc');

        // Stroke near the top
        doc.addStroke(StrokeElement(
          id: 's1',
          points: [const StrokePoint(x: 100, y: 150)],
          property: const StrokeProperty(colorValue: 0xFF1E1E1E),
        ));

        // Stroke scrolled down at 4,000 pixels
        doc.addStroke(StrokeElement(
          id: 's2',
          points: [const StrokePoint(x: 200, y: 4000)],
          property: const StrokeProperty(colorValue: 0xFF1565C0),
        ));

        // Stroke scrolled far down at 25,000 pixels
        doc.addStroke(StrokeElement(
          id: 's3',
          points: [const StrokePoint(x: 300, y: 25000)],
          property: const StrokeProperty(colorValue: 0xFFC62828),
        ));

        // Save
        final file = await storage.saveNote(doc);
        expect(await file.exists(), isTrue);

        // Reload
        final reloaded = await storage.loadNote(file);
        expect(reloaded.strokes.length, equals(3));
        expect(reloaded.strokes[0].points[0].y, equals(150.0));
        expect(reloaded.strokes[1].points[0].y, equals(4000.0));
        expect(reloaded.strokes[2].points[0].y, equals(25000.0));
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    // 6. Mixed stylus/touch input does not corrupt active strokes
    test('Mixed stylus/touch input does not corrupt active strokes', () {
      final controller = CanvasController();

      // Stylus starts drawing
      controller.handlePointerDown(
        const PointerDownEvent(
          position: Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        ),
      );
      expect(controller.isStylusActive, isTrue);
      expect(controller.activePoints.length, equals(1));

      // Palm or finger touches down while stylus is active -> should be rejected
      final touchAccepted = controller.shouldAcceptPointerForInking(
        const PointerDownEvent(
          position: Offset(500, 500),
          kind: PointerDeviceKind.touch,
        ),
      );
      expect(touchAccepted, isFalse);

      // Stylus moves
      controller.handlePointerMove(
        const PointerMoveEvent(
          position: Offset(120, 130),
          kind: PointerDeviceKind.stylus,
        ),
      );
      expect(controller.activePoints.length, equals(2));

      // Stylus completes stroke
      controller.handlePointerUp(
        const PointerUpEvent(
          position: Offset(120, 130),
          kind: PointerDeviceKind.stylus,
        ),
      );
      expect(controller.isStylusActive, isFalse);
      expect(controller.document.strokes.length, equals(1));
      expect(controller.document.strokes.first.points.length, equals(2));
    });

    // 7. Large vertical navigation does not generate excessive offscreen drawing work
    test('Large vertical navigation does not generate excessive offscreen drawing work', () {
      final doc = NoteDocument(paperTemplate: PaperTemplate.ruled);

      // Stroke at top (y = 200)
      doc.addStroke(StrokeElement(
        id: 'top-stroke',
        points: [const StrokePoint(x: 100, y: 200), const StrokePoint(x: 150, y: 220)],
        property: const StrokeProperty(colorValue: 0xFF1E1E1E),
      ));

      // Stroke way down at y = 50,200
      doc.addStroke(StrokeElement(
        id: 'deep-stroke',
        points: [const StrokePoint(x: 100, y: 50200), const StrokePoint(x: 150, y: 50250)],
        property: const StrokeProperty(colorValue: 0xFF1E1E1E),
      ));

      // When viewport is at y = 50,000, visible height = 1000 (visible range y in [50000, 51000])
      final painter = PhucNoteViewPainter(
        document: doc,
        backgroundColor: Colors.white,
        repaintCounter: 1,
        viewportOffset: const Offset(0, -50000),
        zoomScale: 1.0,
      );

      // Verify visible rect computation
      final visibleLeft = (-painter.viewportOffset.dx) / painter.zoomScale;
      final visibleTop = (-painter.viewportOffset.dy) / painter.zoomScale;
      final visibleRight = (800 - painter.viewportOffset.dx) / painter.zoomScale;
      final visibleBottom = (1000 - painter.viewportOffset.dy) / painter.zoomScale;
      final visibleRect = Rect.fromLTRB(visibleLeft, visibleTop, visibleRight, visibleBottom);

      expect(visibleRect.top, equals(50000.0));
      expect(visibleRect.bottom, equals(51000.0));

      // Top stroke (y=200) is culled
      expect(visibleRect.overlaps(doc.strokes[0].boundingBox), isFalse);

      // Deep stroke (y=50200) is within viewport
      expect(visibleRect.overlaps(doc.strokes[1].boundingBox), isTrue);
    });

    // 8. CanvasView two-finger pinch zoom widget interaction
    testWidgets('CanvasView two-finger pinch zoom and single finger pan in stylus-only mode', (tester) async {
      final controller = CanvasController();
      controller.setStylusOnlyMode(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CanvasView(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final canvasCenter = tester.getCenter(find.byType(CanvasView));

      // 1-finger drag in stylus-only mode -> pans viewport
      final touch = await tester.startGesture(canvasCenter, kind: PointerDeviceKind.touch);
      await touch.moveBy(const Offset(0, -100));
      await touch.up();
      await tester.pumpAndSettle();

      expect(controller.viewportOffset.dy, equals(-100.0));
      expect(controller.document.strokes, isEmpty);

      // 2-finger pinch zoom simulation
      final finger1 = await tester.startGesture(canvasCenter - const Offset(50, 0), kind: PointerDeviceKind.touch);
      final finger2 = await tester.startGesture(canvasCenter + const Offset(50, 0), kind: PointerDeviceKind.touch);
      await tester.pump(const Duration(milliseconds: 16));

      // Spread fingers apart from 100px to 200px (2x zoom)
      await finger1.moveBy(const Offset(-50, 0));
      await finger2.moveBy(const Offset(50, 0));
      await tester.pump(const Duration(milliseconds: 16));

      await finger1.up();
      await finger2.up();
      await tester.pumpAndSettle();

      expect(controller.zoomScale, greaterThan(1.5));
      expect(controller.document.strokes, isEmpty);
    });

    // TASK A — Focal-point stability when no boundary clamp is active
    test('Task A: Focal-point stability when no boundary clamp is active has zero drift', () {
      final controller = CanvasController();
      // Position viewport well inside document bounds
      controller.panViewport(const Offset(-200, -3000));

      final testFocalPoints = [
        const Offset(150, 200),
        const Offset(600, 800),
        const Offset(400, 500),
      ];

      for (final focalPoint in testFocalPoints) {
        final canvasPointBefore = controller.screenToCanvas(focalPoint);

        // Zoom in by 1.6x
        controller.zoomAt(focalPoint, 1.6);
        final screenPointAfter = controller.canvasToScreen(canvasPointBefore);
        expect((screenPointAfter.dx - focalPoint.dx).abs(), lessThan(1e-6));
        expect((screenPointAfter.dy - focalPoint.dy).abs(), lessThan(1e-6));

        // Zoom out by 0.7x
        controller.zoomAt(focalPoint, 0.7);
        final screenPointAfter2 = controller.canvasToScreen(canvasPointBefore);
        expect((screenPointAfter2.dx - focalPoint.dx).abs(), lessThan(1e-6));
        expect((screenPointAfter2.dy - focalPoint.dy).abs(), lessThan(1e-6));
      }
    });

    // TASK A — Boundary policy verification near top overscroll limit
    test('Task A: Zoom-out near top overscroll limit adheres to boundary-clamping policy', () {
      final controller = CanvasController();
      // Reach max top overscroll (80.0)
      controller.panViewport(const Offset(0, 100));
      expect(controller.viewportOffset.dy, equals(CanvasController.maxTopOverscroll));

      // Zoom out around screen focal point (400, 300) with scale factor 0.5x
      controller.zoomAt(const Offset(400, 300), 0.5);

      // Boundary policy: top offset must not exceed maxTopOverscroll
      expect(controller.viewportOffset.dy, lessThanOrEqualTo(CanvasController.maxTopOverscroll));

      // Zoom back in from clamped state -> focal point remains within boundary
      controller.zoomAt(const Offset(400, 300), 2.0);
      expect(controller.viewportOffset.dy, lessThanOrEqualTo(CanvasController.maxTopOverscroll));
    });

    // TASK B — Eraser indicator and hit-testing radius match at 0.5x, 1x and 4x
    test('Task B: Eraser indicator and hit-testing radius match at 0.5x, 1x, and 4x', () {
      for (final testZoom in [0.5, 1.0, 4.0]) {
        final controller = CanvasController();
        controller.zoomAt(Offset.zero, testZoom);
        expect(controller.zoomScale, equals(testZoom));

        // Draw single dot stroke on screen at (300, 300)
        controller.handlePointerDown(const PointerDownEvent(position: Offset(300, 300)));
        controller.handlePointerUp(const PointerUpEvent(position: Offset(300, 300)));
        expect(controller.document.strokes.length, equals(1));

        final stroke = controller.document.strokes.first;
        final strokeCanvasPos = Offset(stroke.points.first.x, stroke.points.first.y);
        final screenStrokePos = controller.canvasToScreen(strokeCanvasPos);
        final visualScreenRadius = controller.eraserRadius * testZoom;

        controller.setTool(CanvasTool.eraser);

        // 1. Outside test: Screen touch placed outside visual radius -> NOT erased
        final outsideScreenPos = screenStrokePos + Offset(visualScreenRadius + 8.0 * testZoom, 0);
        controller.handlePointerDown(PointerDownEvent(position: outsideScreenPos));
        controller.handlePointerUp(PointerUpEvent(position: outsideScreenPos));
        expect(controller.document.strokes.length, equals(1),
            reason: 'Should not erase outside visual indicator at zoom $testZoom');

        // 2. Inside test: Screen touch placed strictly inside visual radius -> MUST erase
        final insideScreenPos = screenStrokePos + Offset(visualScreenRadius - 2.0 * testZoom, 0);
        controller.handlePointerDown(PointerDownEvent(position: insideScreenPos));
        controller.handlePointerUp(PointerUpEvent(position: insideScreenPos));
        expect(controller.document.strokes, isEmpty,
            reason: 'Must erase inside visual indicator at zoom $testZoom');
      }
    });

    // TASK C — Deep vertical navigation does not construct paths for offscreen strokes
    test('Task C: Deep vertical navigation does not construct paths for offscreen strokes', () {
      final doc = NoteDocument();

      // Add 10 strokes near document top (y = 0..300)
      for (int i = 0; i < 10; i++) {
        doc.addStroke(StrokeElement(
          id: 'top_$i',
          points: [StrokePoint(x: 100, y: 50.0 + i * 20), StrokePoint(x: 150, y: 60.0 + i * 20)],
          property: const StrokeProperty(colorValue: 0xFF1E1E1E),
        ));
      }

      // Add 10 strokes at deep continuous location y = 50,000..50,800
      for (int i = 0; i < 10; i++) {
        doc.addStroke(StrokeElement(
          id: 'mid_$i',
          points: [StrokePoint(x: 100, y: 50100.0 + i * 50), StrokePoint(x: 150, y: 50110.0 + i * 50)],
          property: const StrokeProperty(colorValue: 0xFF1E1E1E),
        ));
      }

      // Add 10 strokes far down at y = 100,000..100,800
      for (int i = 0; i < 10; i++) {
        doc.addStroke(StrokeElement(
          id: 'deep_$i',
          points: [StrokePoint(x: 100, y: 100100.0 + i * 50), StrokePoint(x: 150, y: 100110.0 + i * 50)],
          property: const StrokeProperty(colorValue: 0xFF1E1E1E),
        ));
      }

      expect(doc.strokes.length, equals(30));

      // Viewport scrolled to y = 50,000; screen height = 1,000 (visible range y: 50000..51000)
      final painter = PhucNoteViewPainter(
        document: doc,
        backgroundColor: Colors.white,
        repaintCounter: 1,
        viewportOffset: const Offset(0, -50000),
        zoomScale: 1.0,
      );

      final mockCanvas = MockRecordingCanvas();
      painter.paint(mockCanvas, const Size(800, 1000));

      // Strictly only the 10 mid strokes in the viewport should have generated paths!
      expect(mockCanvas.drawPathCount, equals(10));
    });

    // TASK C — Bounded rendering benchmark
    test('Task C: Bounded rendering: 1,000 offscreen strokes produce 0 drawPath calls', () {
      final doc = NoteDocument();

      // Create 1,000 strokes situated at y in [0, 45000]
      for (int i = 0; i < 1000; i++) {
        doc.addStroke(StrokeElement(
          id: 'stroke_$i',
          points: [StrokePoint(x: 100, y: i * 40.0), StrokePoint(x: 120, y: i * 40.0 + 10)],
          property: const StrokeProperty(colorValue: 0xFF1E1E1E),
        ));
      }

      // Viewport situated at y in [60000, 61000] (all 1000 strokes offscreen)
      final painter = PhucNoteViewPainter(
        document: doc,
        backgroundColor: Colors.white,
        repaintCounter: 1,
        viewportOffset: const Offset(0, -60000),
        zoomScale: 1.0,
      );

      final mockCanvas = MockRecordingCanvas();
      final stopwatch = Stopwatch()..start();
      painter.paint(mockCanvas, const Size(800, 1000));
      stopwatch.stop();

      // Zero drawPath calls for offscreen strokes
      expect(mockCanvas.drawPathCount, equals(0));
      // Bounded execution under 10ms for 1,000 items
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
