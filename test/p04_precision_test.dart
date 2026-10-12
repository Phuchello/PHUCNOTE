import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/drawing/canvas_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reject regressing experimental defaults', () {
    const accepted = [
      StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 3, thinning: 0, smoothing: .5, streamline: .35),
      StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 4.5, thinning: .2, smoothing: .7, streamline: .55),
      StrokeProperty(colorValue: 0xFF1E1E1E, strokeWidth: 5, thinning: .8, smoothing: .55, streamline: .4),
    ];
    for (var i = 0; i < 3; i++) {
      expect(PenPreset.defaults[i].property.toJson(), accepted[i].toJson());
    }
  });

  test('new controller uses Ballpoint default', () {
    final c = CanvasController();
    addTearDown(c.dispose);
    expect(c.penProperty.toJson(), PenPreset.defaults.first.property.toJson());
  });

  test('accepted Ballpoint dot retains exact baseline diameter', () {
    final path = StrokeGeometry.generatePath([StrokePoint(x: 10, y: 10)], PenPreset.defaults.first.property);
    final width = path.getBounds().width;
    expect(width, 3.0);
  });
}
