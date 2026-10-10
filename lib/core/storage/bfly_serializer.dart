// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/note_document.dart';
import '../models/stroke_element.dart';

/// Serializer for the Linwood Butterfly compatible `.bfly` ZIP container format.
class BflySerializer {
  static const String metaButterflyFile = 'META-INF/butterfly.json';
  static const String metaPhucNoteFile = 'META-INF/phucnote.json';
  static const String infoFile = 'BFLY/info.json';
  static const String pageZeroFile = 'BFLY/pages/page_0.json';

  /// Serializes a [NoteDocument] into `.bfly` ZIP container bytes.
  static Uint8List encode(NoteDocument document) {
    final archive = Archive();

    // 1. META-INF/butterfly.json & META-INF/phucnote.json
    final metaJson = jsonEncode({
      'version': '2.6.0',
      'generator': 'PHUCNOTE',
      'type': 'document',
      'timestamp': DateTime.now().toIso8601String(),
    });
    final metaBytes = utf8.encode(metaJson);
    archive.addFile(ArchiveFile.bytes(metaButterflyFile, metaBytes));
    archive.addFile(ArchiveFile.bytes(metaPhucNoteFile, metaBytes));

    // 2. BFLY/info.json
    final infoJson = jsonEncode({
      'id': document.id,
      'title': document.title,
      'version': document.version,
      'createdAt': document.createdAt.toIso8601String(),
      'updatedAt': document.updatedAt.toIso8601String(),
      'paperTemplate': document.paperTemplate.name,
    });
    archive.addFile(ArchiveFile.bytes(infoFile, utf8.encode(infoJson)));

    // 3. BFLY/pages/page_0.json
    final pageJson = jsonEncode({
      'id': 'page_0',
      'title': 'Page 1',
      'elements': document.strokes.map((s) => s.toJson()).toList(),
    });
    archive.addFile(ArchiveFile.bytes(pageZeroFile, utf8.encode(pageJson)));

    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData);
  }

  /// Deserializes `.bfly` ZIP container bytes into a [NoteDocument].
  static NoteDocument decode(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);

      // Read info
      Map<String, dynamic> infoMap = {};
      final infoArchiveFile = archive.findFile(infoFile);
      if (infoArchiveFile != null) {
        final content = utf8.decode(infoArchiveFile.content as List<int>);
        infoMap = jsonDecode(content) as Map<String, dynamic>;
      }

      // Read strokes from page_0 or all page files
      final List<StrokeElement> strokes = [];
      final pageArchiveFile = archive.findFile(pageZeroFile);
      if (pageArchiveFile != null) {
        final content = utf8.decode(pageArchiveFile.content as List<int>);
        final pageMap = jsonDecode(content) as Map<String, dynamic>;
        final elements = pageMap['elements'] as List<dynamic>? ?? [];
        for (final el in elements) {
          try {
            strokes.add(StrokeElement.fromJson(el as Map<String, dynamic>));
          } catch (_) {
            // Skip unrecognized elements gracefully
          }
        }
      } else {
        // Fallback: search any page file in BFLY/pages/
        for (final file in archive) {
          if (file.name.startsWith('BFLY/pages/') && file.name.endsWith('.json')) {
            final content = utf8.decode(file.content as List<int>);
            final pageMap = jsonDecode(content) as Map<String, dynamic>;
            final elements = pageMap['elements'] as List<dynamic>? ?? [];
            for (final el in elements) {
              try {
                strokes.add(StrokeElement.fromJson(el as Map<String, dynamic>));
              } catch (_) {
                // Ignore corrupt single element
              }
            }
          }
        }
      }

      final template = PaperTemplate.values.firstWhere(
        (t) => t.name == (infoMap['paperTemplate'] as String?),
        orElse: () => PaperTemplate.ruled,
      );

      return NoteDocument(
        id: infoMap['id'] as String?,
        title: infoMap['title'] as String? ?? 'Imported Note',
        createdAt: infoMap['createdAt'] != null
            ? DateTime.tryParse(infoMap['createdAt'] as String)
            : null,
        updatedAt: infoMap['updatedAt'] != null
            ? DateTime.tryParse(infoMap['updatedAt'] as String)
            : null,
        version: infoMap['version'] as String? ?? '1.0.0',
        paperTemplate: template,
        strokes: strokes,
      );
    } catch (e) {
      // Fallback: If not a valid zip, try parsing raw JSON directly
      try {
        final jsonStr = utf8.decode(bytes);
        final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        return NoteDocument.fromJson(jsonMap);
      } catch (_) {
        throw FormatException('Unable to parse document as .bfly or JSON: $e');
      }
    }
  }
}
