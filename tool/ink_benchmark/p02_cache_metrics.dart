import 'dart:ui';

import 'package:phucnote/drawing/stroke_path_cache.dart';

abstract class P02MeasuredCache extends StrokePathCache {
  P02MeasuredCache({super.maxEntries, super.maxPoints});
  int hits = 0;
  int misses = 0;
  int evictions = 0;
  int bypasses = 0;
  int get entryCount;
  int get retainedPointCount;
  void beginFrame(Rect visibleRect, {int? documentStrokeCount});
}
