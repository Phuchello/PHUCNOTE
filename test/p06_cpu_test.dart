import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/stroke_path_cache.dart';
import 'package:phucnote/drawing/view_painter.dart';
import '../tool/ink_benchmark/benchmark.dart';
import '../tool/ink_benchmark/traces.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('P06 accepted production CPU baseline benchmarks', () async {
    final pens = PenPreset.defaults;
    final geoResults = <Map<String, dynamic>>[];
    for (final pen in pens) {
      for (final len in [128, 512, 2048, 4096, 8192]) {
        for (var r = 0; r < 3; r++) {
          final pts = curve(count: len, ramp: true).map((s) => s.point).toList();
          final times = <double>[];
          Path? lastPath;
          for (var f = 0; f < 24; f++) {
            final n = len * (f + 1) ~/ 24;
            final sw = Stopwatch()..start();
            lastPath = StrokeGeometry.generatePath(pts.take(n).toList(), pen.property);
            sw.stop();
            times.add(sw.elapsedMicroseconds / 1000.0);
          }
          final bounds = lastPath!.getBounds();
          expect(bounds.left.isFinite && bounds.top.isFinite && bounds.right.isFinite && bounds.bottom.isFinite && !bounds.isEmpty, isTrue);
          geoResults.add({'pen': pen.name, 'length': len, 'repeat': r, 'raw_ms': times, 'distribution': distribution(times)});
        }
      }
    }
    final densityResults = <Map<String, dynamic>>[];
    final basePts = curve(count: 128, ramp: true).map((s) => s.point).toList();
    for (final pen in pens) {
      for (final d in [32, 128, 256, 512]) {
        final doc = NoteDocument(strokes: List.generate(d, (i) => StrokeElement(id: 'cpu_$i', points: basePts, property: pen.property)));
        for (var r = 0; r < 3; r++) {
          for (final cached in r.isOdd ? [false, true] : [true, false]) {
            final cache = StrokePathCache();
            void paintFrame(int f) {
              final rec = PictureRecorder();
              PhucNoteViewPainter(document: doc, backgroundColor: const Color(0xffffffff), repaintCounter: f, strokeCache: cached ? cache : null, viewportOffset: Offset(f.isEven ? 2 : -2, 0), zoomScale: f % 3 == 0 ? 1.05 : 1).paint(Canvas(rec), const Size(1200, 800));
              rec.endRecording().dispose();
            }
            for (var w = 0; w < 4; w++) { paintFrame(w); }
            final times = <double>[];
            for (var f = 0; f < 24; f++) {
              final sw = Stopwatch()..start();
              paintFrame(f);
              sw.stop();
              times.add(sw.elapsedMicroseconds / 1000.0);
            }
            densityResults.add({'pen': pen.name, 'density': d, 'cached': cached, 'repeat': r, 'raw_ms': times, 'distribution': distribution(times)});
          }
        }
      }
    }
    expect(geoResults.length, 45);
    expect(densityResults.length, 72);
    File('artifacts/p0/cpu_baseline.json')..createSync(recursive: true)..writeAsStringSync(jsonEncode({'metadata': {'scope': 'CPU', 'description': 'CPU baseline, not display/pen latency or native bytes'}, 'geometry': geoResults, 'density': densityResults}));
  }, skip: !const bool.fromEnvironment('P06_MEASURE'), timeout: const Timeout(Duration(minutes: 3)));
}
