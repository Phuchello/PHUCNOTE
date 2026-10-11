import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Source-page points to logical pixels. DPR only controls raster resolution.
class PageViewport extends ChangeNotifier {
  Size page = const Size(595, 841);
  Size view = Size.zero;
  double scale = 1;
  Offset offset = Offset.zero;
  bool widthFit = false;
  Offset toScreen(Offset document) => document * scale + offset;
  Offset toDocument(Offset screen) => (screen - offset) / scale;
  Rect get pageBounds => Offset.zero & page;
  Rect get screenBounds => Rect.fromLTWH(
    offset.dx,
    offset.dy,
    page.width * scale,
    page.height * scale,
  );
  void layout(Size source, Size viewport) {
    final changed = page != source || view != viewport;
    page = source;
    view = viewport;
    if (changed) fit(width: widthFit, notify: false);
  }

  void fit({bool width = false, bool notify = true}) {
    if (view.isEmpty || page.isEmpty) return;
    widthFit = width;
    scale = width
        ? (view.width - 32) / page.width
        : math.min(
            (view.width - 32) / page.width,
            (view.height - 32) / page.height,
          );
    scale = scale.clamp(0.1, 8);
    offset = Offset(
      (view.width - page.width * scale) / 2,
      width ? 16 : (view.height - page.height * scale) / 2,
    );
    if (notify) notifyListeners();
  }

  void zoom(double next, Offset focal) {
    final anchor = toDocument(focal);
    scale = next.clamp(0.1, 8);
    offset = focal - anchor * scale;
    notifyListeners();
  }

  void pan(Offset delta) {
    offset += delta;
    notifyListeners();
  }
}
