import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';

import 'p02_cache_metrics.dart';

/// View-local, bounded cache. Mutable point lists are checked against a snapshot;
/// identifiers alone cannot prove that a stroke still has the same geometry.
class P02CandidateCache extends P02MeasuredCache {
  final _entries = LinkedHashMap<StrokeElement, _CachedStroke>.identity();
  final _visibleEntries = HashSet<StrokeElement>.identity();
  int _pointCount = 0;

  @override
  int get entryCount => _entries.length;
  @override
  int get retainedPointCount => _pointCount;

  /// Protect already cached visible ink for this synchronous paint. Misses may
  /// use remaining/offscreen capacity, but cannot evict the visible working set.
  /// Over-capacity pages still draw every stroke, generating uncached misses.
  @override
  void beginFrame(Rect visibleRect, {int? documentStrokeCount}) {
    _visibleEntries.clear();
    // No cyclic eviction is possible when the whole document already fits.
    // Avoid a third point-snapshot scan on ordinary small pages.
    if (_entries.length == documentStrokeCount) return;
    for (final entry in _entries.entries) {
      if (listEquals(entry.value.points, entry.key.points) &&
          visibleRect.overlaps(entry.value.bounds)) {
        _visibleEntries.add(entry.key);
      }
    }
  }

  P02CandidateCache({super.maxEntries, super.maxPoints});

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
      _pointCount -= previous.points.length;
      if (listEquals(previous.points, stroke.points)) {
        hits++;
        _entries[stroke] = previous;
        _pointCount += previous.points.length;
        return previous.path;
      }
      _visibleEntries.remove(stroke);
    }
    misses++;
    final path = StrokeGeometry.generatePath(stroke.points, stroke.property);
    if (stroke.points.length > maxPoints) {
      bypasses++;
      return path;
    }
    while (_entries.length >= maxEntries ||
        _pointCount + stroke.points.length > maxPoints) {
      if (_visibleEntries.length == _entries.length) {
        bypasses++;
        return path;
      }
      final victim = _entries.keys.firstWhere(
        (key) => !_visibleEntries.contains(key),
      );
      final removed = _entries.remove(victim)!;
      evictions++;
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

  @override
  void clear() {
    _entries.clear();
    _visibleEntries.clear();
    _pointCount = 0;
  }
}

class _CachedStroke {
  final List<StrokePoint> points;
  final Rect bounds;
  final Path path;

  _CachedStroke(this.points, this.bounds, this.path);
}
