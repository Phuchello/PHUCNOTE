// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:ui';
import 'package:uuid/uuid.dart';
import 'stroke_point.dart';
import 'stroke_property.dart';

/// Representation of a persistent vector ink stroke on a page.
class StrokeElement {
  final String id;
  final List<StrokePoint> points;
  final StrokeProperty property;
  final DateTime createdAt;

  StrokeElement({
    required this.id,
    required this.points,
    required this.property,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Rect get boundingBox {
    if (points.isEmpty) return Rect.zero;
    double minX = points.first.x;
    double maxX = points.first.x;
    double minY = points.first.y;
    double maxY = points.first.y;

    for (final p in points) {
      minX = min(minX, p.x);
      maxX = max(maxX, p.x);
      minY = min(minY, p.y);
      maxY = max(maxY, p.y);
    }

    final pad = property.strokeWidth;
    return Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
  }

  /// Checks if a test point (such as an eraser pointer) is within [radius] of any stroke point.
  bool hitTest(Offset position, double radius) {
    if (points.isEmpty) return false;
    final box = boundingBox.inflate(radius);
    if (!box.contains(position)) return false;

    final thresholdSq = (radius + property.strokeWidth / 2) * (radius + property.strokeWidth / 2);
    for (final p in points) {
      final dx = p.x - position.dx;
      final dy = p.y - position.dy;
      if (dx * dx + dy * dy <= thresholdSq) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'pen',
        'points': points.map((p) => p.toJson()).toList(),
        'property': property.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory StrokeElement.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String?;
    final id = (rawId != null && rawId.isNotEmpty) ? rawId : const Uuid().v4();

    final rawPoints = json['points'] as List<dynamic>? ?? [];
    final points = <StrokePoint>[];
    for (final pt in rawPoints) {
      if (pt is Map<String, dynamic>) {
        try {
          points.add(StrokePoint.fromJson(pt));
        } catch (_) {}
      }
    }

    final property = json['property'] != null && json['property'] is Map<String, dynamic>
        ? StrokeProperty.fromJson(json['property'] as Map<String, dynamic>)
        : const StrokeProperty(colorValue: 0xFF1E1E1E);

    final rawDate = json['createdAt'];
    DateTime createdAt = DateTime.now();
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
    }

    return StrokeElement(
      id: id,
      points: points,
      property: property,
      createdAt: createdAt,
    );
  }
}
