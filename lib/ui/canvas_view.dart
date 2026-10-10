// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../drawing/canvas_controller.dart';
import '../drawing/foreground_painter.dart';
import '../drawing/view_painter.dart';

/// The handwriting canvas widget with dual-layer RepaintBoundary architecture,
/// configurable stylus-only gating, and seamless touch pan navigation.
class CanvasView extends StatelessWidget {
  final CanvasController controller;
  final Color paperColor;

  const CanvasView({
    super.key,
    required this.controller,
    this.paperColor = const Color(0xFFFAFAFA),
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ClipRect(
          child: Listener(
            onPointerDown: (event) {
              if (controller.stylusOnlyMode && event.kind == PointerDeviceKind.touch) {
                // In stylus-only mode, touch is dedicated for panning/navigation
                return;
              }
              controller.handlePointerDown(event);
            },
            onPointerMove: (event) {
              if (controller.stylusOnlyMode && event.kind == PointerDeviceKind.touch) {
                // Pan viewport smoothly with finger dragging
                controller.panViewport(event.delta);
                return;
              }
              controller.handlePointerMove(event);
            },
            onPointerUp: (event) {
              if (controller.stylusOnlyMode && event.kind == PointerDeviceKind.touch) {
                return;
              }
              controller.handlePointerUp(event);
            },
            onPointerCancel: (event) {
              controller.handlePointerCancel(event);
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Static background and committed strokes (cached raster)
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PhucNoteViewPainter(
                      document: controller.document,
                      backgroundColor: paperColor,
                      repaintCounter: controller.repaintCounter,
                      viewportOffset: controller.viewportOffset,
                    ),
                    isComplex: true,
                  ),
                ),

                // Layer 2: Fast in-flight active stroke / eraser indicator (120-165Hz render loop)
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PhucNoteForegroundPainter(
                      activePoints: controller.activePoints,
                      property: controller.currentProperty,
                      eraserPosition: controller.eraserPosition,
                      eraserRadius: controller.eraserRadius,
                      viewportOffset: controller.viewportOffset,
                    ),
                    willChange: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
