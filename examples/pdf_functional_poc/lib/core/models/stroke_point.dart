// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:perfect_freehand/perfect_freehand.dart' as freehand;

/// Representation of a single digitized point within a handwritten stroke.
class StrokePoint {
  final double x;
  final double y;
  final double pressure;
  final double tilt;

  const StrokePoint({
    required this.x,
    required this.y,
    this.pressure = 0.5,
    this.tilt = 0.0,
  });

  Offset toOffset() => Offset(x, y);

  freehand.PointVector toFreehandPoint() => freehand.PointVector(x, y, pressure);

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'pressure': pressure,
        'tilt': tilt,
      };

  factory StrokePoint.fromJson(Map<String, dynamic> json) => StrokePoint(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        pressure: (json['pressure'] as num?)?.toDouble() ?? 0.5,
        tilt: (json['tilt'] as num?)?.toDouble() ?? 0.0,
      );

  StrokePoint copyWith({
    double? x,
    double? y,
    double? pressure,
    double? tilt,
  }) {
    return StrokePoint(
      x: x ?? this.x,
      y: y ?? this.y,
      pressure: pressure ?? this.pressure,
      tilt: tilt ?? this.tilt,
    );
  }
}
