// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/drawing/view_painter.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

import 'support/editor_interactions.dart';

import 'support/localized_app.dart';

/// Test spy canvas tracking drawRect and drawPath invocations.
class A4SpyCanvas extends Fake implements Canvas {
  final List<Rect> drawnRects = [];
  final List<Rect> paragraphBounds = [];
  int drawPathCount = 0;
  int drawLineCount = 0;

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
    drawnRects.add(rect);
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    drawLineCount++;
  }

  @override
  void drawPath(Path path, Paint paint) {
    drawPathCount++;
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    paragraphBounds.add(offset & Size(paragraph.longestLine, paragraph.height));
  }
}

void main() {
  group('A4 Notebook Guides & Layout Tests', () {
    // 1. Correct A4 ratio and page numbering calculations
    test('A4 dimensions strictly maintain the 210:297 aspect ratio', () {
      const width = CanvasController.a4Width;
      const height = CanvasController.a4Height;
      const gap = CanvasController.a4PageGap;

      // Exact aspect ratio check
      expect(width / height, closeTo(210.0 / 297.0, 1e-9));
      expect(width * 297.0, equals(height * 210.0));

      const stride = height + gap;

      // Page 1 bounds
      const page1Top = 0.0;
      const page1Bottom = page1Top + height;
      expect(page1Bottom, equals(1188.0));

      // Page 2 bounds
      const page2Top = stride;
      const page2Bottom = page2Top + height;
      expect(page2Top, equals(1212.0));
      expect(page2Bottom, equals(2400.0));

      // Page 10 bounds
      const page10Top = 9 * stride;
      expect(page10Top, equals(10908.0));
    });

    // 2. Page guides remaining aligned during pan and zoom transforms
    test('Page guides remain strictly aligned with canvas coordinates during pan/zoom', () {
      final controller = CanvasController();
      controller.setShowA4Guides(true);
      expect(controller.showA4Guides, isTrue);

      const page1Origin = Offset.zero;
      const page1BottomRight = Offset(CanvasController.a4Width, CanvasController.a4Height);

      // Default transform (offset: 0, zoom: 1)
      expect(controller.canvasToScreen(page1Origin), equals(Offset.zero));
      expect(controller.canvasToScreen(page1BottomRight), equals(const Offset(840.0, 1188.0)));

      // Pan viewport by (100, -500)
      controller.panViewport(const Offset(100, -500));
      expect(controller.canvasToScreen(page1Origin), equals(const Offset(100.0, -500.0)));
      expect(controller.canvasToScreen(page1BottomRight), equals(const Offset(940.0, 688.0)));

      // Zoom to 2.0x around focal point (200, 200)
      controller.zoomAt(const Offset(200, 200), 2.0);
      expect(controller.zoomScale, equals(2.0));

      // Canvas logical dimensions of page 1 remain immutable
      expect(CanvasController.a4Width, equals(840.0));
      expect(CanvasController.a4Height, equals(1188.0));

      // Screen projection scales properly with zoom
      final screenBottomRight = controller.canvasToScreen(page1BottomRight);
      final screenTopLeft = controller.canvasToScreen(page1Origin);
      expect(screenBottomRight.dx - screenTopLeft.dx, closeTo(840.0 * 2.0, 1e-4));
      expect(screenBottomRight.dy - screenTopLeft.dy, closeTo(1188.0 * 2.0, 1e-4));
    });

    // 3. Rendering only visible guides in viewport
    test('ViewPainter renders guides strictly for visible pages in the viewport', () {
      final doc = NoteDocument();

      // Viewport at top (y = 0..1000) -> should only draw Page 1
      final painterTop = PhucNoteViewPainter(
        document: doc,
        backgroundColor: Colors.white,
        repaintCounter: 1,
        viewportOffset: Offset.zero,
        zoomScale: 1.0,
        showA4Guides: true,
      );

      final spyCanvasTop = A4SpyCanvas();
      painterTop.paint(spyCanvasTop, const Size(800, 1000));

      // Page outlines drawn (excluding paper bg rect):
      // Only Page 1 outline rect should be drawn
      final pageRectsTop = spyCanvasTop.drawnRects.where((r) => r.width == CanvasController.a4Width).toList();
      expect(pageRectsTop.length, equals(1));
      expect(pageRectsTop.first.top, equals(0.0));

      // Viewport panned deep down to y = 50,000 (y in [50000, 51000])
      // Stride = 1212.0. Page ~42 is at 41 * 1212 = 49692..50880
      final painterDeep = PhucNoteViewPainter(
        document: doc,
        backgroundColor: Colors.white,
        repaintCounter: 2,
        viewportOffset: const Offset(0, -50000),
        zoomScale: 1.0,
        showA4Guides: true,
      );

      final spyCanvasDeep = A4SpyCanvas();
      painterDeep.paint(spyCanvasDeep, const Size(800, 1000));

      final pageRectsDeep = spyCanvasDeep.drawnRects.where((r) => r.width == CanvasController.a4Width).toList();
      // Should only contain the visible page(s) around 50,000, never Page 1
      expect(pageRectsDeep.every((r) => r.top > 40000), isTrue);
      expect(pageRectsDeep.any((r) => r.top == 0.0), isFalse);
    });

    test('Page numbers retain readable size and footer alignment when zoomed out', () {
      final doc = NoteDocument(paperTemplate: PaperTemplate.blank);

      Rect pageNumberAt(double zoom) {
        final canvas = A4SpyCanvas();
        PhucNoteViewPainter(
          document: doc,
          backgroundColor: Colors.white,
          repaintCounter: 0,
          zoomScale: zoom,
          showA4Guides: true,
        ).paint(canvas, Size(900 * zoom, 1250 * zoom));
        return canvas.paragraphBounds.single;
      }

      final normal = pageNumberAt(1);
      final zoomedOut = pageNumberAt(CanvasController.minZoom);
      expect(zoomedOut.height * CanvasController.minZoom, closeTo(normal.height, 0.01));
      expect(zoomedOut.width * CanvasController.minZoom, closeTo(normal.width, 0.01));
      expect(zoomedOut.right, closeTo(CanvasController.a4Width - 24, 0.01));
      expect(zoomedOut.bottom, closeTo(CanvasController.a4Height - 12, 0.01));
    });

    // 4. No changed stroke coordinates when A4 guides are toggled
    test('Toggling A4 guides preserves stroke coordinates without alteration', () {
      final controller = CanvasController();

      // Draw stroke
      controller.handlePointerDown(const PointerDownEvent(position: Offset(150, 300)));
      controller.handlePointerMove(const PointerMoveEvent(position: Offset(200, 450)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(200, 450)));

      expect(controller.document.strokes.length, equals(1));
      final originalX = controller.document.strokes.first.points[0].x;
      final originalY = controller.document.strokes.first.points[0].y;

      // Toggle A4 guides ON
      controller.toggleA4Guides();
      expect(controller.showA4Guides, isTrue);
      expect(controller.document.strokes.first.points[0].x, equals(originalX));
      expect(controller.document.strokes.first.points[0].y, equals(originalY));

      // Toggle A4 guides OFF
      controller.toggleA4Guides();
      expect(controller.showA4Guides, isFalse);
      expect(controller.document.strokes.first.points[0].x, equals(originalX));
      expect(controller.document.strokes.first.points[0].y, equals(originalY));
    });

    // 5. Drawing and erasing work seamlessly with A4 guides enabled
    test('Drawing, erasing, undo, and redo work with A4 guides enabled', () {
      final controller = CanvasController();
      controller.setShowA4Guides(true);

      // Draw stroke on page 1
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 200)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(200, 200)));
      expect(controller.document.strokes.length, equals(1));

      // Erase stroke
      controller.setTool(CanvasTool.eraser);
      controller.handlePointerDown(const PointerDownEvent(position: Offset(200, 200)));
      controller.handlePointerUp(const PointerUpEvent(position: Offset(200, 200)));
      expect(controller.document.strokes, isEmpty);

      // Undo
      controller.undo();
      expect(controller.document.strokes.length, equals(1));

      // Redo
      controller.redo();
      expect(controller.document.strokes, isEmpty);
    });

    // 6. Toolbar toggle button interaction
    testWidgets('ToolbarWidget contains functional A4 page guides toggle button', (tester) async {
      final controller = CanvasController();
      expect(controller.showA4Guides, isFalse);

      await tester.pumpWidget(
        localizedApp(
          home: Scaffold(
            body: ToolbarWidget(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await openDrawingOptions(tester);
      final a4Button = find.byTooltip(vi.continuousPaperHint);
      expect(a4Button, findsOneWidget);

      // Tap to enable A4 guides
      await tester.tap(a4Button);
      await tester.pumpAndSettle();

      expect(controller.showA4Guides, isTrue);
      await openDrawingOptions(tester);
      expect(find.byTooltip(vi.a4WritingHint), findsOneWidget);

      // Tap to disable A4 guides
      await tester.tap(find.byTooltip(vi.a4WritingHint));
      await tester.pumpAndSettle();

      expect(controller.showA4Guides, isFalse);
      await openDrawingOptions(tester);
      expect(find.byTooltip(vi.continuousPaperHint), findsOneWidget);
    });
  });
}
