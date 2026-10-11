// Frozen a02a78e cache algorithm for matched P0.2 measurements; no production use.
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';

import 'p02_cache_metrics.dart';

class P02BaselineCache extends P02MeasuredCache {
  final _entries = LinkedHashMap<StrokeElement, _Entry>.identity();
  int _points = 0;
  P02BaselineCache({super.maxEntries, super.maxPoints});
  @override
  int get entryCount => _entries.length;
  @override
  int get retainedPointCount => _points;
  @override
  void beginFrame(Rect visibleRect, {int? documentStrokeCount}) {}
  @override
  Rect boundsFor(StrokeElement stroke) {
    final entry = _entries[stroke];
    return entry != null && listEquals(entry.points, stroke.points)
        ? entry.bounds
        : stroke.boundingBox;
  }

  @override
  Path pathFor(StrokeElement stroke) {
    final previous = _entries.remove(stroke);
    if (previous != null) {
      _points -= previous.points.length;
      if (listEquals(previous.points, stroke.points)) {
        hits++;
        _entries[stroke] = previous;
        _points += previous.points.length;
        return previous.path;
      }
    }
    misses++;
    final path = StrokeGeometry.generatePath(stroke.points, stroke.property);
    if (stroke.points.length > maxPoints) {
      bypasses++;
      return path;
    }
    while (_entries.length >= maxEntries ||
        _points + stroke.points.length > maxPoints) {
      final removed = _entries.remove(_entries.keys.first)!;
      _points -= removed.points.length;
      evictions++;
    }
    _entries[stroke] = _Entry(List.of(stroke.points), stroke.boundingBox, path);
    _points += stroke.points.length;
    return path;
  }

  @override
  void clear() {
    _entries.clear();
    _points = 0;
  }
}

class _Entry {
  final List<StrokePoint> points;
  final Rect bounds;
  final Path path;
  _Entry(this.points, this.bounds, this.path);
}
