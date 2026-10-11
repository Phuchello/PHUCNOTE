import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';

import '../tool/ink_benchmark/benchmark.dart';
import '../tool/ink_benchmark/incremental_geometry.dart';
import '../tool/ink_benchmark/traces.dart';

List<InkSample> plateau(int count) => [
  for (final s in curve(count: count))
    InkSample(s.point.copyWith(pressure: .2), s.timeUs),
];

Future<List<int>> raster(Path path, int width) async {
  final recorder = PictureRecorder();
  Canvas(recorder).drawPath(path, Paint()..color = const Color(0xff222222));
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, 180);
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
  test('WET-01..07 full-width pixels, late pressure, accents and completed input equal fallback', () async {
    final properties = [
      ...PenPreset.defaults.map((p) => p.property),
      PenPreset.defaults.first.property.copyWith(
        isHighlighter: true,
        thinning: 0,
        strokeWidth: 13,
      ),
    ];
    for (final property in properties) {
      final sources = <List<StrokePoint>>[
        for (final n in [128, 512, 2048, 4096])
          curve(count: n, ramp: true).map((s) => s.point).toList(),
        plateau(4096).map((s) => s.point).toList(),
        [
          for (var i = 0; i < 512; i++)
            curve(count: 512)[i].point.copyWith(pressure: i < 500 ? .2 : .8),
        ],
        for (final trace in traceCatalog()[8].strokes)
          trace.map((s) => s.point).toList(),
      ];
      for (final source in sources) {
        final candidate = IncrementalGeometry(property);
        final raw = <StrokePoint>[];
        for (var i = 0; i < source.length; i++) {
          raw.add(source[i]);
          candidate.append(source[i]);
          if ([0, 1, 2, 127, 511, 2047, 4095, source.length - 1].contains(i)) {
            final fallback = StrokeGeometry.generatePath(raw, property);
            final path = candidate.path();
            expect(path.getBounds(), fallback.getBounds());
            final width = math.max(600, fallback.getBounds().right.ceil() + 32);
            expect(await raster(path, width), await raster(fallback, width));
            expect(candidate.retainedSamples, raw.length);
            expect(
              raw.map((p) => p.toJson()),
              source.take(i + 1).map((p) => p.toJson()),
            );
          }
        }
      }
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
  test(
    'P02 three matched A1 geometry repetitions ramp and plateau',
    () async {
      final data = {
        'ramp': geometryBenchmark(repetitions: 3),
        'plateau': geometryBenchmark(repetitions: 3, traceFactory: plateau),
      };
      final directory = Directory('artifacts/p02-ink-hardening')
        ..createSync(recursive: true);
      await File('${directory.path}/wet-desktop.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      for (final workload in data.values) {
        expect(workload['runs'], hasLength(12));
      }
    },
    skip: !const bool.fromEnvironment('P02_MEASURE'),
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
