// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note_document.dart';
import 'bfly_serializer.dart';

/// Manages local persistent file storage for PhucNote documents.
class NoteStorage {
  static const String notesDirectoryName = 'phucnote_notes';

  Future<Directory> getNotesDirectory() async {
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

  /// Saves a document as a `.bfly` file in the notes directory.
  Future<File> saveNote(NoteDocument document) async {
    final dir = await getNotesDirectory();
    final sanitizedTitle = document.title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
    final filename = '${sanitizedTitle}_${document.id.substring(0, 8)}.bfly';
    final file = File('${dir.path}/$filename');

    final bytes = BflySerializer.encode(document);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Loads a document from a given `.bfly` file.
  Future<NoteDocument> loadNote(File file) async {
    final bytes = await file.readAsBytes();
    return BflySerializer.decode(bytes);
  }

  /// Deletes a saved note file.
  Future<void> deleteNote(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
