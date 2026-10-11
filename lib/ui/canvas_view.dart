// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../drawing/canvas_controller.dart';
import '../drawing/foreground_painter.dart';
import '../drawing/view_painter.dart';

/// The handwriting canvas widget with dual-layer RepaintBoundary architecture,
/// configurable stylus-only gating, two-finger pinch zoom, and continuous vertical navigation.
class CanvasView extends StatefulWidget {
  final CanvasController controller;
  final Color paperColor;

  const CanvasView({
    super.key,
    required this.controller,
    this.paperColor = const Color(0xFFFAFAFA),
  });

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  final Map<int, Offset> _activeTouchPointers = {};
  Offset? _prevFocalPoint;
  double? _prevDistance;
  bool _isPinching = false;

  bool _isStylus(PointerEvent event) {
    return event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isStylus(event)) {
      widget.controller.handlePointerDown(event);
      return;
    }

    // Touch pointer (finger / mouse)
    if (widget.controller.isStylusActive) {
      // Software palm rejection: stylus is actively down, reject touch
      return;
    }

    _activeTouchPointers[event.pointer] = event.localPosition;

    if (_activeTouchPointers.length == 1) {
      if (!widget.controller.stylusOnlyMode) {
        widget.controller.handlePointerDown(event);
      }
    } else if (_activeTouchPointers.length >= 2) {
      _isPinching = true;
      if (!widget.controller.stylusOnlyMode) {
        widget.controller.cancelActivePoints();
      }
      final pts = _activeTouchPointers.values.toList();
      _prevFocalPoint = (pts[0] + pts[1]) / 2;
      _prevDistance = (pts[0] - pts[1]).distance;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isStylus(event)) {
      widget.controller.handlePointerMove(event);
      return;
    }

    if (widget.controller.isStylusActive) {
      return;
    }

    if (!_activeTouchPointers.containsKey(event.pointer)) {
      return;
    }
    _activeTouchPointers[event.pointer] = event.localPosition;

    if (_activeTouchPointers.length >= 2) {
      // Two-finger pinch zoom and navigation
      final pts = _activeTouchPointers.values.toList();
      final currentFocalPoint = (pts[0] + pts[1]) / 2;
      final currentDistance = (pts[0] - pts[1]).distance;

      if (_prevFocalPoint != null &&
          _prevDistance != null &&
          _prevDistance! > 1.0 &&
          currentDistance > 1.0) {
        final scaleDelta = currentDistance / _prevDistance!;
        widget.controller.applyTransform(
          focalPoint: currentFocalPoint,
          prevFocalPoint: _prevFocalPoint!,
          scaleDelta: scaleDelta,
        );
      }
      _prevFocalPoint = currentFocalPoint;
      _prevDistance = currentDistance;
    } else if (_activeTouchPointers.length == 1 && !_isPinching) {
      if (widget.controller.stylusOnlyMode) {
        widget.controller.panViewport(event.delta);
      } else {
        widget.controller.handlePointerMove(event);
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isStylus(event)) {
      widget.controller.handlePointerUp(event);
      return;
    }

    _activeTouchPointers.remove(event.pointer);

    if (_activeTouchPointers.length < 2) {
      _isPinching = false;
      _prevFocalPoint = null;
      _prevDistance = null;
    }

    if (_activeTouchPointers.isEmpty) {
      if (!widget.controller.stylusOnlyMode) {
        widget.controller.handlePointerUp(event);
      }
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_isStylus(event)) {
      widget.controller.handlePointerCancel(event);
      return;
    }

    _activeTouchPointers.remove(event.pointer);

    if (_activeTouchPointers.length < 2) {
      _isPinching = false;
      _prevFocalPoint = null;
      _prevDistance = null;
    }

    if (_activeTouchPointers.isEmpty) {
      if (!widget.controller.stylusOnlyMode) {
        widget.controller.handlePointerCancel(event);
      }
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (HardwareKeyboard.instance.isControlPressed) {
        final scaleFactor = event.scrollDelta.dy < 0 ? 1.1 : 0.9;
        widget.controller.zoomAt(event.localPosition, scaleFactor);
      } else {
        widget.controller.panViewport(-event.scrollDelta);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return ClipRect(
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            onPointerSignal: _onPointerSignal,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Static background and committed strokes (cached raster)
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PhucNoteViewPainter(
                      document: widget.controller.document,
                      backgroundColor: widget.paperColor,
                      repaintCounter: widget.controller.repaintCounter,
                      viewportOffset: widget.controller.viewportOffset,
                      zoomScale: widget.controller.zoomScale,
                      showA4Guides: widget.controller.showA4Guides,
                    ),
                    isComplex: true,
                  ),
                ),

                // Layer 2: Fast in-flight active stroke / eraser indicator (120-165Hz render loop)
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PhucNoteForegroundPainter(
                      activePoints: widget.controller.activePoints,
                      property: widget.controller.activeProperty,
                      eraserPosition: widget.controller.eraserPosition,
                      eraserRadius: widget.controller.eraserRadius,
                      viewportOffset: widget.controller.viewportOffset,
                      zoomScale: widget.controller.zoomScale,
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
