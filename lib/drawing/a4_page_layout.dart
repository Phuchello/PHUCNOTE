// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:ui';

/// A4 guides and input share these bounds in global document coordinates.
abstract final class A4PageLayout {
  static const double width = 840.0;
  static const double height = 1188.0;
  static const double gap = 24.0;
  static const double stride = height + gap;

  /// One-based pages; top/left edges are included, bottom/right are excluded.
  static Rect pageBounds(int pageIndex) {
    if (pageIndex < 1) throw ArgumentError.value(pageIndex, 'pageIndex');
    return Rect.fromLTWH(0, (pageIndex - 1) * stride, width, height);
  }

  static Rect gapAfterPage(int pageIndex) =>
      Rect.fromLTWH(0, pageBounds(pageIndex).bottom, width, gap);

  /// Returns null above the document or in an inter-page gap.
  static int? pageIndexAtY(double y) {
    if (!y.isFinite || y < 0) return null;
    final pageIndex = (y / stride).floor() + 1;
    return y < pageBounds(pageIndex).bottom ? pageIndex : null;
  }

  /// Returns null outside page width, above the document, or in a gap.
  static int? pageIndexAt(Offset position) {
    if (!position.dx.isFinite || position.dx < 0 || position.dx >= width) {
      return null;
    }
    return pageIndexAtY(position.dy);
  }

  /// Page outlines that intersect the viewport's vertical document range.
  static Iterable<int> visiblePageIndices(Rect viewport) sync* {
    final first = max(1, (viewport.top / stride).floor() + 1);
    final last = max(first, (viewport.bottom / stride).ceil() + 1);
    for (var index = first; index <= last; index++) {
      final bounds = pageBounds(index);
      if (bounds.bottom >= viewport.top && bounds.top <= viewport.bottom) {
        yield index;
      }
    }
  }
}
