// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Styling and geometry parameters for rendering ink strokes.
class StrokeProperty {
  final int colorValue;
  final double strokeWidth;
  final double thinning;
  final double smoothing;
  final double streamline;
  final bool isHighlighter;
  final double opacity;

  const StrokeProperty({
    required this.colorValue,
    this.strokeWidth = 3.0,
    this.thinning = 0.5,
    this.smoothing = 0.5,
    this.streamline = 0.5,
    this.isHighlighter = false,
    this.opacity = 1.0,
  });

  Color get color => Color(colorValue).withValues(alpha: isHighlighter ? 0.35 : opacity);

  Map<String, dynamic> toJson() => {
        'color': colorValue,
        'strokeWidth': strokeWidth,
        'thinning': thinning,
        'smoothing': smoothing,
        'streamline': streamline,
        'isHighlighter': isHighlighter,
        'opacity': opacity,
        'type': 'pen',
      };

  static int _extractColorValue(Map<String, dynamic> json) {
    if (json.containsKey('color')) {
      final c = json['color'];
      if (c is int) return c;
      if (c is String) {
        final sanitized = c.replaceFirst('#', '');
        final parsed = int.tryParse(sanitized, radix: 16);
        if (parsed != null) {
          return (parsed <= 0xFFFFFF) ? (0xFF000000 | parsed) : parsed;
        }
      }
    }
    if (json.containsKey('paint') && json['paint'] is Map<String, dynamic>) {
      final paint = json['paint'] as Map<String, dynamic>;
      final c = paint['color'];
      if (c is int) return c;
      if (c is Map && c['value'] is int) return c['value'] as int;
    }
    return 0xFF1E1E1E;
  }

  factory StrokeProperty.fromJson(Map<String, dynamic> json) {
    final parsedColor = _extractColorValue(json);
    final width = (json['strokeWidth'] as num?)?.toDouble() ?? 3.0;
    final isHigh = (json['isHighlighter'] as bool?) ?? (json['type'] == 'highlighter');

    return StrokeProperty(
      colorValue: parsedColor,
      strokeWidth: width,
      thinning: (json['thinning'] as num?)?.toDouble() ?? 0.5,
      smoothing: (json['smoothing'] as num?)?.toDouble() ?? 0.5,
      streamline: (json['streamline'] as num?)?.toDouble() ?? 0.5,
      isHighlighter: isHigh,
      opacity: (json['opacity'] as num?)?.toDouble() ?? (isHigh ? 0.35 : 1.0),
    );
  }

  StrokeProperty copyWith({
    int? colorValue,
    double? strokeWidth,
    double? thinning,
    double? smoothing,
    double? streamline,
    bool? isHighlighter,
    double? opacity,
  }) {
    return StrokeProperty(
      colorValue: colorValue ?? this.colorValue,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      thinning: thinning ?? this.thinning,
      smoothing: smoothing ?? this.smoothing,
      streamline: streamline ?? this.streamline,
      isHighlighter: isHighlighter ?? this.isHighlighter,
      opacity: opacity ?? this.opacity,
    );
  }
}
