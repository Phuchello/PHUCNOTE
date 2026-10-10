// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';

void main() {
  group('Linwood Butterfly v2.6.0 Interoperability & Schema Validation', () {
    test('successfully imports upstream legacy fixture document_v1.bfly', () async {
      final file = File('test/fixtures/document_v1.bfly');
      expect(file.existsSync(), isTrue, reason: 'Upstream fixture document_v1.bfly must exist');

      final bytes = await file.readAsBytes();
      final doc = BflySerializer.decode(bytes);

      expect(doc, isNotNull);
      expect(doc.title, '25/10/2023 18:56');
      expect(doc.paperTemplate, PaperTemplate.grid); // Derived from box background
      expect(doc.strokes, isNotEmpty);
      expect(doc.strokes.first.points.length, greaterThan(100));

      // Check first stroke coordinate fidelity
      final firstPoint = doc.strokes.first.points.first;
      expect(firstPoint.x, 683.0);
      expect(firstPoint.y, 193.0);
      expect(firstPoint.pressure, 0.0);
    });

    test('successfully imports upstream multi-page fixture study.tbfly', () async {
      final file = File('test/fixtures/study.tbfly');
      expect(file.existsSync(), isTrue, reason: 'Upstream fixture study.tbfly must exist');

      final bytes = await file.readAsBytes();
      final doc = BflySerializer.decode(bytes);

      expect(doc, isNotNull);
      expect(doc.title, 'Study');
      // study.tbfly contains four pages with dozens of pen strokes
      expect(doc.strokes.length, greaterThan(10));

      for (final stroke in doc.strokes) {
        expect(stroke.points, isNotEmpty);
        expect(stroke.property.strokeWidth, greaterThan(0));
      }
    });

    test('round-trip export and import generates authentic Butterfly v2.6.0 ZIP archive structure', () {
      final original = NoteDocument(
        title: 'Quantum Field Theory',
        paperTemplate: PaperTemplate.ruled,
      );

      final encodedBytes = BflySerializer.encode(original);
      expect(encodedBytes[0], 0x50, reason: 'Must start with PK zip signature');

      // Unpack ZIP archive to verify exact Butterfly file hierarchy
      final archive = ZipDecoder().decodeBytes(encodedBytes);

      expect(archive.findFile('META-INF/butterfly.json'), isNotNull);
      expect(archive.findFile('META-INF/phucnote.json'), isNotNull);
      expect(archive.findFile('BFLY/info.json'), isNotNull);
      expect(archive.findFile('BFLY/pages/0.Main.json'), isNotNull);

      // Decode back
      final decoded = BflySerializer.decode(encodedBytes);
      expect(decoded.title, 'Quantum Field Theory');
      expect(decoded.paperTemplate, PaperTemplate.ruled);
    });
  });
}
