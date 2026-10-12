import 'dart:io';
import 'package:flutter/gestures.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';
import 'package:phucnote/drawing/canvas_controller.dart';

void main() {
  test('legacy/new ink survives 60-stroke workflow, undo/redo and real save/reopen', () async {
    final dir = Directory.systemTemp.createTempSync('phucnote_workflow_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final old = BflySerializer.decode(File('test/fixtures/document_v1.bfly').readAsBytesSync());
    final oldStrokesJson = old.strokes.map((s) => s.toJson()).toList();
    final oldCount = old.strokes.length;
    final c = CanvasController(document: old);
    addTearDown(c.dispose);
    for (var i = 0; i < 60; i++) {
      c.setPenProperty(PenPreset.defaults[i % 3].property);
      final position = Offset(20, 100.0 + i * 3);
      final pointer = i + 1;
      c.handlePointerDown(PointerDownEvent(pointer: pointer, kind: PointerDeviceKind.stylus, position: c.canvasToScreen(position), pressure: .5));
      var lastPos = position;
      for (var j = 1; j <= 8; j++) {
        lastPos = position + Offset(j * 2.0, j.isEven ? 0.0 : 2.0);
        c.handlePointerMove(PointerMoveEvent(pointer: pointer, kind: PointerDeviceKind.stylus, position: c.canvasToScreen(lastPos), pressure: .2 + j * .08));
      }
      c.handlePointerUp(PointerUpEvent(pointer: pointer, kind: PointerDeviceKind.stylus, position: c.canvasToScreen(lastPos), pressure: .84));
      if ((i + 1) % 20 == 0) c.toggleA4Guides();
      c.panViewport(const Offset(5, -5));
      c.zoomAt(Offset.zero, 1.01);
    }
    expect(c.document.strokes.length, oldCount + 60);
    for (var i = 0; i < oldCount; i++) {
      expect(c.document.strokes[i].toJson(), oldStrokesJson[i]);
    }
    final fullStrokeJsons = c.document.strokes.map((s) => s.toJson()).toList();
    for (var i = 0; i < 60; i++) { c.undo(); }
    expect(c.document.strokes.length, oldCount);
    for (var i = 0; i < 60; i++) { c.redo(); }
    expect(c.document.strokes.map((s) => s.toJson()).toList(), fullStrokeJsons);
    final file = await NoteStorage(customRootDirectory: dir).saveNote(c.document);
    final reopened = BflySerializer.decode(await file.readAsBytes());
    expect(reopened.strokes.map((s) => s.toJson()).toList(), fullStrokeJsons);
    c.setStylusOnlyMode(false);
    c.setDocument(reopened);
    expect(c.stylusOnlyMode, isFalse);
  });
}
