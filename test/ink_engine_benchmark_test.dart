import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as freehand;
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/stroke_path_cache.dart';

import '../tool/ink_benchmark/benchmark.dart';
import '../tool/ink_benchmark/incremental_geometry.dart';
import '../tool/ink_benchmark/pen_experiments.dart';
import '../tool/ink_benchmark/traces.dart';

Future<List<int>> pixels(Path path, {double zoom = 1}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..scale(zoom);
  canvas.drawPath(path, Paint()..color = const Color(0xFF111111));
  final picture = recorder.endRecording();
  final image = await picture.toImage(600, 180);
  final bytes = (await image.toByteData(format: ImageByteFormat.rawRgba))!
      .buffer
      .asUint8List()
      .toList();
  image.dispose();
  picture.dispose();
  return bytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'All catalog prefixes preserve perfect_freehand preprocessing and bounds',
    () {
      final random = math.Random(7004);
      final cases = [
        for (final t in traceCatalog()) ...t.strokes,
        [
          for (var i = 0; i < 150; i++)
            InkSample(
              StrokePoint(
                x: i % 7 == 0 ? 30 : 30 + random.nextDouble() * 5,
                y: i % 7 == 0 ? 60 : 60 + random.nextDouble() * 5,
                pressure: i < 75 ? .5 : random.nextDouble(),
              ),
              i * 8333,
            ),
        ],
        [
          for (var i = 0; i < 8; i++)
            InkSample(const StrokePoint(x: 30, y: 60), i * 8333),
        ],
      ];
      for (final preset in PenPreset.defaults) {
        for (final trace in cases) {
          final raw = <StrokePoint>[];
          final candidate = IncrementalGeometry(preset.property);
          for (final s in trace) {
            raw.add(s.point);
            candidate.append(s.point);
            final expected = freehand.getStrokePoints(
              [for (final p in raw) p.toFreehandPoint()],
              options: freehand.StrokeOptions(
                size: preset.property.strokeWidth,
                streamline: preset.property.streamline,
              ),
            );
            final actual = candidate.debugPreprocessed();
            expect(actual.length, expected.length);
            for (var i = 0; i < expected.length; i++) {
              expect(actual[i].point, expected[i].point);
              expect(actual[i].pressure, expected[i].pressure);
              expect(actual[i].vector, expected[i].vector);
              expect(actual[i].distance, expected[i].distance);
              expect(actual[i].runningLength, expected[i].runningLength);
            }
            expect(
              candidate.path().getBounds(),
              StrokeGeometry.generatePath(raw, preset.property).getBounds(),
            );
            expect(candidate.retainedSamples, raw.length);
            expect(candidate.path(), same(candidate.path()));
          }
        }
      }
    },
  );

  test('Wet prefixes, completion, transforms and bfly reopen retain identical pixels', () async {
    for (final preset in PenPreset.defaults) {
      final controller = CanvasController()..setPenProperty(preset.property);
      controller.panViewport(const Offset(15, -30));
      controller.zoomAt(Offset.zero, 1.5);
      final candidate = IncrementalGeometry(preset.property);
      final source = curve(count: 128, ramp: true);
      for (var i = 0; i < source.length; i++) {
        final p = source[i].point;
        candidate.append(p);
        final screen = controller.canvasToScreen(p.toOffset());
        if (i == 0) {
          controller.handlePointerDown(
            PointerDownEvent(
              kind: PointerDeviceKind.stylus,
              position: screen,
              pressure: p.pressure.clamp(.1, 1),
              tilt: p.tilt,
            ),
          );
        } else {
          controller.handlePointerMove(
            PointerMoveEvent(
              kind: PointerDeviceKind.stylus,
              position: screen,
              pressure: p.pressure.clamp(.1, 1),
              tilt: p.tilt,
            ),
          );
        }
        if ([1, 2, 3, 31, 63, 127].contains(i)) {
          expect(
            await pixels(candidate.path()),
            await pixels(
              StrokeGeometry.generatePath(
                source.take(i + 1).map((s) => s.point).toList(),
                preset.property,
              ),
            ),
          );
        }
      }
      controller.handlePointerUp(
        PointerUpEvent(
          kind: PointerDeviceKind.stylus,
          position: controller.canvasToScreen(source.last.point.toOffset()),
        ),
      );
      final stroke = controller.document.strokes.single;
      final serialized = BflySerializer.encode(controller.document);
      final reopened = BflySerializer.decode(serialized);
      final reopenedStroke = reopened.strokes.single;
      expect(reopenedStroke.toJson(), stroke.toJson());
      controller.undo();
      expect(controller.document.strokes, isEmpty);
      controller.redo();
      expect(controller.document.strokes.single.toJson(), stroke.toJson());
      expect(
        await pixels(
          StrokeGeometry.generatePath(
            reopenedStroke.points,
            reopenedStroke.property,
          ),
          zoom: 1.5,
        ),
        await pixels(
          StrokeGeometry.generatePath(stroke.points, stroke.property),
          zoom: 1.5,
        ),
      );
      controller.dispose();
    }
  });

  test('Audit reproduces stable-pressure simulation, pressure clamp and unused tilt', () async {
    final property = PenPreset.defaults.last.property;
    final points = curve().map((s) => s.point.copyWith(pressure: .2)).toList();
    final legacy = StrokeGeometry.generatePath(points, property);
    final simulated = outlinePath(
      freehand.getStroke(
        [for (final p in points) p.toFreehandPoint()],
        options: freehand.StrokeOptions(
          size: property.strokeWidth,
          thinning: property.thinning,
          smoothing: property.smoothing,
          streamline: property.streamline,
          simulatePressure: true,
        ),
      ),
      property.strokeWidth,
    );
    expect(await pixels(legacy), await pixels(simulated));
    expect(
      await pixels(legacy),
      isNot(await pixels(experimentalPen(points, property))),
    );
    expect(
      await pixels(legacy),
      await pixels(
        StrokeGeometry.generatePath([
          for (final p in points) p.copyWith(tilt: 1.2),
        ], property),
      ),
    );
    final controller = CanvasController();
    controller.handlePointerDown(
      const PointerDownEvent(
        kind: PointerDeviceKind.stylus,
        pressure: .02,
        pressureMin: 0,
        pressureMax: 2,
        position: Offset(20, 60),
      ),
    );
    expect(controller.activePoints.single.pressure, .1);
    controller.handlePointerMove(
      const PointerMoveEvent(
        kind: PointerDeviceKind.stylus,
        position: Offset(40, 60),
        pressure: .5,
      ),
    );
    controller.handlePointerUp(
      const PointerUpEvent(
        kind: PointerDeviceKind.stylus,
        position: Offset(80, 60),
        pressure: .5,
      ),
    );
    // P0.2 retains the accepted UP location for newly written strokes.
    expect(controller.document.strokes.single.points.last.x, 80);
    controller.dispose();
  });

  test('Dense cache over capacity evicts; no silent geometry/data change', () {
    for (final density in [32, 128, 256]) {
      final cache = StrokePathCache();
      final doc = NoteDocument(
        strokes: [
          for (var i = 0; i < density; i++)
            StrokeElement(
              id: 'density_$i',
              points: curve().map((s) => s.point).toList(),
              property: PenPreset.defaults.first.property,
            ),
        ],
      );
      final first = cache.pathFor(doc.strokes.first);
      for (final s in doc.strokes.skip(1)) {
        cache.pathFor(s);
      }
      final next = cache.pathFor(doc.strokes.first);
      if (density <= 128) {
        expect(next, same(first));
      } else {
        expect(next, isNot(same(first)));
      }
      expect(next.getBounds(), first.getBounds());
      expect(doc.strokes.length, density);
    }
  });

  test('Timestamp and tilt are not geometry dynamics; parameter changes are visible', () async {
    final catalog = traceCatalog();
    final slow = catalog[6].strokes.single.map((s) => s.point).toList();
    final fast = catalog[7].strokes.single.map((s) => s.point).toList();
    final base = PenPreset.defaults.first.property;
    expect(
      await pixels(StrokeGeometry.generatePath(slow, base)),
      await pixels(StrokeGeometry.generatePath(fast, base)),
    );
    // Sparse corners can legitimately produce the same outline at both
    // smoothing values; use dense input to exercise its spacing threshold.
    final corner = polyline([
      const math.Point<double>(20, 30),
      const math.Point<double>(20, 70),
      const math.Point<double>(65, 70),
      const math.Point<double>(65, 30),
    ], steps: 128).map((s) => s.point).toList();
    final original = await pixels(StrokeGeometry.generatePath(corner, base));
    for (final property in [
      base.copyWith(smoothing: 0),
      base.copyWith(streamline: 0),
      base.copyWith(strokeWidth: 6),
    ]) {
      expect(
        await pixels(StrokeGeometry.generatePath(corner, property)),
        isNot(original),
      );
    }
    final metrics = <Map<String, Object>>[];
    for (final preset in PenPreset.defaults) {
      final curvePoints = curve().map((s) => s.point).toList();
      final legacy = StrokeGeometry.generatePath(curvePoints, preset.property);
      final complete = experimentalPen(
        curvePoints,
        preset.property,
        completedTip: true,
      );
      final a = await pixels(legacy);
      final b = await pixels(complete);
      var differences = 0;
      for (var i = 0; i < a.length; i += 4) {
        if (a[i + 3] != b[i + 3]) differences++;
      }
      metrics.add({
        'preset': preset.name,
        'differentAlphaPixels': differences,
        'legacyBounds': legacy.getBounds().toString(),
        'trialBounds': complete.getBounds().toString(),
      });
    }
    File('artifacts/ink-engine/pen_behavior.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'units': '600x180 synthetic raster; not a quality score',
        'stablePressureCompletedTipTrial': metrics,
      }),
    );
  });

  test(
    'Generate reproducible benchmark inputs and visual comparison',
    () async {
      final out = Directory('artifacts/ink-engine')
        ..createSync(recursive: true);
      final fixture = const JsonEncoder.withIndent('  ').convert(catalogJson());
      File('${out.path}/trace_catalog.json').writeAsStringSync(fixture);
      final nativeFixture = File(
        'examples/ink_engine_native_spike/app/src/main/assets/ink_traces.json',
      );
      if (nativeFixture.existsSync()) {
        expect(jsonDecode(nativeFixture.readAsStringSync()), catalogJson());
      }
      if (const bool.fromEnvironment('INK_MEASURE')) {
        File('${out.path}/desktop_geometry.json').writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(geometryBenchmark()),
        );
        File('${out.path}/desktop_density.json').writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(densityBenchmark()),
        );
      }
      final fontFile = File(
        '${Platform.environment['WINDIR'] ?? r'C:\Windows'}/Fonts/segoeui.ttf',
      );
      if (fontFile.existsSync()) {
        await (FontLoader('InkComparison')..addFont(
              fontFile.readAsBytes().then((b) => ByteData.sublistView(b)),
            ))
            .load();
      }
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)
        ..drawColor(const Color(0xFFF9F6EF), BlendMode.src);
      void label(String text, double x, double y, {double size = 20}) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'InkComparison',
              fontSize: size,
              color: const Color(0xFF243746),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(x, y));
        textPainter.dispose();
      }

      label(
        'PHUCNOTE · Controlled ink experiments · synthetic input',
        24,
        20,
        size: 26,
      );
      label('Historical renderer', 24, 65);
      label('A1 incremental: identical geometry', 580, 65);
      label('Session-only pressure / tip / taper trials', 1140, 65);
      for (var row = 0; row < 4; row++) {
        final property = row < 3
            ? PenPreset.defaults[row].property
            : const StrokeProperty(
                colorValue: 0xFFFFD54F,
                strokeWidth: 18,
                thinning: 0,
                smoothing: .55,
                streamline: .4,
                isHighlighter: true,
                opacity: .35,
              );
        final name = row < 3
            ? PenPreset.defaults[row].name
            : 'Highlighter: crossing strokes';
        final y = 110.0 + row * 280;
        for (var col = 0; col < 3; col++) {
          final x = 24.0 + col * 560;
          label(name, x, y);
          canvas.save();
          canvas.translate(x, y + 28);
          final traces = row == 3
              ? [
                  line([20, 55, 250, 55]),
                  line([140, 25, 140, 85]),
                ]
              : [
                  curve()
                      .map(
                        (s) =>
                            InkSample(s.point.copyWith(pressure: .2), s.timeUs),
                      )
                      .toList(),
                  for (final s in traceCatalog()[8].strokes)
                    [
                      for (final p in s)
                        InkSample(
                          p.point.copyWith(y: p.point.y + 55),
                          p.timeUs,
                        ),
                    ],
                  for (final s in traceCatalog()[9].strokes)
                    [
                      for (final p in s)
                        InkSample(
                          p.point.copyWith(y: p.point.y + 130),
                          p.timeUs,
                        ),
                    ],
                ];
          for (final stroke in traces) {
            final raw = stroke.map((s) => s.point).toList();
            final candidate = IncrementalGeometry(property);
            for (final p in raw) {
              candidate.append(p);
            }
            final path = col == 0
                ? StrokeGeometry.generatePath(raw, property)
                : col == 1
                ? candidate.path()
                : experimentalPen(
                    raw,
                    property,
                    pressureGamma: row == 2 ? .7 : 1,
                    taper: row == 2 ? 5 : 0,
                    completedTip: true,
                  );
            final paint = Paint()..color = property.color;
            if (row == 3) {
              paint.blendMode = BlendMode.multiply;
            }
            canvas.drawPath(path, paint);
          }
          canvas.restore();
        }
      }
      label(
        'Pressure plateau, stylized Tiếng Việt and formula accents; no physical stylus claim.',
        24,
        1250,
        size: 19,
      );
      label(
        'A1 keeps old pixels. Right column cannot persist its extra options in the current .bfly schema.',
        24,
        1285,
        size: 19,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(1710, 1335);
      File('PEN_RENDERING_VISUAL_COMPARISON.png').writeAsBytesSync(
        (await image.toByteData(format: ImageByteFormat.png))!.buffer
            .asUint8List(),
      );
      image.dispose();
      picture.dispose();
    },
  );
}
