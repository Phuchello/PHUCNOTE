import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/stroke_path_cache.dart';

import '../integration_test/support/y700_trace.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Committed paths reused; mutable points invalidate bounds and geometry',
    () {
      final cache = StrokePathCache();
      final stroke = denseDocument().strokes.first;
      final path = cache.pathFor(stroke);
      expect(cache.pathFor(stroke), same(path));
      stroke.points[0] = const StrokePoint(x: -100, y: -100, pressure: 0.1);
      expect(cache.boundsFor(stroke).left, lessThan(0));
      expect(cache.pathFor(stroke), isNot(same(path)));
      expect(
        cache.pathFor(stroke).getBounds(),
        StrokeGeometry.generatePath(stroke.points, stroke.property).getBounds(),
      );
    },
  );
  test('Identity, capacity, point budget and clearing prevent stale/unbounded entries', () {
    final cache = StrokePathCache(maxEntries: 2, maxPoints: 300);
    final document = denseDocument();
    final a = document.strokes[0];
    final b = document.strokes[1];
    final c = document.strokes[2];
    final old = cache.pathFor(a);
    cache.pathFor(b);
    cache.pathFor(c);
    expect(cache.pathFor(a), isNot(same(old)));
    final replacement = StrokeElement(
      id: a.id,
      points: a.points,
      property: PenPreset.defaults.last.property,
    );
    expect(
      cache.pathFor(replacement).getBounds(),
      StrokeGeometry.generatePath(
        replacement.points,
        replacement.property,
      ).getBounds(),
    );
    final fresh = cache.pathFor(a);
    cache.clear();
    expect(cache.pathFor(a), isNot(same(fresh)));
    final tiny = StrokePathCache(maxPoints: 1);
    expect(tiny.pathFor(a), isNot(same(tiny.pathFor(a))));
  });
  test('Cached and uncached ink has identical pixels, including reopen and all pens', () async {
    Future<List<int>> pixels(StrokeElement stroke, Path path) async {
      final recorder = PictureRecorder();
      Canvas(recorder).drawPath(path, Paint()..color = stroke.property.color);
      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 180);
      final bytes = (await image.toByteData(format: ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List()
          .toList();
      image.dispose();
      picture.dispose();
      return bytes;
    }

    final document = denseDocument();
    final reopened = BflySerializer.decode(BflySerializer.encode(document));
    final cache = StrokePathCache();
    for (var i = 0; i < 3; i++) {
      final stroke = document.strokes[i];
      final expected = await pixels(
        stroke,
        StrokeGeometry.generatePath(stroke.points, stroke.property),
      );
      expect(await pixels(stroke, cache.pathFor(stroke)), expected);
      final loaded = reopened.strokes[i];
      expect(await pixels(loaded, cache.pathFor(loaded)), expected);
    }
  });
}
