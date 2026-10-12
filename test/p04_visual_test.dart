import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';

import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import '../tool/ink_benchmark/traces.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate baseline/rejected-candidate PNG from frozen identical traces', () async {
    final traces = [
      ...traceCatalog(),
      InkTrace('vietnamese_tone_marks', 'acute_grave_hook_tilde_dot', [
        line([20, 70, 50, 30]),
        line([80, 30, 110, 70]),
        line([140, 45, 150, 30, 165, 35, 160, 55, 150, 75]),
        line([195, 55, 210, 35, 225, 65, 240, 45]),
        const [InkSample(StrokePoint(x: 280, y: 55), 0)],
      ]),
      InkTrace('vietnamese_diacritic_components', 'breve_circumflex_horn_crossed_d', [
        line([20, 40, 35, 65, 55, 65, 70, 40]),
        line([100, 65, 120, 30, 140, 65]),
        line([175, 30, 190, 35, 190, 55, 175, 70]),
        line([240, 25, 240, 85]),
        line([225, 50, 255, 50]),
      ]),
    ];
    const width = 1980;
    const cellWidth = 330.0;
    const cellHeight = 110.0;
    final height = traces.length * 110;
    const oldProps = [
      StrokeProperty(colorValue: 0xff1e1e1e, strokeWidth: 3, thinning: 0, smoothing: .5, streamline: .35),
      StrokeProperty(colorValue: 0xff1e1e1e, strokeWidth: 4.5, thinning: .2, smoothing: .7, streamline: .55),
      StrokeProperty(colorValue: 0xff1e1e1e, strokeWidth: 5, thinning: .8, smoothing: .55, streamline: .4),
    ];
    // Experimental values are frozen only as evidence; NOT production defaults.
    const experimentalProps = [
      StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 2.8, thinning: 0, smoothing: .35, streamline: .20),
      StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 3.8, thinning: .15, smoothing: .50, streamline: .35),
      StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 4.8, thinning: .60, smoothing: .45, streamline: .30),
    ];
    final columns = [
      oldProps[0], experimentalProps[0],
      oldProps[1], experimentalProps[1],
      oldProps[2], experimentalProps[2],
    ];
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    canvas.drawColor(const Color(0xffffffff), BlendMode.src);
    for (int row = 0; row < traces.length; row++) {
      for (int col = 0; col < columns.length; col++) {
        canvas.save();
        canvas.translate(col * cellWidth, row * cellHeight);
        canvas.clipRect(const Rect.fromLTWH(0, 0, cellWidth, cellHeight));
        for (final samples in traces[row].strokes) {
          final path = StrokeGeometry.generatePath(samples.map((s) => s.point).toList(), columns[col]);
          final b = path.getBounds();
          expect(b.left.isFinite && b.top.isFinite && b.right.isFinite && b.bottom.isFinite, isTrue);
          expect(b.width, greaterThan(0));
          expect(b.height, greaterThan(0));
          canvas.drawPath(path, Paint()..color = columns[col].color);
        }
        canvas.restore();
      }
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    Directory('artifacts/p0').createSync(recursive: true);
    File('artifacts/p0/pen_before_after.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
    final traceJson = traces.map((t) => t.toJson()).toList();
    File('artifacts/p0/pen_traces.json').writeAsStringSync(jsonEncode(traceJson));
  });
}
