// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/core/storage/note_storage.dart';

void main() {
  late Directory tempDir;
  late NoteStorage storage;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('phucnote_test_');
    storage = NoteStorage(customRootDirectory: tempDir);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('NoteStorage — Data Safety & Atomic Writes', () {
    test('saveNote and loadNote persist and reload real files on disk', () async {
      final doc = NoteDocument(
        title: 'Physics Mechanics',
        paperTemplate: PaperTemplate.grid,
      );
      doc.addStroke(StrokeElement(
        id: 's-1',
        points: const [
          StrokePoint(x: 10, y: 20, pressure: 0.6),
          StrokePoint(x: 15, y: 25, pressure: 0.7),
        ],
        property: const StrokeProperty(colorValue: 0xFF1565C0, strokeWidth: 4.0),
      ));

      final savedFile = await storage.saveNote(doc);
      expect(await savedFile.exists(), isTrue);
      expect(savedFile.path.endsWith('.bfly'), isTrue);

      final loadedDoc = await storage.loadNote(savedFile);
      expect(loadedDoc.title, 'Physics Mechanics');
      expect(loadedDoc.paperTemplate, PaperTemplate.grid);
      expect(loadedDoc.strokes.length, 1);
      expect(loadedDoc.strokes.first.points.length, 2);
      expect(loadedDoc.strokes.first.property.colorValue, 0xFF1565C0);
    });

    test('atomic saving creates .bak file on update without corrupting original file', () async {
      final doc = NoteDocument(title: 'Calculus Notes');
      doc.addStroke(StrokeElement(
        id: 's-initial',
        points: const [StrokePoint(x: 0, y: 0)],
        property: const StrokeProperty(colorValue: 0xFF000000),
      ));

      // First save
      final file = await storage.saveNote(doc);
      expect(await file.exists(), isTrue);

      // Mutate and save again
      doc.addStroke(StrokeElement(
        id: 's-second',
        points: const [StrokePoint(x: 100, y: 100)],
        property: const StrokeProperty(colorValue: 0xFFEF6C00),
      ));
      final updatedFile = await storage.saveNote(doc);
      expect(updatedFile.path, file.path);

      // Verify backup file exists
      final bakFile = File('${file.path}.bak');
      expect(await bakFile.exists(), isTrue);

      // Verify no temporary files linger
      final entities = tempDir.listSync();
      final tmpFiles = entities.where((e) => e.path.contains('.tmp_'));
      expect(tmpFiles, isEmpty);
    });

    test('crash recovery loads from .bak file when primary .bfly is corrupted', () async {
      final doc = NoteDocument(title: 'Crash Recovery Test');
      doc.addStroke(StrokeElement(
        id: 's-safe',
        points: const [StrokePoint(x: 50, y: 50)],
        property: const StrokeProperty(colorValue: 0xFF2E7D32),
      ));

      // Save initial valid version
      final file = await storage.saveNote(doc);

      // Update to create valid .bak file
      doc.addStroke(StrokeElement(
        id: 's-update',
        points: const [StrokePoint(x: 80, y: 80)],
        property: const StrokeProperty(colorValue: 0xFF6A1B9A),
      ));
      await storage.saveNote(doc);

      // Deliberately corrupt the primary file with garbage bytes (simulating disk truncation)
      await file.writeAsString('CORRUPTED_TRUNCATED_NON_ZIP_DATA');

      // Loading should seamlessly fall back to the .bak file
      final recoveredDoc = await storage.loadNote(file);
      expect(recoveredDoc, isNotNull);
      expect(recoveredDoc.title, 'Crash Recovery Test');
      expect(recoveredDoc.strokes.isNotEmpty, isTrue);
    });

    test('listSavedNotes returns notes sorted by last modified descending', () async {
      final doc1 = NoteDocument(title: 'Alpha');
      final file1 = await storage.saveNote(doc1);

      await Future.delayed(const Duration(milliseconds: 50));

      final doc2 = NoteDocument(title: 'Beta');
      final file2 = await storage.saveNote(doc2);

      final list = await storage.listSavedNotes();
      expect(list.length, 2);
      expect(list.first.path, file2.path);
      expect(list.last.path, file1.path);
    });

    test('deleteNote removes both .bfly and its .bak backup', () async {
      final doc = NoteDocument(title: 'To Delete');
      final file = await storage.saveNote(doc);
      await storage.saveNote(doc); // Generates .bak

      final bakFile = File('${file.path}.bak');
      expect(await file.exists(), isTrue);
      expect(await bakFile.exists(), isTrue);

      await storage.deleteNote(file);
      expect(await file.exists(), isFalse);
      expect(await bakFile.exists(), isFalse);
    });
  });
}
