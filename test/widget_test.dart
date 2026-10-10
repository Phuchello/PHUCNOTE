// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/toolbar_widget.dart';

void main() {
  testWidgets('PhucNoteApp UI smoke test', (WidgetTester tester) async {
    final noteStorage = NoteStorage();
    await tester.pumpWidget(PhucNoteApp(noteStorage: noteStorage));
    await tester.pumpAndSettle();

    // Verify main components are rendered
    expect(find.byType(CanvasView), findsOneWidget);
    expect(find.byType(ToolbarWidget), findsOneWidget);
    expect(find.text('Untitled Note'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNothing); // Currently selected pen has Icons.edit
    expect(find.byIcon(Icons.edit), findsNWidgets(2));
    expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_outlined), findsOneWidget);
  });
}
