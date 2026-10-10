// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/models/note_document.dart';
import '../core/models/stroke_element.dart';
import '../core/models/stroke_point.dart';
import '../core/models/stroke_property.dart';
import 'canvas_action.dart';
import 'a4_page_layout.dart';

enum CanvasTool {
  pen,
  highlighter,
  eraser,
}

/// Controller coordinating input events, stylus-only gating, active strokes,
/// eraser collisions, viewport panning, and the full action-history undo/redo engine.
class CanvasController extends ChangeNotifier {
  NoteDocument _document;
  CanvasTool _tool = CanvasTool.pen;
  Color _color = const Color(0xFF1E1E1E);
  double _strokeWidth = 3.0;

  final List<StrokePoint> _activePoints = [];
  Offset? _eraserPosition;
  final double eraserRadius = 20.0;

  // Action-History Undo / Redo Stacks
  final List<CanvasAction> _undoStack = [];
  final List<CanvasAction> _redoStack = [];

  // Temporary buffers during an in-flight eraser gesture
  final List<StrokeElement> _sessionErasedStrokes = [];
  final List<int> _sessionErasedIndices = [];
  final Map<StrokeElement, int> _sessionStrokeIndices = {};

  // Stylus and Palm Rejection Settings
  bool _stylusOnlyMode = false;
  bool _isStylusActive = false;

  // Viewport navigation offset and zoom
  Offset _viewportOffset = Offset.zero;
  double _zoomScale = 1.0;

  static const double minZoom = 0.5;
  static const double maxZoom = 4.0;
  static const double maxTopOverscroll = 80.0;

  // A4 Notebook Visual Guides (210:297 aspect ratio layout)
  bool _showA4Guides = false;
  static const double a4Width = A4PageLayout.width;
  static const double a4Height = A4PageLayout.height;
  static const double a4PageGap = A4PageLayout.gap;

  int _repaintCounter = 0;
  int _revision = 0;
  int _savedRevision = 0;

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
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get revision => _revision;
  bool get isModified => _revision != _savedRevision;
  bool get stylusOnlyMode => _stylusOnlyMode;
  bool get isStylusActive => _isStylusActive;
  Offset get viewportOffset => _viewportOffset;
  double get zoomScale => _zoomScale;
  bool get showA4Guides => _showA4Guides;

  void toggleA4Guides() {
    _showA4Guides = !_showA4Guides;
    _repaintCounter++;
    notifyListeners();
  }

  void setShowA4Guides(bool enabled, {bool fitWidth = false, double? viewportWidth}) {
    if (_showA4Guides != enabled) {
      _showA4Guides = enabled;
      _repaintCounter++;
      notifyListeners();
    }
    if (enabled && fitWidth && viewportWidth != null) {
      fitToWidth(viewportWidth);
    }
  }

