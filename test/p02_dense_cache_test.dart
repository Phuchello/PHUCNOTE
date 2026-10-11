import '../tool/ink_benchmark/p02_candidate_cache.dart';

import 'dart:ui';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/stroke_path_cache.dart';

import '../tool/ink_benchmark/p02_cache_painter.dart';

import '../tool/ink_benchmark/traces.dart';
import '../tool/ink_benchmark/p02_baseline_cache.dart';

NoteDocument densePage(int count, {int length = 128}) => NoteDocument(
  strokes: [
    for (var i = 0; i < count; i++)
      StrokeElement(
        id: 'p02_$i',
        points: curve(count: length).map((p) => p.point).toList(),
        property: PenPreset.defaults[i % 3].property,
      ),
  ],
);

void paintPage(
  NoteDocument doc,
  StrokePathCache cache, {
  Offset offset = Offset.zero,
  double zoom = 1,
}) {
  final recorder = PictureRecorder();
  P02CachePainter(
    document: doc,
    backgroundColor: const Color(0xffffffff),
    repaintCounter: 1,
    viewportOffset: offset,
    zoomScale: zoom,
    strokeCache: cache,
  ).paint(Canvas(recorder), const Size(1200, 800));
  recorder.endRecording().dispose();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('CACHE-03/04 visible cached working set survives sequential over-capacity paint', () {
    for (final density in [256, 512]) {
      final doc = densePage(density);
      final cache = P02CandidateCache();
      final first = cache.pathFor(doc.strokes.first);
      for (final s in doc.strokes.take(128).skip(1)) {
        cache.pathFor(s);
      }
      for (var frame = 0; frame < 3; frame++) {
        paintPage(
          doc,
          cache,
          offset: Offset(frame.isEven ? 2 : -2, 0),
          zoom: frame == 2 ? 1.1 : 1,
        );
      }
      expect(
        cache.pathFor(doc.strokes.first),
        same(first),
        reason:
            'Visible cached ink should not be cyclically evicted at density $density',
      );
    }
  });
  test('CACHE-01/02/07 bounded admission across density, long strokes and viewport changes', () {
    for (final count in [32, 128, 256, 512]) {
      for (final length in [32, 128, 512]) {
        final doc = densePage(count, length: length);
        final cache = P02CandidateCache();
        for (var frame = 0; frame < 4; frame++) {
          paintPage(
            doc,
            cache,
            offset: Offset(frame == 2 ? -500 : 0, 0),
            zoom: frame == 3 ? .8 : 1,
          );
          expect(cache.entryCount, lessThanOrEqualTo(128));
          expect(cache.retainedPointCount, lessThanOrEqualTo(20000));
        }
        if (count * length <= 20000 && count <= 128) {
          expect(cache.hits, greaterThan(0));
        }
      }
    }
    final cache = P02CandidateCache(maxPoints: 64);
    final long = densePage(1, length: 4096).strokes.single;
    final a = cache.pathFor(long);
    expect(cache.pathFor(long).getBounds(), a.getBounds());
    expect(cache.entryCount, 0);
    expect(cache.retainedPointCount, 0);
    expect(cache.bypasses, 2);
  });
  test('CACHE-05/06 mutations, undo/redo and document clearing cannot reuse stale paths', () {
    final c = CanvasController(document: densePage(256));
    addTearDown(c.dispose);
    final cache = P02CandidateCache();
    paintPage(c.document, cache);
    final stroke = c.document.strokes.last;
    final original = cache.pathFor(stroke);
    stroke.points[0] = const StrokePoint(x: -100, y: -100);
    paintPage(c.document, cache);
    expect(cache.pathFor(stroke), isNot(same(original)));
    expect(
      cache.pathFor(stroke).getBounds(),
      StrokeGeometry.generatePath(stroke.points, stroke.property).getBounds(),
    );
    final ids = c.document.strokes.map((s) => s.id).toList();
    c.clearCanvas();
    c.undo();
    paintPage(c.document, cache);
    expect(c.document.strokes.map((s) => s.id), ids);
    c.redo();
    expect(c.document.strokes, isEmpty);
    final next = densePage(256);
    c.setDocument(next);
    cache.clear();
    expect(cache.entryCount, 0);
    expect(cache.retainedPointCount, 0);
    paintPage(c.document, cache);
    expect(cache.pathFor(next.strokes.last), isNot(same(original)));
  });
  test('CACHE-08 all four pens, accents, formulas and dense ink retain exact pixels and bfly coordinates', () async {
    var strokeSerial = 0;
    final doc = NoteDocument(
      strokes: [
        for (var row = 0; row < 4; row++)
          for (var pattern = 0; pattern < traceCatalog().length; pattern++)
            for (final trace in traceCatalog()[pattern].strokes)
              StrokeElement(
                id: '$row/$pattern/${strokeSerial++}',
                points: [
                  for (final sample in trace)
                    sample.point.copyWith(
                      x: sample.point.x * .45 + (pattern % 5) * 220 + 12,
                      y: sample.point.y * .45 + row * 185 + (pattern ~/ 5) * 48,
                    ),
                ],
                property: row < 3
                    ? PenPreset.defaults[row].property.copyWith(opacity: .73)
                    : PenPreset.defaults.first.property.copyWith(
                        isHighlighter: true,
                        strokeWidth: 13,
                        thinning: 0,
                      ),
              ),
      ],
    );
    Future<List<int>> render(
      NoteDocument document,
      StrokePathCache cache,
      String? name,
    ) async {
      final recorder = PictureRecorder();
      P02CachePainter(
        document: document,
        backgroundColor: const Color(0xfffafafa),
        repaintCounter: 1,
        strokeCache: cache,
      ).paint(Canvas(recorder), const Size(1200, 800));
      final picture = recorder.endRecording();
      final image = await picture.toImage(1200, 800);
      if (name != null) {
        await Directory('artifacts/p02-ink-hardening').create(recursive: true);
        await File('artifacts/p02-ink-hardening/$name.png').writeAsBytes(
          (await image.toByteData(format: ImageByteFormat.png))!.buffer
              .asUint8List(),
        );
      }
      final bytes = (await image.toByteData(format: ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List()
          .toList();
      image.dispose();
      picture.dispose();
      return bytes;
    }

    final cache = P02CandidateCache();
    final baseline = await render(doc, P02BaselineCache(), 'cache-before');
    expect(await render(doc, cache, 'cache-after'), baseline);
    expect(await render(doc, cache, null), baseline);
    final reopened = BflySerializer.decode(BflySerializer.encode(doc));
    expect(
      reopened.strokes.map((s) => s.toJson()),
      doc.strokes.map((s) => s.toJson()),
    );
    cache.clear();
    expect(await render(reopened, cache, null), baseline);
    final paragraphs = NoteDocument(
      strokes: [
        for (var row = 0; row < 4; row++)
          for (var line = 0; line < 3; line++)
            for (var word = 0; word < 6; word++)
              for (final trace in traceCatalog()[8].strokes)
                StrokeElement(
                  id: 'paragraph_${strokeSerial++}',
                  points: [
                    for (final sample in trace)
                      sample.point.copyWith(
                        x: sample.point.x * .45 + word * 180 + 12,
                        y: sample.point.y * .45 + row * 185 + line * 48,
                      ),
                  ],
                  property: row < 3
                      ? PenPreset.defaults[row].property
                      : PenPreset.defaults.first.property.copyWith(
                          isHighlighter: true,
                          strokeWidth: 13,
                          thinning: 0,
                        ),
                ),
      ],
    );
    final paragraphPixels = await render(
      paragraphs,
      P02BaselineCache(),
      'paragraph-before',
    );
    cache.clear();
    expect(await render(paragraphs, cache, 'paragraph-after'), paragraphPixels);
  });
}
