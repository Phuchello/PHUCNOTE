import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_functional_poc/ink_sheet.dart';

void main() {
  test(
    'Adapter files are byte-identical to audited production geometry/models',
    () {
      for (final path in [
        'core/models/stroke_point.dart',
        'core/models/stroke_property.dart',
        'drawing/stroke_geometry.dart',
      ]) {
        expect(
          File('lib/$path').readAsBytesSync(),
          File('../../lib/$path').readAsBytesSync(),
        );
      }
    },
  );
  test(
    'Ink boundary/cancel and multi-stroke erase preserve exact ordered history',
    () {
      final sheet = InkSheet();
      const bounds = Rect.fromLTWH(0, 0, 595, 841);
      expect(
        sheet.begin(const Offset(-1, 10), bounds, InkTool.pen, .5),
        isFalse,
      );
      for (var i = 0; i < 3; i++) {
        sheet.begin(
          Offset(30, 30 + 40.0 * i),
          bounds,
          i == 1 ? InkTool.highlighter : InkTool.pen,
          .3,
        );
        sheet.move(Offset(150, 30 + 40.0 * i), .8);
        sheet.end();
      }
      final exact = jsonEncode(sheet.strokes.map((s) => s.toJson()).toList());
      sheet.begin(const Offset(90, 20), bounds, InkTool.eraser, .5);
      sheet.move(const Offset(90, 120), .5);
      sheet.end(); // Same safe completion is used on pointer cancellation.
      expect(sheet.strokes, isEmpty);
      for (var cycle = 0; cycle < 3; cycle++) {
        sheet.undo();
        expect(
          jsonEncode(sheet.strokes.map((s) => s.toJson()).toList()),
          exact,
        );
        sheet.redo();
        expect(sheet.strokes, isEmpty);
      }
      sheet.undo();
      sheet.begin(const Offset(590, 830), bounds, InkTool.pen, .5);
      sheet.move(const Offset(620, 900), .7);
      sheet.end();
      expect(sheet.strokes.last.points.last.x, 595);
      expect(sheet.strokes.last.points.last.y, 841);
      expect(sheet.canRedo, isFalse);
      sheet.dispose();
    },
  );
}
