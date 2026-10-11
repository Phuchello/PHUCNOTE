import 'dart:ui';

import 'package:phucnote/drawing/view_painter.dart';

import 'p02_cache_metrics.dart';

/// Isolated frame preparation; production painter and cache remain at baseline.
class P02CachePainter extends PhucNoteViewPainter {
  P02CachePainter({
    required super.document,
    required super.backgroundColor,
    required super.repaintCounter,
    super.strokeCache,
    super.viewportOffset,
    super.zoomScale,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final cache = strokeCache;
    if (cache is P02MeasuredCache) {
      cache.beginFrame(
        Rect.fromLTRB(
          -viewportOffset.dx / zoomScale,
          -viewportOffset.dy / zoomScale,
          (size.width - viewportOffset.dx) / zoomScale,
          (size.height - viewportOffset.dy) / zoomScale,
        ),
        documentStrokeCount: document.strokes.length,
      );
    }
    super.paint(canvas, size);
  }
}
