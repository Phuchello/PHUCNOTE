// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/models/note_document.dart';
import '../core/models/stroke_element.dart';
import '../core/models/stroke_point.dart';
import '../core/models/stroke_property.dart';

enum CanvasTool {
  pen,
  highlighter,
  eraser,
}

/// Controller coordinating input events, in-flight strokes, eraser collisions,
/// and document undo/redo stacks.
class CanvasController extends ChangeNotifier {
  NoteDocument _document;
  CanvasTool _tool = CanvasTool.pen;
  Color _color = const Color(0xFF1E1E1E);
  double _strokeWidth = 3.0;

  final List<StrokePoint> _activePoints = [];
  Offset? _eraserPosition;
  final double eraserRadius = 20.0;

  final List<StrokeElement> _undoStack = [];
  final List<StrokeElement> _redoStack = [];

  int _repaintCounter = 0;
  bool _isModified = false;

  CanvasController({NoteDocument? document})
      : _document = document ?? NoteDocument();

  // Getters
  NoteDocument get document => _document;
  CanvasTool get tool => _tool;
  Color get color => _color;
  double get strokeWidth => _strokeWidth;
  List<StrokePoint> get activePoints => List.unmodifiable(_activePoints);
  Offset? get eraserPosition => _eraserPosition;
  int get repaintCounter => _repaintCounter;
  bool get canUndo => _undoStack.isNotEmpty || _document.strokes.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get isModified => _isModified;

  StrokeProperty get currentProperty => StrokeProperty(
        colorValue: _color.toARGB32(),
        strokeWidth: _tool == CanvasTool.highlighter ? _strokeWidth * 3.5 : _strokeWidth,
        thinning: _tool == CanvasTool.highlighter ? 0.0 : 0.45,
        smoothing: 0.55,
        streamline: 0.40,
        isHighlighter: _tool == CanvasTool.highlighter,
        opacity: _tool == CanvasTool.highlighter ? 0.35 : 1.0,
      );

  void setDocument(NoteDocument doc) {
    _document = doc;
    _activePoints.clear();
    _eraserPosition = null;
    _undoStack.clear();
    _redoStack.clear();
    _repaintCounter++;
    _isModified = false;
    notifyListeners();
  }

  void setTool(CanvasTool newTool) {
    if (_tool != newTool) {
      _tool = newTool;
      notifyListeners();
    }
  }

  void setColor(Color newColor) {
    if (_color != newColor) {
      _color = newColor;
      if (_tool == CanvasTool.eraser) {
        _tool = CanvasTool.pen;
      }
      notifyListeners();
    }
  }

  void setStrokeWidth(double newWidth) {
    if (_strokeWidth != newWidth) {
      _strokeWidth = newWidth;
      notifyListeners();
    }
  }

  void setPaperTemplate(PaperTemplate template) {
    if (_document.paperTemplate != template) {
      _document.paperTemplate = template;
      _isModified = true;
      _repaintCounter++;
      notifyListeners();
    }
  }

  void handlePointerDown(PointerDownEvent event) {
    final pos = event.localPosition;
    final pressure = event.pressure.clamp(0.1, 1.0);

    if (_tool == CanvasTool.eraser) {
      _eraserPosition = pos;
      _eraseAt(pos);
      notifyListeners();
      return;
    }

    _activePoints.clear();
    _activePoints.add(StrokePoint(
      x: pos.dx,
      y: pos.dy,
      pressure: pressure,
      tilt: event.tilt,
    ));
    notifyListeners();
  }

  void handlePointerMove(PointerMoveEvent event) {
    final pos = event.localPosition;
    final pressure = event.pressure.clamp(0.1, 1.0);

    if (_tool == CanvasTool.eraser) {
      _eraserPosition = pos;
      _eraseAt(pos);
      notifyListeners();
      return;
    }

    if (_activePoints.isNotEmpty) {
      _activePoints.add(StrokePoint(
        x: pos.dx,
        y: pos.dy,
        pressure: pressure,
        tilt: event.tilt,
      ));
      notifyListeners();
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    if (_tool == CanvasTool.eraser) {
      _eraserPosition = null;
      notifyListeners();
      return;
    }

    if (_activePoints.length >= 2 || _activePoints.length == 1) {
      final stroke = StrokeElement(
        id: const Uuid().v4(),
        points: List.of(_activePoints),
        property: currentProperty,
      );
      _document.addStroke(stroke);
      _undoStack.add(stroke);
      _redoStack.clear();
      _isModified = true;
      _repaintCounter++;
    }

    _activePoints.clear();
    notifyListeners();
  }

  void handlePointerCancel(PointerCancelEvent event) {
    _activePoints.clear();
    _eraserPosition = null;
    notifyListeners();
  }

  void _eraseAt(Offset pos) {
    final toRemove = <StrokeElement>[];
    for (final stroke in _document.strokes) {
      if (stroke.hitTest(pos, eraserRadius)) {
        toRemove.add(stroke);
      }
    }

    if (toRemove.isNotEmpty) {
      for (final s in toRemove) {
        _document.removeStroke(s);
      }
      _isModified = true;
      _repaintCounter++;
    }
  }

  void undo() {
    if (_document.strokes.isNotEmpty) {
      final lastStroke = _document.strokes.removeLast();
      _redoStack.add(lastStroke);
      _isModified = true;
      _repaintCounter++;
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      final stroke = _redoStack.removeLast();
      _document.addStroke(stroke);
      _isModified = true;
      _repaintCounter++;
      notifyListeners();
    }
  }

  void clearCanvas() {
    if (_document.strokes.isNotEmpty) {
      _redoStack.addAll(_document.strokes.reversed);
      _document.clearStrokes();
      _isModified = true;
      _repaintCounter++;
      notifyListeners();
    }
  }

  void markSaved() {
    _isModified = false;
    notifyListeners();
  }
}
