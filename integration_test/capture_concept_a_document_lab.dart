// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:phucnote/design_preview/document_lab/concept_a_document_reader_view.dart';
import 'package:phucnote/design_preview/document_lab/concept_a_library_extended_view.dart';
import 'package:phucnote/design_preview/document_lab/concept_a_split_study_view.dart';
import 'package:phucnote/design_preview/document_lab/document_lab_models.dart';
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

  group('Landscape Views', () {
    testWidgets('01. Capture Concept A Library with mixed files', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptALibraryExtendedView(isDark: false)));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_library_mixed');
    });

    testWidgets('02. Capture PDF reader landscape', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[0],
        isPortrait: false,
        isDark: false,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_pdf_reader_landscape');
    });

    testWidgets('04. Capture Annotated PDF', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[0],
        isPortrait: false,
        isDark: false,
        isAnnotated: true,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_pdf_annotated');
    });

    testWidgets('05. Capture PDF page thumbnails', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[0],
        isPortrait: false,
        isDark: false,
        showThumbnails: true,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_pdf_thumbnails');
    });

    testWidgets('06. Capture Lecture slide landscape', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[1],
        isPortrait: false,
        isDark: false,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_slide_landscape');
    });

    testWidgets('08. Capture Annotated lecture slide', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[1],
        isPortrait: false,
        isDark: false,
        isAnnotated: true,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_slide_annotated');
    });

    testWidgets('09. Capture Slide + handwriting split workspace', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptASplitStudyView(
        isSlide: true,
        isDark: false,
        initialSplitRatio: 0.46,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_split_slide_study');
    });

    testWidgets('10. Capture PDF + handwriting split workspace', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(const ConceptASplitStudyView(
        isSlide: false,
        isDark: false,
        initialSplitRatio: 0.48,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_split_pdf_study');
    });

    testWidgets('11. Capture Dark-theme document reader', (tester) async {
      await ensureOrientation(tester, true);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[0],
        isPortrait: false,
        isDark: true,
        isAnnotated: true,
      ), isDark: true));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_doc_reader_dark');
    });
  });

  group('Portrait and Compact Views', () {
    testWidgets('03. Capture PDF reader portrait', (tester) async {
      await ensureOrientation(tester, false);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[0],
        isPortrait: true,
        isDark: false,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_pdf_reader_portrait');
    });

    testWidgets('07. Capture Lecture slide portrait', (tester) async {
      await ensureOrientation(tester, false);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[1],
        isPortrait: true,
        isDark: false,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_slide_portrait');
    });

    testWidgets('12. Capture Compact-tablet narrow viewport', (tester) async {
      await ensureOrientation(tester, false);
      await tester.pumpWidget(wrapView(ConceptADocumentReaderView(
        document: LabDocument.sampleDocuments[1],
        isPortrait: true,
        isDark: false,
        isCompact: true,
      )));
      await tester.pumpAndSettle();
      await capture(tester, 'concept_a_compact_narrow');
      await SystemChrome.setPreferredOrientations([]);
    });
  });
}
