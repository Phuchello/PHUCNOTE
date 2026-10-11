import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'drawing/stroke_geometry.dart';
import 'ink_sheet.dart';
import 'page_viewport.dart';

/// Stylus/mouse ink and finger navigation use the same page transform.
/// A gesture owns its sheet and transform until up/cancel or page change.
class InkSurface extends StatefulWidget {
  final PageViewport viewport;
  final InkSheet sheet;
  final InkTool tool;
  final Widget background;
  const InkSurface({
    super.key,
    required this.viewport,
    required this.sheet,
    required this.tool,
    required this.background,
  });
  @override
  State<InkSurface> createState() => _InkSurfaceState();
}

class _InkSurfaceState extends State<InkSurface> {
  int? _pointer;
  double _inkScale = 1, _gestureScale = 1;
  Offset _inkOffset = Offset.zero, _anchor = Offset.zero;
  InkSheet? _owner;
  Size _inkView = Size.zero;
  @override
  void didUpdateWidget(covariant InkSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sheet != widget.sheet ||
        (_pointer != null && _inkView != widget.viewport.view)) {
      _finish();
    }
  }

  void _finish() {
    final owner = _owner;
    _owner = null;
    _pointer = null;
    owner?.end();
  }

  @override
  void dispose() {
    _finish();
    super.dispose();
  }

  Offset _point(Offset local) => (local - _inkOffset) / _inkScale;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.sheet,
    builder: (context, _) => Listener(
      onPointerDown: (event) {
        if (_pointer != null || event.kind == PointerDeviceKind.touch) return;
        _inkScale = widget.viewport.scale;
        _inkOffset = widget.viewport.offset;
        _inkView = widget.viewport.view;
        final tool = event.kind == PointerDeviceKind.invertedStylus
            ? InkTool.eraser
            : widget.tool;
        if (widget.sheet.begin(
          _point(event.localPosition),
          widget.viewport.pageBounds,
          tool,
          event.pressure,
        )) {
          _owner = widget.sheet;
          _pointer = event.pointer;
        }
      },
      onPointerMove: (event) {
        if (event.pointer == _pointer) {
          _owner?.move(_point(event.localPosition), event.pressure);
        }
      },
      onPointerUp: (event) {
        if (event.pointer == _pointer) _finish();
      },
      onPointerCancel: (event) {
        if (event.pointer == _pointer) _finish();
      },
      child: GestureDetector(
        supportedDevices: const {PointerDeviceKind.touch},
        behavior: HitTestBehavior.opaque,
        onScaleStart: (details) {
          _gestureScale = widget.viewport.scale;
          _anchor = widget.viewport.toDocument(details.localFocalPoint);
        },
        onScaleUpdate: (details) {
          if (_pointer != null) return;
          widget.viewport.scale = (_gestureScale * details.scale).clamp(.1, 8);
          widget.viewport.offset =
              details.localFocalPoint - _anchor * widget.viewport.scale;
          widget.viewport.pan(Offset.zero);
        },
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.background,
              IgnorePointer(
                child: CustomPaint(
                  painter: InkPainter(widget.viewport, widget.sheet),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class InkPainter extends CustomPainter {
  final PageViewport viewport;
  final InkSheet sheet;
  InkPainter(this.viewport, this.sheet);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(viewport.offset.dx, viewport.offset.dy);
    canvas.scale(viewport.scale);
    canvas.clipRect(viewport.pageBounds);
    for (final stroke in [
      ...sheet.strokes,
      if (sheet.pending != null) sheet.pending!,
    ]) {
      canvas.drawPath(
        StrokeGeometry.generatePath(stroke.points, stroke.property),
        Paint()..color = stroke.property.color,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InkPainter oldDelegate) => true;
}
