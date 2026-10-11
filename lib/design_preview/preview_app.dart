// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../ui/app_theme.dart';
import 'concept_a/concept_a_library_view.dart';
import 'concept_a/concept_a_editor_view.dart';
import 'concept_a/concept_a_studio_view.dart';
import 'concept_b/concept_b_library_view.dart';
import 'concept_b/concept_b_editor_view.dart';
import 'concept_b/concept_b_studio_view.dart';

enum PreviewScreen {
  conceptALibrary,
  conceptALandscapeEditor,
  conceptAPortraitEditor,
  conceptAPenStudio,
  conceptADarkEditor,
  conceptBLibrary,
  conceptBLandscapeEditor,
  conceptBPortraitEditor,
  conceptBPenStudio,
  conceptBDarkEditor,
}

class DesignPreviewApp extends StatefulWidget {
  final PreviewScreen initialScreen;

  const DesignPreviewApp({
    super.key,
    this.initialScreen = PreviewScreen.conceptALibrary,
  });

  @override
  State<DesignPreviewApp> createState() => DesignPreviewAppState();
}

class DesignPreviewAppState extends State<DesignPreviewApp> {
  late PreviewScreen _currentScreen;

  @override
  void initState() {
    super.initState();
    _currentScreen = widget.initialScreen;
  }

  void setScreen(PreviewScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _currentScreen == PreviewScreen.conceptADarkEditor ||
        _currentScreen == PreviewScreen.conceptBDarkEditor;

    Widget body;
    switch (_currentScreen) {
      case PreviewScreen.conceptALibrary:
        body = const ConceptALibraryView();
        break;
      case PreviewScreen.conceptALandscapeEditor:
        body = const ConceptAEditorView(isDark: false, isPortrait: false);
        break;
      case PreviewScreen.conceptAPortraitEditor:
        body = const ConceptAEditorView(isDark: false, isPortrait: true);
        break;
      case PreviewScreen.conceptAPenStudio:
        body = const ConceptAStudioView(isDark: false);
        break;
      case PreviewScreen.conceptADarkEditor:
        body = const ConceptAEditorView(isDark: true, isPortrait: false);
        break;

      case PreviewScreen.conceptBLibrary:
        body = const ConceptBLibraryView(isDark: false);
        break;
      case PreviewScreen.conceptBLandscapeEditor:
        body = const ConceptBEditorView(isDark: false, isPortrait: false);
        break;
      case PreviewScreen.conceptBPortraitEditor:
        body = const ConceptBEditorView(isDark: false, isPortrait: true);
        break;
      case PreviewScreen.conceptBPenStudio:
        body = const ConceptBStudioView(isDark: false);
        break;
      case PreviewScreen.conceptBDarkEditor:
        body = const ConceptBEditorView(isDark: true, isPortrait: false);
        break;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [Locale('vi', 'VN')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: academicTheme(Brightness.light),
      darkTheme: academicTheme(Brightness.dark),
      home: body,
    );
  }
}
