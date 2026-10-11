import 'package:flutter/material.dart';

import '../core/models/stroke_point.dart';
import '../core/models/stroke_property.dart';
import '../drawing/stroke_geometry.dart';

/// A scratch pad, independent of document input, history and autosave.
class PenPreview extends StatefulWidget {
  final StrokeProperty property;
  const PenPreview({super.key, required this.property});

  @override
  State<PenPreview> createState() => _PenPreviewState();
}

class _PenPreviewState extends State<PenPreview> {
  final List<List<StrokePoint>> _strokes = [];
  List<StrokePoint>? _active;
  int? _pointer;

  StrokePoint _point(PointerEvent event) => StrokePoint(
    x: event.localPosition.dx,
    y: event.localPosition.dy,
    pressure: event.pressure.clamp(0.1, 1),
    tilt: event.tilt,
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Expanded(child: Text('Write here to preview')),
          IconButton(
            tooltip: 'Reset preview',
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _strokes.clear();
              _active = null;
              _pointer = null;
            }),
          ),
        ],
      ),
      Semantics(
        label: 'Handwriting preview',
        child: SizedBox(
          height: 132,
          child: ClipRect(
            child: GestureDetector(
              onPanStart: (_) {},
              onPanUpdate: (_) {},
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if (_pointer != null) return;
                  setState(() {
                    _pointer = event.pointer;
                    _active = [_point(event)];
                  });
                },
                onPointerMove: (event) {
                  if (_pointer != event.pointer) return;
                  setState(() => _active!.add(_point(event)));
                },
                onPointerUp: (event) {
                  if (_pointer != event.pointer) return;
                  setState(() {
                    _strokes.add(_active!);
                    _active = null;
                    _pointer = null;
                  });
                },
                onPointerCancel: (event) {
                  if (_pointer != event.pointer) return;
                  setState(() {
                    _active = null;
                    _pointer = null;
                  });
                },
                child: CustomPaint(
                  key: const ValueKey('pen-preview'),
                  painter: PenPreviewPainter(
                    property: widget.property,
                    strokes: [
                      ..._strokes.map((points) => List<StrokePoint>.of(points)),
                      if (_active != null) List<StrokePoint>.of(_active!),
                    ],
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class PenPreviewPainter extends CustomPainter {
  final StrokeProperty property;
  final List<List<StrokePoint>> strokes;
  const PenPreviewPainter({required this.property, required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF8F7F3),
    );
    final guide = Paint()
      ..color = const Color(0xFFD4D3CF)
      ..strokeWidth = 1;
    for (double y = 28; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guide);
    }
    final demo = [
      for (var i = 0; i < 60; i++)
        StrokePoint(
          x: 20 + i * (size.width - 40) / 59,
          y: 66.0 + [0, -18, -28, -18, 0, 18, 28, 18][i % 8],
          pressure: 0.15 + (i % 20) / 24,
        ),
    ];
    final ink = Paint()
      ..color = property.color
      ..style = PaintingStyle.fill;
    for (final points in strokes.isEmpty ? [demo] : strokes) {
      canvas.drawPath(StrokeGeometry.generatePath(points, property), ink);
    }
  }

  @override
  bool shouldRepaint(covariant PenPreviewPainter oldDelegate) => true;
}
