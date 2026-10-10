// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:uuid/uuid.dart';
import 'stroke_element.dart';

enum PaperTemplate {
  blank,
  ruled,
  grid,
}

/// In-memory representation of a PhucNote document.
class NoteDocument {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  String version;
  PaperTemplate paperTemplate;
  final List<StrokeElement> strokes;

  NoteDocument({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.version = '1.0.0',
    this.paperTemplate = PaperTemplate.ruled,
    List<StrokeElement>? strokes,
  })  : id = id ?? const Uuid().v4(),
        title = title ?? 'Untitled Note',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        strokes = strokes ?? [];

  void addStroke(StrokeElement stroke) {
    strokes.add(stroke);
    updatedAt = DateTime.now();
  }

  bool removeStroke(StrokeElement stroke) {
    final removed = strokes.remove(stroke);
    if (removed) {
      updatedAt = DateTime.now();
    }
    return removed;
  }

  void clearStrokes() {
    strokes.clear();
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'paperTemplate': paperTemplate.name,
        'strokes': strokes.map((s) => s.toJson()).toList(),
      };

  factory NoteDocument.fromJson(Map<String, dynamic> json) => NoteDocument(
        id: json['id'] as String?,
        title: json['title'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
        version: json['version'] as String? ?? '1.0.0',
        paperTemplate: PaperTemplate.values.firstWhere(
          (t) => t.name == (json['paperTemplate'] as String?),
          orElse: () => PaperTemplate.ruled,
        ),
        strokes: (json['strokes'] as List<dynamic>?)
                ?.map((e) => StrokeElement.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
