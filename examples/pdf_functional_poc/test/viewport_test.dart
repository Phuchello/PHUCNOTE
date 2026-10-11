import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_functional_poc/page_viewport.dart';

void main() {
  test('PDF-04/05: source aspect and distinct fit transforms', () {
    final view = PageViewport()
      ..layout(const Size(595, 841), const Size(1200, 640));
    final fit = view.scale;
    expect(
      view.screenBounds.width / view.screenBounds.height,
      closeTo(595 / 841, 1e-12),
    );
    expect(view.screenBounds.height, lessThanOrEqualTo(640));
    view.fit(width: true);
    expect(view.scale, greaterThan(fit));
    expect(view.screenBounds.width, closeTo(1168, 1e-10));
    view.layout(const Size(960, 540), const Size(1200, 640));
    expect(
      view.screenBounds.width / view.screenBounds.height,
      closeTo(16 / 9, 1e-12),
    );
  });
  test('PDF-06/07: inverse mapping after pan/zoom and orientation/DPR', () {
    final view = PageViewport()
      ..layout(const Size(595, 841), const Size(1200, 640));
    const point = Offset(180, 350);
    for (final dpr in [1.0, 2.0, 3.0]) {
      view.zoom(2, const Offset(530, 270));
      view.pan(const Offset(-63, 91));
      final physical = view.toScreen(point) * dpr;
      expect(
        (view.toDocument(physical / dpr) - point).distance,
        lessThan(1e-10),
      );
    }
    view.layout(const Size(595, 841), const Size(640, 1200));
    expect(
      (view.toDocument(view.toScreen(point)) - point).distance,
      lessThan(1e-10),
    );
    expect(view.screenBounds.width, lessThanOrEqualTo(640));
    view.dispose();
  });
}
