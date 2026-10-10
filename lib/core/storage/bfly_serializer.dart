// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/note_document.dart';
import '../models/stroke_element.dart';

/// Serializer for the Linwood Butterfly compatible `.bfly` ZIP container
/// and `.tbfly` / legacy JSON document formats.
class BflySerializer {
  static const int kZipSignature = 0x50; // 'P' in 'PK'
  static const String metaButterflyFile = 'META-INF/butterfly.json';
  static const String metaPhucNoteFile = 'META-INF/phucnote.json';
  static const String infoFile = 'BFLY/info.json';
  static const String defaultPageFile = 'BFLY/pages/0.Main.json';
  static const String legacyPageFile = 'BFLY/pages/page_0.json';

  /// Serializes a [NoteDocument] into a Linwood Butterfly compatible `.bfly` ZIP archive.
  static Uint8List encode(NoteDocument document) {
    final archive = Archive();

    // 1. META-INF/butterfly.json & META-INF/phucnote.json
    final metaButterflyJson = jsonEncode({
      'version': '2.6.0',
      'generator': 'PHUCNOTE',
      'type': 'document',
      'name': document.title,
      'fileVersion': 13,
      'createdAt': document.createdAt.toIso8601String(),
      'updatedAt': document.updatedAt.toIso8601String(),
    });
    archive.addFile(ArchiveFile.bytes(metaButterflyFile, utf8.encode(metaButterflyJson)));

    final metaPhucNoteJson = jsonEncode({
      'version': '1.0.0',
      'generator': 'PHUCNOTE',
      'id': document.id,
      'title': document.title,
      'paperTemplate': document.paperTemplate.name,
      'updatedAt': document.updatedAt.toIso8601String(),
    });
    archive.addFile(ArchiveFile.bytes(metaPhucNoteFile, utf8.encode(metaPhucNoteJson)));

    // 2. BFLY/info.json
    final infoJson = jsonEncode({
      'id': document.id,
      'title': document.title,
      'name': document.title,
      'version': document.version,
      'createdAt': document.createdAt.toIso8601String(),
      'updatedAt': document.updatedAt.toIso8601String(),
      'paperTemplate': document.paperTemplate.name,
    });
    archive.addFile(ArchiveFile.bytes(infoFile, utf8.encode(infoJson)));

    // 3. BFLY/pages/0.Main.json
    final strokeJsonList = document.strokes.map((s) => s.toJson()).toList();
    final pageJson = jsonEncode({
      'id': 'page_0',
      'name': 'Main',
      'layers': [
        {
          'id': 'main_layer',
          'content': strokeJsonList,
        }
      ],
      'content': strokeJsonList,
    });
    archive.addFile(ArchiveFile.bytes(defaultPageFile, utf8.encode(pageJson)));

    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData);
  }

  /// Deserializes bytes into a [NoteDocument].
  ///
  /// Automatically distinguishes between:
  /// - Real Linwood Butterfly v2.x `.bfly` ZIP containers.
  /// - Upstream `.tbfly` JSON documents.
  /// - Legacy v1 single-file JSON `.bfly` files.
  static NoteDocument decode(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const FormatException('Cannot decode empty document bytes.');
    }

    if (bytes[0] == kZipSignature) {
      return _decodeZipArchive(bytes);
    } else {
      return _decodeTextJson(bytes);
    }
  }

  static NoteDocument _decodeZipArchive(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);

    // Read metadata & info
    Map<String, dynamic> infoMap = {};
    final infoArchiveFile = archive.findFile(infoFile);
    if (infoArchiveFile != null) {
      final content = utf8.decode(infoArchiveFile.content as List<int>);
      infoMap = jsonDecode(content) as Map<String, dynamic>;
    } else {
      final metaFile = archive.findFile(metaButterflyFile) ?? archive.findFile(metaPhucNoteFile);
      if (metaFile != null) {
        final content = utf8.decode(metaFile.content as List<int>);
        infoMap = jsonDecode(content) as Map<String, dynamic>;
      }
    }

    // Collect all page files sorted in order
    final pageFiles = archive.files
        .where((f) => f.name.startsWith('BFLY/pages/') && f.name.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final List<StrokeElement> strokes = [];

    for (final pageFile in pageFiles) {
      try {
        final content = utf8.decode(pageFile.content as List<int>);
        final pageMap = jsonDecode(content) as Map<String, dynamic>;
        _extractStrokesFromPageMap(pageMap, strokes);
      } catch (_) {
        // Skip corrupt single page file gracefully
      }
    }

    final title = (infoMap['title'] as String?) ??
        (infoMap['name'] as String?) ??
        'Imported Note';

    final template = PaperTemplate.values.firstWhere(
      (t) => t.name == (infoMap['paperTemplate'] as String?),
      orElse: () => PaperTemplate.ruled,
    );

    return NoteDocument(
      id: infoMap['id'] as String?,
      title: title,
      createdAt: infoMap['createdAt'] != null
          ? DateTime.tryParse(infoMap['createdAt'].toString())
          : null,
      updatedAt: infoMap['updatedAt'] != null
          ? DateTime.tryParse(infoMap['updatedAt'].toString())
          : null,
      version: infoMap['version']?.toString() ?? '1.0.0',
      paperTemplate: template,
      strokes: strokes,
    );
  }

  static NoteDocument _decodeTextJson(Uint8List bytes) {
    final jsonStr = utf8.decode(bytes);
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;

    final List<StrokeElement> strokes = [];

    // 1. Pages map (e.g., in study.tbfly)
    if (jsonMap.containsKey('pages') && jsonMap['pages'] is Map) {
      final pagesMap = jsonMap['pages'] as Map<String, dynamic>;
      final sortedPageKeys = pagesMap.keys.toList()..sort();
      for (final key in sortedPageKeys) {
        final pageObj = pagesMap[key];
        if (pageObj is Map<String, dynamic>) {
          _extractStrokesFromPageMap(pageObj, strokes);
        }
      }
    } else {
      // 2. Direct top-level content or elements (e.g., in document_v1.bfly)
      _extractStrokesFromPageMap(jsonMap, strokes);
    }

    final title = (jsonMap['name'] as String?) ??
        (jsonMap['title'] as String?) ??
        'Imported Document';

    PaperTemplate template = PaperTemplate.ruled;
    if (jsonMap.containsKey('background') && jsonMap['background'] is Map) {
      final bg = jsonMap['background'] as Map<String, dynamic>;
      if (bg['type'] == 'box' || bg['type'] == 'grid') {
        template = PaperTemplate.grid;
      }
    }

    return NoteDocument(
      id: jsonMap['id'] as String?,
      title: title,
      createdAt: jsonMap['createdAt'] != null
          ? DateTime.tryParse(jsonMap['createdAt'].toString())
          : null,
      updatedAt: jsonMap['updatedAt'] != null
          ? DateTime.tryParse(jsonMap['updatedAt'].toString())
          : null,
      version: jsonMap['version']?.toString() ?? '1.0.0',
      paperTemplate: template,
      strokes: strokes,
    );
  }

  static void _extractStrokesFromPageMap(
    Map<String, dynamic> pageMap,
    List<StrokeElement> targetStrokes,
  ) {
    final elementsToProcess = <dynamic>[];

    // Check 'layers' first (Butterfly v2 standard)
    if (pageMap.containsKey('layers') &&
        pageMap['layers'] is List &&
        (pageMap['layers'] as List).isNotEmpty) {
      final layers = pageMap['layers'] as List;
      for (final layer in layers) {
        if (layer is Map && layer.containsKey('content') && layer['content'] is List) {
          elementsToProcess.addAll(layer['content'] as List);
        }
      }
    } else if (pageMap.containsKey('content') &&
        pageMap['content'] is List &&
        (pageMap['content'] as List).isNotEmpty) {
      // Direct content list fallback
      elementsToProcess.addAll(pageMap['content'] as List);
    } else if (pageMap.containsKey('elements') &&
        pageMap['elements'] is List &&
        (pageMap['elements'] as List).isNotEmpty) {
      // Direct elements list fallback
      elementsToProcess.addAll(pageMap['elements'] as List);
    }

    // Parse ink elements
    for (final el in elementsToProcess) {
      if (el is Map<String, dynamic>) {
        final type = el['type'] as String?;
        final points = el['points'];
        if ((type == 'pen' || type == 'stroke' || type == 'path' || type == 'highlighter') &&
            points is List &&
            points.isNotEmpty) {
          try {
            targetStrokes.add(StrokeElement.fromJson(el));
          } catch (_) {
            // Ignore non-stroke element
          }
        }
      }
    }
  }
}
