// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../drawing/canvas_controller.dart';
import '../drawing/foreground_painter.dart';
import '../drawing/view_painter.dart';

/// The handwriting canvas widget with dual-layer RepaintBoundary architecture.
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
            onPointerDown: controller.handlePointerDown,
            onPointerMove: controller.handlePointerMove,
            onPointerUp: controller.handlePointerUp,
            onPointerCancel: controller.handlePointerCancel,
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
