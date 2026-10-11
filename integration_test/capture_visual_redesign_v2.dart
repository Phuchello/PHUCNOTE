// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:phucnote/design_preview/concept_a/concept_a_library_view.dart';
import 'package:phucnote/design_preview/concept_a/concept_a_editor_view.dart';
import 'package:phucnote/design_preview/concept_a/concept_a_studio_view.dart';
import 'package:phucnote/design_preview/concept_b/concept_b_library_view.dart';
import 'package:phucnote/design_preview/concept_b/concept_b_editor_view.dart';
import 'package:phucnote/design_preview/concept_b/concept_b_studio_view.dart';
import 'package:phucnote/l10n/l10n.dart';
import 'package:phucnote/ui/app_theme.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapView(Widget child, {bool isDark = false}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [Locale('vi', 'VN')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: academicTheme(Brightness.light),
      darkTheme: academicTheme(Brightness.dark),
      home: child,
    );
  }

  Future<void> capture(WidgetTester tester, String filename) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    final bytes = await binding.takeScreenshot(filename);
    try {
      final file = File('/data/user/0/com.phucnote.phucnote/files/$filename.png');
      await file.writeAsBytes(bytes);
    } catch (_) {}
  }

  Future<void> ensureOrientation(WidgetTester tester, bool landscape) async {
    await SystemChrome.setPreferredOrientations([
      landscape ? DeviceOrientation.landscapeLeft : DeviceOrientation.portraitUp,
    ]);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      final isLand = tester.view.physicalSize.width > tester.view.physicalSize.height;
      if (isLand == landscape) break;
    }
    await tester.pumpAndSettle();
  }

  group('Concept A Prototypes', () {
    testWidgets('Capture Concept A Library', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptALibraryView()));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_library');
    });

    testWidgets('Capture Concept A Landscape Editor', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptAEditorView(isDark: false, isPortrait: false)));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_landscape_editor');
    });

    testWidgets('Capture Concept A Pen Studio', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptAStudioView(isDark: false)));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_pen_studio');
    });

    testWidgets('Capture Concept A Dark Editor', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptAEditorView(isDark: true, isPortrait: false), isDark: true));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_dark_editor');
    });

    testWidgets('Capture Concept A Portrait Editor', (tester) async {
      await ensureOrientation(tester, false);
      await tester.pumpWidget(wrapView(const ConceptAEditorView(isDark: false, isPortrait: true)));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_portrait_editor');
      await SystemChrome.setPreferredOrientations([]);
    });
  });

  group('Concept B Prototypes', () {
    testWidgets('Capture Concept B Library', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptBLibraryView(isDark: false)));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_b_library');
    });

    testWidgets('Capture Concept B Landscape Editor', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptBEditorView(isDark: false, isPortrait: false)));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_b_landscape_editor');
    });

    testWidgets('Capture Concept B Pen Studio', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptBStudioView(isDark: false)));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_b_pen_studio');
    });

    testWidgets('Capture Concept B Dark Editor', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptBEditorView(isDark: true, isPortrait: false), isDark: true));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_b_dark_editor');
    });

    testWidgets('Capture Concept B Portrait Editor', (tester) async {
      await ensureOrientation(tester, false);
      await tester.pumpWidget(wrapView(const ConceptBEditorView(isDark: false, isPortrait: true)));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_b_portrait_editor');
      await SystemChrome.setPreferredOrientations([]);
    });
  });
}
