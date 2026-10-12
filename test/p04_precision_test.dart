import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/canvas_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new controller uses Ballpoint default', () {
    final c = CanvasController();
    addTearDown(c.dispose);
    expect(c.penProperty.toJson(), PenPreset.defaults.first.property.toJson());
  });

  test('fine dot', () {
    final path = StrokeGeometry.generatePath([StrokePoint(x: 10, y: 10)], PenPreset.defaults.first.property);
    final width = path.getBounds().width;
    expect(width, greaterThan(2.0));
    expect(width, lessThanOrEqualTo(2.8));
  });
}
