import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/note_document.dart';
import 'package:phucnote/core/models/stroke_element.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/core/storage/note_storage.dart';

class _GatedStorage extends NoteStorage {
  final entered = Completer<void>();
  final release = Completer<void>();
  int directoryCalls = 0;
  bool failFirst = false;

  _GatedStorage(Directory root) : super(customRootDirectory: root);

  @override
  Future<Directory> getNotesDirectory() async {
    directoryCalls++;
    if (directoryCalls == 1) {
      entered.complete();
      await release.future;
      if (failFirst) throw const FileSystemException('first write failed');
    }
    return super.getNotesDirectory();
  }
}

void main() {
  late Directory root;
  late _GatedStorage storage;

  setUp(() {
    root = Directory.systemTemp.createTempSync('phucnote_p0_');
    storage = _GatedStorage(root);
  });
  tearDown(() => root.deleteSync(recursive: true));

  test(
    'a failed write does not block a queued save from another storage instance',
    () async {
      storage.failFirst = true;
      final document = NoteDocument(title: 'Retry');
      final first = storage.saveNote(document);
      final firstFailure = expectLater(
        first,
        throwsA(isA<FileSystemException>()),
      );
      await storage.entered.future;
      document.paperTemplate = PaperTemplate.grid;
      final second = NoteStorage(customRootDirectory: root).saveNote(document);
      storage.release.complete();
      await firstFailure;
      final file = await second;
      expect((await storage.loadNote(file)).paperTemplate, PaperTemplate.grid);
    },
  );

  test(
    'save snapshots metadata and stroke data before its first await',
    () async {
      final stroke = StrokeElement(
        id: 'first',
        points: [const StrokePoint(x: 1, y: 1)],
        property: const StrokeProperty(colorValue: 0xff000000),
      );
      final document = NoteDocument(title: 'Before', strokes: [stroke]);
      final pending = storage.saveNote(document);
      await storage.entered.future;
      document.title = 'After';
      stroke.points.add(const StrokePoint(x: 2, y: 2));
      document.strokes.clear();
      storage.release.complete();
      final file = await pending;
      final saved = await storage.loadNote(file);
      expect(saved.title, 'Before');
      expect(saved.strokes.single.points.length, 1);
      expect(file.path, contains('Before_'));
    },
  );

  test(
    'concurrent saves for one document cannot overwrite the newer request',
    () async {
      final older = NoteDocument(
        title: 'Same',
        paperTemplate: PaperTemplate.ruled,
      );
      final newer = NoteDocument(
        id: older.id,
        title: 'Same',
        paperTemplate: PaperTemplate.grid,
      );
      final first = storage.saveNote(older);
      await storage.entered.future;
      final second = storage.saveNote(newer);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final callsWhileBlocked = storage.directoryCalls;
      storage.release.complete();
      final files = await Future.wait([first, second]);
      expect(callsWhileBlocked, 1);
      expect(
        (await storage.loadNote(files.last)).paperTemplate,
        PaperTemplate.grid,
      );
      expect(
        (await storage.loadNote(File('${files.last.path}.bak'))).paperTemplate,
        PaperTemplate.ruled,
      );
      expect(
        root.listSync().where((file) => file.path.contains('.tmp_')),
        isEmpty,
      );
    },
  );

  test(
    'different documents are not blocked by another document save',
    () async {
      final first = storage.saveNote(NoteDocument(title: 'Blocked'));
      await storage.entered.future;
      final second = await storage.saveNote(NoteDocument(title: 'Independent'));
      expect((await storage.loadNote(second)).title, 'Independent');
      storage.release.complete();
      await first;
    },
  );
}
