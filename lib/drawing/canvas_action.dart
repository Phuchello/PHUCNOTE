// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import '../core/models/note_document.dart';
import '../core/models/stroke_element.dart';

/// Abstract base class for undoable canvas actions.
abstract class CanvasAction {
  /// Applies the action to the document.
  void execute(NoteDocument document);

  /// Reverts the effects of this action on the document.
  void undo(NoteDocument document);

  /// Re-applies the action on the document after an undo.
  void redo(NoteDocument document) => execute(document);
}

/// Action representing adding a new handwritten stroke to the canvas.
class AddStrokeAction implements CanvasAction {
  final StrokeElement stroke;

  AddStrokeAction(this.stroke);

  @override
  void execute(NoteDocument document) {
    document.addStroke(stroke);
  }

  @override
  void undo(NoteDocument document) {
    document.removeStroke(stroke);
  }

  @override
  void redo(NoteDocument document) {
    document.addStroke(stroke);
  }
}

/// Action representing erasing one or more strokes from the canvas.
/// Preserves the original indices so strokes are restored in their exact z-order.
class EraseStrokesAction implements CanvasAction {
  final List<StrokeElement> erasedStrokes;
  final List<int> originalIndices;

  EraseStrokesAction({
    required List<StrokeElement> erasedStrokes,
    required List<int> originalIndices,
  })  : erasedStrokes = List.unmodifiable(erasedStrokes),
        originalIndices = List.unmodifiable(originalIndices);

  @override
  void execute(NoteDocument document) {
    for (final stroke in erasedStrokes) {
      document.removeStroke(stroke);
    }
  }

  @override
  void undo(NoteDocument document) {
    // Restore strokes at their original indices if possible, or append
    for (int i = 0; i < erasedStrokes.length; i++) {
      final stroke = erasedStrokes[i];
      final targetIndex = originalIndices[i];
      if (targetIndex >= 0 && targetIndex <= document.strokes.length) {
        document.strokes.insert(targetIndex, stroke);
      } else {
        document.strokes.add(stroke);
      }
    }
  }

  @override
  void redo(NoteDocument document) {
    execute(document);
  }
}

/// Action representing clearing all strokes from the canvas.
class ClearCanvasAction implements CanvasAction {
  final List<StrokeElement> previousStrokes;

  ClearCanvasAction(List<StrokeElement> strokes)
      : previousStrokes = List.unmodifiable(strokes);

  @override
  void execute(NoteDocument document) {
    document.clearStrokes();
  }

  @override
  void undo(NoteDocument document) {
    document.clearStrokes();
    for (final s in previousStrokes) {
      document.addStroke(s);
    }
  }

  @override
  void redo(NoteDocument document) {
    execute(document);
  }
}