  /// Fits the A4 page preview to the specified viewport width, adjusting
  /// zoom and horizontal offset so the entire A4 width is visible and centered.
  void fitToWidth(double viewportWidth) {
    if (viewportWidth <= 0) return;
    _showA4Guides = true;
    final newZoom = (viewportWidth / a4Width).clamp(minZoom, maxZoom);
    final newDx = (viewportWidth - a4Width * newZoom) / 2.0;
    _zoomScale = newZoom;
    _viewportOffset = Offset(newDx, _viewportOffset.dy);
    _repaintCounter++;
    notifyListeners();
  }

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
    _sessionErasedStrokes.clear();
    _sessionErasedIndices.clear();
    _sessionStrokeIndices.clear();
    _viewportOffset = Offset.zero;
    _zoomScale = 1.0;
    _repaintCounter++;
    _revision++;
    _savedRevision = _revision;
    notifyListeners();
  }

  void setTool(CanvasTool newTool) {
    if (_tool != newTool) {
      _finishEraseSession();
      _tool = newTool;
      notifyListeners();
    }
  }

  void setColor(Color newColor) {
    if (_color != newColor) {
      _color = newColor;
      if (_tool == CanvasTool.eraser) {
        _finishEraseSession();
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
      _revision++;
      _repaintCounter++;
      notifyListeners();
    }
  }

  void renameDocument(String title) {
    if (_document.title != title) {
      _document.title = title;
      _document.updatedAt = DateTime.now();
      _revision++;
      notifyListeners();
    }
  }

  void setStylusOnlyMode(bool enabled) {
    if (_stylusOnlyMode != enabled) {
      _stylusOnlyMode = enabled;
      notifyListeners();
    }
  }

  void panViewport(Offset delta) {
    final newDx = _viewportOffset.dx + delta.dx;
    final newDy = (_viewportOffset.dy + delta.dy).clamp(double.negativeInfinity, maxTopOverscroll);
    _viewportOffset = Offset(newDx, newDy);
    _repaintCounter++;
    notifyListeners();
  }

  void zoomAt(Offset focalPoint, double scaleFactor) {
    final oldZoom = _zoomScale;
    final newZoom = (oldZoom * scaleFactor).clamp(minZoom, maxZoom);
    if (newZoom == oldZoom) return;

    final actualRatio = newZoom / oldZoom;
    final newDx = focalPoint.dx - (focalPoint.dx - _viewportOffset.dx) * actualRatio;
    final newDy = (focalPoint.dy - (focalPoint.dy - _viewportOffset.dy) * actualRatio)
        .clamp(double.negativeInfinity, maxTopOverscroll);

    _zoomScale = newZoom;
    _viewportOffset = Offset(newDx, newDy);
    _repaintCounter++;
    notifyListeners();
  }

  void applyTransform({
    required Offset focalPoint,
    required Offset prevFocalPoint,
    required double scaleDelta,
  }) {
    final oldZoom = _zoomScale;
    final newZoom = (oldZoom * scaleDelta).clamp(minZoom, maxZoom);
    final actualRatio = newZoom / oldZoom;

    // Stable focal point transform formula:
    final newDx = focalPoint.dx - (prevFocalPoint.dx - _viewportOffset.dx) * actualRatio;
    final newDy = (focalPoint.dy - (prevFocalPoint.dy - _viewportOffset.dy) * actualRatio)
        .clamp(double.negativeInfinity, maxTopOverscroll);

    _zoomScale = newZoom;
    _viewportOffset = Offset(newDx, newDy);
    _repaintCounter++;
    notifyListeners();
  }

  void resetViewport() {
    _viewportOffset = Offset.zero;
    _zoomScale = 1.0;
    _repaintCounter++;
    notifyListeners();
  }

  void cancelActivePoints() {
    if (_activePoints.isNotEmpty) {
      _activePoints.clear();
      _repaintCounter++;
      notifyListeners();
    }
  }

  /// Converts a screen local position to document/canvas coordinates.
  Offset screenToCanvas(Offset screenPos) {
    return (screenPos - _viewportOffset) / _zoomScale;
  }

  /// Converts a document/canvas coordinate to screen local position.
  Offset canvasToScreen(Offset canvasPos) {
    return canvasPos * _zoomScale + _viewportOffset;
  }

  /// Returns the bounding box of the visible canvas rectangle given screen viewport dimensions.
  Rect getVisibleCanvasRect(Size viewportSize) {
    final topLeft = screenToCanvas(Offset.zero);
    final bottomRight = screenToCanvas(Offset(viewportSize.width, viewportSize.height));
    return Rect.fromLTRB(topLeft.dx, topLeft.dy, bottomRight.dx, bottomRight.dy);
  }

  /// Evaluates whether an incoming pointer event should be accepted for inking.
  bool shouldAcceptPointerForInking(PointerEvent event) {
    final isStylus = event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;

    if (isStylus) {
      return true;
    }

    // In stylus-only mode, completely reject touch events from inking
    if (_stylusOnlyMode && event.kind == PointerDeviceKind.touch) {
      return false;
    }

    // Software palm rejection: reject touch if active stylus is down
    if (_isStylusActive && event.kind == PointerDeviceKind.touch) {
      return false;
    }

    // Software palm rejection: reject touch with large contact area
    if (event.kind == PointerDeviceKind.touch) {
      if (event.size > 0.5 || (event.radiusMajor > 35 && event.radiusMinor > 25)) {
        return false;
      }
    }

    // Allow mouse (desktop/testing) or standard touch when stylus-only mode is off
    return true;
  }

  Offset _canvasCoordinates(Offset localPosition) {
    return screenToCanvas(localPosition);
  }

  void handlePointerDown(PointerDownEvent event) {
    final isStylus = event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;
    if (isStylus) {
      _isStylusActive = true;
    }

    if (!shouldAcceptPointerForInking(event)) {
      return;
    }

    _finishEraseSession();
    final canvasPos = _canvasCoordinates(event.localPosition);
    final pressure = event.pressure.clamp(0.1, 1.0);

    // If stylus inverted tip is used, temporarily behave as eraser
    final effectiveTool = (event.kind == PointerDeviceKind.invertedStylus)
        ? CanvasTool.eraser
        : _tool;

    if (effectiveTool == CanvasTool.eraser) {
      _sessionErasedStrokes.clear();
      _sessionErasedIndices.clear();
      _sessionStrokeIndices.addAll({
        for (var i = 0; i < _document.strokes.length; i++)
          _document.strokes[i]: i,
      });
      _eraserPosition = canvasPos;
      _eraseAt(canvasPos);
      notifyListeners();
      return;
    }

    _activePoints.clear();
    if (_showA4Guides && A4PageLayout.pageIndexAt(canvasPos) == null) {
      notifyListeners();
      return;
    }
    // A4 limits only stroke initiation. Once accepted, every sample is retained
    // across page edges/gaps as one global-coordinate stroke and undo action.
    _activePoints.add(StrokePoint(
      x: canvasPos.dx,
      y: canvasPos.dy,
      pressure: pressure,
      tilt: event.tilt,
    ));
    notifyListeners();
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (!shouldAcceptPointerForInking(event)) {
      return;
    }

    final canvasPos = _canvasCoordinates(event.localPosition);
    final pressure = event.pressure.clamp(0.1, 1.0);

    final effectiveTool = (event.kind == PointerDeviceKind.invertedStylus)
        ? CanvasTool.eraser
        : _tool;

    if (effectiveTool == CanvasTool.eraser) {
      if (_eraserPosition == null) return;
      _eraserPosition = canvasPos;
      _eraseAt(canvasPos);
      notifyListeners();
      return;
    }

    if (_activePoints.isNotEmpty) {
      _activePoints.add(StrokePoint(
        x: canvasPos.dx,
        y: canvasPos.dy,
        pressure: pressure,
        tilt: event.tilt,
      ));
      notifyListeners();
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    final isStylus = event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;
    if (isStylus) {
      _isStylusActive = false;
    }

    if (!shouldAcceptPointerForInking(event)) {
      return;
    }

    if (_eraserPosition != null) {
      _finishEraseSession();
      notifyListeners();
      return;
    }

    if (_activePoints.isNotEmpty) {
      final stroke = StrokeElement(
        id: const Uuid().v4(),
        points: List.of(_activePoints),
        property: currentProperty,
      );
      final action = AddStrokeAction(stroke);
      action.execute(_document);
      _undoStack.add(action);
      _redoStack.clear();
      _revision++;
      _repaintCounter++;
    }

    _activePoints.clear();
    notifyListeners();
  }

  void handlePointerCancel(PointerCancelEvent event) {
    _isStylusActive = false;
    _activePoints.clear();
    // Erasures already changed the document; cancellation still needs history.
    _finishEraseSession();
    notifyListeners();
  }

  void _finishEraseSession() {
    if (_sessionErasedStrokes.isNotEmpty) {
      _undoStack.add(
        EraseStrokesAction(
          erasedStrokes: _sessionErasedStrokes,
          originalIndices: _sessionErasedIndices,
        ),
      );
      _redoStack.clear();
    }
    _eraserPosition = null;
    _sessionErasedStrokes.clear();
    _sessionErasedIndices.clear();
    _sessionStrokeIndices.clear();
  }

  void _eraseAt(Offset pos) {
    final newlyErased = <StrokeElement>[];
    final newlyErasedIndices = <int>[];

    for (int i = _document.strokes.length - 1; i >= 0; i--) {
      final stroke = _document.strokes[i];
      if (stroke.hitTest(pos, eraserRadius)) {
        newlyErased.add(stroke);
        newlyErasedIndices.add(_sessionStrokeIndices[stroke]!);
      }
    }

    if (newlyErased.isNotEmpty) {
      for (int i = 0; i < newlyErased.length; i++) {
        final s = newlyErased[i];
        final originalIdx = newlyErasedIndices[i];
        _document.removeStroke(s);
        _sessionErasedStrokes.add(s);
        _sessionErasedIndices.add(originalIdx);
      }
      _revision++;
      _repaintCounter++;
    }
  }

  /// Undoes the last action in the action-history stack.
  void undo() {
    _finishEraseSession();
    if (_undoStack.isNotEmpty) {
      final action = _undoStack.removeLast();
      action.undo(_document);
      _redoStack.add(action);
      _revision++;
      _repaintCounter++;
      notifyListeners();
    }
  }

  /// Redoes the last reverted action from the redo stack.
  void redo() {
    _finishEraseSession();
    if (_redoStack.isNotEmpty) {
      final action = _redoStack.removeLast();
      action.redo(_document);
      _undoStack.add(action);
      _revision++;
      _repaintCounter++;
      notifyListeners();
    }
  }

  /// Clears all strokes on the canvas and logs a ClearCanvasAction to undo stack.
  void clearCanvas() {
    _finishEraseSession();
    if (_document.strokes.isNotEmpty) {
      final action = ClearCanvasAction(_document.strokes);
      action.execute(_document);
      _undoStack.add(action);
      _redoStack.clear();
      _revision++;
      _repaintCounter++;
      notifyListeners();
    }
  }

  void markSaved({required NoteDocument document, required int revision}) {
    if (identical(document, _document) && revision == _revision) {
      _savedRevision = revision;
      notifyListeners();
    }
  }
}
