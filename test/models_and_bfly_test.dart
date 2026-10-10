// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';

void main() {
  group('Stroke Models & Geometry', () {
    test('StrokePoint converts to Offset and JSON properly', () {
      final point = StrokePoint(x: 100.5, y: 200.2, pressure: 0.8, tilt: 0.1);
      expect(point.toOffset(), equals(const Offset(100.5, 200.2)));
      expect(point.pressure, equals(0.8));

      final json = point.toJson();
      final decoded = StrokePoint.fromJson(json);
      expect(decoded.x, equals(100.5));
      expect(decoded.y, equals(200.2));
      expect(decoded.pressure, equals(0.8));
    });

    test('StrokeProperty supports highlighter and opacity', () {
      const penProp = StrokeProperty(
        colorValue: 0xFF1565C0,
        strokeWidth: 4.0,
        isHighlighter: false,
      );
      expect(penProp.color.a, equals(1.0));

      const hlProp = StrokeProperty(
        colorValue: 0xFFFFEB3B,
        strokeWidth: 12.0,
        isHighlighter: true,
      );
      expect(hlProp.color.a, closeTo(0.35, 0.01));
    });

    test('StrokeElement calculates bounding box and hitTest', () {
      final stroke = StrokeElement(
        id: 'stroke_1',
        points: [
          const StrokePoint(x: 10, y: 10),
          const StrokePoint(x: 20, y: 20),
          const StrokePoint(x: 30, y: 30),
        ],
        property: const StrokeProperty(colorValue: 0xFF000000, strokeWidth: 4.0),
      );

      expect(stroke.boundingBox.contains(const Offset(20, 20)), isTrue);
      expect(stroke.hitTest(const Offset(20, 20), 5.0), isTrue);
      expect(stroke.hitTest(const Offset(200, 200), 5.0), isFalse);
    });
  });

  group('.bfly Container Serialization & Round-Trip', () {
    test('Encodes and decodes NoteDocument to/from .bfly ZIP container', () {
      final originalDoc = NoteDocument(
        id: 'doc_123',
        title: 'Lecture CS101 Notes',
        paperTemplate: PaperTemplate.grid,
      );

      final stroke1 = StrokeElement(
        id: 'str_1',
        points: [
          const StrokePoint(x: 15.0, y: 25.0, pressure: 0.6),
          const StrokePoint(x: 18.0, y: 28.0, pressure: 0.7),
          const StrokePoint(x: 22.0, y: 35.0, pressure: 0.8),
        ],
        property: const StrokeProperty(
          colorValue: 0xFF1565C0,
          strokeWidth: 3.5,
          thinning: 0.5,
          smoothing: 0.6,
        ),
      );

      final stroke2 = StrokeElement(
        id: 'str_2',
        points: [
          const StrokePoint(x: 50.0, y: 50.0, pressure: 0.5),
          const StrokePoint(x: 100.0, y: 50.0, pressure: 0.5),
        ],
        property: const StrokeProperty(
          colorValue: 0xFFFFEB3B,
          strokeWidth: 14.0,
          isHighlighter: true,
        ),
      );

      originalDoc.addStroke(stroke1);
      originalDoc.addStroke(stroke2);

      // Encode to .bfly ZIP bytes
      final bflyBytes = BflySerializer.encode(originalDoc);
      expect(bflyBytes, isNotEmpty);

      // Decode from .bfly bytes
      final decodedDoc = BflySerializer.decode(bflyBytes);

      expect(decodedDoc.id, equals('doc_123'));
      expect(decodedDoc.title, equals('Lecture CS101 Notes'));
      expect(decodedDoc.paperTemplate, equals(PaperTemplate.grid));
      expect(decodedDoc.strokes.length, equals(2));

      final decodedStroke1 = decodedDoc.strokes[0];
      expect(decodedStroke1.id, equals('str_1'));
      expect(decodedStroke1.points.length, equals(3));
      expect(decodedStroke1.points[0].x, equals(15.0));
      expect(decodedStroke1.property.colorValue, equals(0xFF1565C0));

      final decodedStroke2 = decodedDoc.strokes[1];
      expect(decodedStroke2.id, equals('str_2'));
      expect(decodedStroke2.property.isHighlighter, isTrue);
    });
  });
}
