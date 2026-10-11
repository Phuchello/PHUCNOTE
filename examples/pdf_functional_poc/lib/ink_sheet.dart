import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core/models/stroke_point.dart';
import 'core/models/stroke_property.dart';

enum InkTool { hand, pen, highlighter, eraser }

class InkStroke {
  final List<StrokePoint> points;
  final StrokeProperty property;
  InkStroke(Iterable<StrokePoint> points, this.property)
    : points = List.unmodifiable(points);
  Map<String, Object> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
    'property': property.toJson(),
  };
}

/// Session-only immutable snapshots keep exact ordering and styling on undo.
/// The PDF is never modified or passed to this controller.
class InkSheet extends ChangeNotifier {
  List<InkStroke> _strokes = const [];
  final List<List<InkStroke>> _undo = [], _redo = [];
  List<InkStroke>? _before;
  final List<StrokePoint> _points = [];
  StrokeProperty? _property;
  InkTool? _gestureTool;
  Rect _bounds = Rect.zero;
  List<InkStroke> get strokes => _strokes;
  bool get active => _before != null;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  InkStroke? get pending =>
      _points.isEmpty || _property == null || _gestureTool == InkTool.eraser
      ? null
      : InkStroke(_points, _property!);

  bool begin(Offset point, Rect bounds, InkTool tool, double pressure) {
    if (active || tool == InkTool.hand || !bounds.contains(point)) return false;
    _before = _strokes;
    _bounds = bounds;
    _gestureTool = tool;
    _property = tool == InkTool.highlighter
        ? const StrokeProperty(
            colorValue: 0xFFF2C94C,
            strokeWidth: 18,
            thinning: 0,
            isHighlighter: true,
          )
        : const StrokeProperty(
            colorValue: 0xFF285DC2,
            strokeWidth: 3,
            smoothing: .6,
            streamline: .3,
          );
    _points.clear();
    move(point, pressure);
    return true;
  }

  void move(Offset point, double pressure) {
    if (!active) return;
    final clamped = Offset(
      point.dx.clamp(_bounds.left, _bounds.right),
      point.dy.clamp(_bounds.top, _bounds.bottom),
    );
    if (_gestureTool == InkTool.eraser) {
      final previous = _points.isEmpty ? clamped : _points.last.toOffset();
      _strokes = List.unmodifiable(
        _strokes.where((stroke) => !_hit(stroke, previous, clamped)),
      );
    }
    _points.add(
      StrokePoint(
        x: clamped.dx,
        y: clamped.dy,
        pressure: pressure.isFinite ? pressure.clamp(0, 1) : .5,
      ),
    );
    notifyListeners();
  }

  static bool _hit(InkStroke stroke, Offset from, Offset to) {
    final radius = 8 + stroke.property.strokeWidth / 2;
    // Segment distance, not only point distance: sparse strokes remain erasable.
    for (var i = 0; i < stroke.points.length; i++) {
      final a = stroke.points[i].toOffset();
      final b = stroke.points[math.min(i + 1, stroke.points.length - 1)]
          .toOffset();
      if (_distance(a, from, to) <= radius ||
          _distance(b, from, to) <= radius ||
          _distance(from, a, b) <= radius ||
          _distance(to, a, b) <= radius ||
          _intersects(a, b, from, to)) {
        return true;
      }
    }
    return false;
  }

  static double _distance(Offset p, Offset a, Offset b) {
    final v = b - a;
    if (v.distanceSquared == 0) return (p - a).distance;
    final t = (((p - a).dx * v.dx + (p - a).dy * v.dy) / v.distanceSquared)
        .clamp(0.0, 1.0);
    return (p - (a + v * t)).distance;
  }

  static bool _intersects(Offset a, Offset b, Offset c, Offset d) {
    double cross(Offset x, Offset y) => x.dx * y.dy - x.dy * y.dx;
    final v = b - a, w = d - c, denominator = cross(v, w);
    if (denominator.abs() < 1e-9) return false;
    final t = cross(c - a, w) / denominator, u = cross(c - a, v) / denominator;
    return t >= 0 && t <= 1 && u >= 0 && u <= 1;
  }

  /// Cancellation commits accepted ink/erase as one undoable gesture.
  void end() {
    final before = _before;
    if (before == null) return;
    if (_gestureTool != InkTool.eraser && _points.isNotEmpty) {
      _strokes = List.unmodifiable([
        ..._strokes,
        InkStroke(_points, _property!),
      ]);
    }
    if (_strokes.length != before.length) {
      _undo.add(before);
      _redo.clear();
    }
    _before = null;
    _property = null;
    _points.clear();
    notifyListeners();
  }

  void undo() {
    end();
    if (!canUndo) return;
    _redo.add(_strokes);
    _strokes = _undo.removeLast();
    notifyListeners();
  }

  void redo() {
    end();
    if (!canRedo) return;
    _undo.add(_strokes);
    _strokes = _redo.removeLast();
    notifyListeners();
  }
}
