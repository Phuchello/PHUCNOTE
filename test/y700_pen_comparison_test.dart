import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/stroke_path_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Render reproducible before/after samples using the real ink engine',
    () async {
      final fontFile = File(
        '${Platform.environment['WINDIR'] ?? r'C:\Windows'}/Fonts/segoeui.ttf',
      );
      if (await fontFile.exists()) {
        final font = FontLoader('InkValidation')
          ..addFont(
            fontFile.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await font.load();
      }
      final traces = <List<StrokePoint>>[
        [
          for (var i = 0; i <= 160; i++)
            StrokePoint(x: 20 + i * 1.5, y: 38, pressure: 0.05 + 0.9 * i / 160),
        ],
        [
          for (var i = 0; i <= 240; i++)
            StrokePoint(
              x: 20 + i * 1.5 + 11 * math.sin(i * 0.12),
              y: 95 + 18 * math.cos(i * 0.12),
              pressure: 0.5 + 0.4 * math.sin(i * 0.09),
            ),
        ],
        for (var letter = 0; letter < 3; letter++) ...[
          [
            for (var i = 0; i <= 40; i++)
              StrokePoint(
                x: 430 + letter * 55 + 7 * math.cos(i * math.pi / 20),
                y: 96 + 10 * math.sin(i * math.pi / 20),
                pressure: .5,
              ),
          ],
          [
            StrokePoint(x: 420 + letter * 55, y: 77),
            StrokePoint(x: 430 + letter * 55, y: 71),
            StrokePoint(x: 440 + letter * 55, y: 77),
          ],
          [
            StrokePoint(x: 431 + letter * 55, y: 63),
            StrokePoint(x: 435 + letter * 55, y: 59),
          ],
          [StrokePoint(x: 430 + letter * 55, y: 119)],
        ],
      ];
      final directory = Directory('artifacts/y700-gen4-ink');
      await directory.create(recursive: true);
      await File('${directory.path}/pen_trace.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'kind': 'synthetic pressure, loops, accent components; not human handwriting',
          'strokes': traces
              .map((s) => s.map((p) => p.toJson()).toList())
              .toList(),
        }),
      );
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(const Color(0xFFF8F6F0), BlendMode.src);
      void label(String text, double x, double y, {double size = 22}) {
        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'InkValidation',
              color: const Color(0xFF263341),
              fontSize: size,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(canvas, Offset(x, y));
        painter.dispose();
      }

      label('PHUCNOTE · BEFORE / AFTER · SYNTHETIC REPLAY', 28, 20);
      label('Before: uncached geometry', 28, 60, size: 18);
      label('After: cached geometry (appearance preserved)', 780, 60, size: 18);
      final cache = StrokePathCache();
      for (var row = 0; row < PenPreset.defaults.length; row++) {
        final preset = PenPreset.defaults[row];
        for (var column = 0; column < 2; column++) {
          final x = 28.0 + column * 752;
          final y = 106.0 + row * 185;
          label(preset.name, x, y, size: 20);
          canvas.save();
          canvas.translate(x, y + 29);
          for (var i = 0; i < traces.length; i++) {
            final stroke = StrokeElement(
              id: '${row}_$i',
              points: traces[i],
              property: preset.property,
            );
            final before = StrokeGeometry.generatePath(
              stroke.points,
              stroke.property,
            );
            final after = cache.pathFor(stroke);
            expect(after.getBounds(), before.getBounds());
            canvas.drawPath(
              column == 0 ? before : after,
              Paint()..color = preset.property.color,
            );
          }
          canvas.restore();
        }
      }
      label(
        'No physical Y700/AP501U test. Presets and legacy rendering unchanged.',
        28,
        680,
        size: 17,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(1536, 720);
      await File('${directory.path}/pen_before_after.png').writeAsBytes(
        (await image.toByteData(format: ImageByteFormat.png))!.buffer
            .asUint8List(),
      );
      image.dispose();
      picture.dispose();
    },
  );
}
