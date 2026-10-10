// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/note_document.dart';
import 'bfly_serializer.dart';

/// Manages local persistent file storage for PhucNote documents,
/// implementing atomic writes, crash recovery, and directory isolation.
class NoteStorage {
  static const String notesDirectoryName = 'phucnote_notes';
  static final Map<String, Future<void>> _pendingWrites = {};
  final Directory? customRootDirectory;

  NoteStorage({this.customRootDirectory});

  /// Resolves the storage directory for notes.
  Future<Directory> getNotesDirectory() async {
    if (customRootDirectory != null) {
      if (!await customRootDirectory!.exists()) {
        await customRootDirectory!.create(recursive: true);
      }
      return customRootDirectory!;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/$notesDirectoryName');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    return notesDir;
  }

  /// Lists all saved `.bfly` notes on disk, ordered by last modified date (newest first).
  Future<List<File>> listSavedNotes() async {
    final dir = await getNotesDirectory();
    final entities = await dir.list().toList();
    final files = entities.whereType<File>().where((f) => f.path.endsWith('.bfly')).toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  /// Saves a document atomically as a `.bfly` file.
  ///
  /// Guarantees that:
  /// 1. Data is written and flushed to a temporary file in the same directory.
  /// 2. If the write fails or is interrupted, the original file is never corrupted or truncated.
  /// 3. The temporary file is atomically renamed to the target filename.
  /// 4. An optional `.bak` backup of the previous version is kept for disaster recovery.
  Future<File> saveNote(NoteDocument document) async {
    // Capture bytes and the filename before yielding to any edits or queued saves.
    final bytes = BflySerializer.encode(document);
    final sanitizedTitle = document.title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
    final filename = '${sanitizedTitle}_${document.id.substring(0, 8)}.bfly';
    final previous = _pendingWrites[document.id] ?? Future<void>.value();
    final result = previous.then((_) => _writeNote(filename, bytes));
    // A failed write must not poison subsequent requests for this document.
    final tail = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    _pendingWrites[document.id] = tail;
    tail.then((_) {
      if (identical(_pendingWrites[document.id], tail)) {
        _pendingWrites.remove(document.id);
      }
    });
    return result;
  }

  Future<File> _writeNote(String filename, Uint8List bytes) async {
    final dir = await getNotesDirectory();
    final targetFile = File('${dir.path}/$filename');
    final tmpFile = File('${targetFile.path}.tmp_${DateTime.now().microsecondsSinceEpoch}');

    try {
      // Flush bytes to ensure all buffers are written to the physical block device
      await tmpFile.writeAsBytes(bytes, flush: true);

      // Create backup of existing file if it exists
      if (await targetFile.exists()) {
        final bakFile = File('${targetFile.path}.bak');
        await targetFile.copy(bakFile.path);
      }

      // Atomic rename/move over the destination
      await tmpFile.rename(targetFile.path);
      return targetFile;
    } catch (e) {
      // Clean up temporary file so no half-written or orphaned files remain
      if (await tmpFile.exists()) {
        try {
          await tmpFile.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// Loads a document from a given `.bfly` file with automatic fallback recovery.
  Future<NoteDocument> loadNote(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return BflySerializer.decode(bytes);
    } catch (primaryError) {
      // Attempt recovery from .bak file if available
      final bakFile = File('${file.path}.bak');
      if (await bakFile.exists()) {
        try {
          final bakBytes = await bakFile.readAsBytes();
          return BflySerializer.decode(bakBytes);
        } catch (_) {
          // If backup also fails, throw primary error
        }
      }
      rethrow;
    }
  }

  /// Deletes a saved note file and its corresponding backup.
  Future<void> deleteNote(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
    final bakFile = File('${file.path}.bak');
    if (await bakFile.exists()) {
      await bakFile.delete();
    }
  }
}
