import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../core/models/stroke_element.dart';
import '../core/models/stroke_point.dart';
import 'stroke_geometry.dart';

/// View-local, bounded cache. Mutable point lists are checked against a snapshot;
/// identifiers alone cannot prove that a stroke still has the same geometry.
class StrokePathCache {
  final int maxEntries;
  final int maxPoints;
  final _entries = LinkedHashMap<StrokeElement, _CachedStroke>.identity();
  int _pointCount = 0;

  StrokePathCache({this.maxEntries = 128, this.maxPoints = 20000})
    : assert(maxEntries > 0),
      assert(maxPoints > 0);

  Rect boundsFor(StrokeElement stroke) {
    final entry = _entries[stroke];
    return entry != null && listEquals(entry.points, stroke.points)
        ? entry.bounds
        : stroke.boundingBox;
  }

  Path pathFor(StrokeElement stroke) {
    final previous = _entries.remove(stroke);
    if (previous != null) {
      _pointCount -= previous.points.length;
      if (listEquals(previous.points, stroke.points)) {
        _entries[stroke] = previous;
        _pointCount += previous.points.length;
        return previous.path;
      }
    }
    final path = StrokeGeometry.generatePath(stroke.points, stroke.property);
    if (stroke.points.length > maxPoints) return path;
    while (_entries.length >= maxEntries ||
        _pointCount + stroke.points.length > maxPoints) {
      final removed = _entries.remove(_entries.keys.first)!;
      _pointCount -= removed.points.length;
    }
    _entries[stroke] = _CachedStroke(
      List.of(stroke.points),
      stroke.boundingBox,
      path,
    );
    _pointCount += stroke.points.length;
    return path;
  }

  void clear() {
    _entries.clear();
    _pointCount = 0;
  }
}

class _CachedStroke {
  final List<StrokePoint> points;
  final Rect bounds;
  final Path path;

  _CachedStroke(this.points, this.bounds, this.path);
}
