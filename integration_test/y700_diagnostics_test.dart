import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/diagnostics/stylus_diagnostics.dart';
import 'package:phucnote/main.dart';
import 'package:phucnote/ui/canvas_view.dart';
import 'package:phucnote/ui/stylus_diagnostics_panel.dart';

import '../test/support/localized_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Native diagnostic observer/export; ADB touch only', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp(
      'y700_diagnostics_',
    );
    final diagnostics = StylusDiagnostics.instance;
    addTearDown(() async {
      if (diagnostics.recording) await diagnostics.stop();
      await tester.pumpWidget(const SizedBox.shrink());
      await directory.delete(recursive: true);
    });
    await tester.pumpWidget(
      PhucNoteApp(noteStorage: NoteStorage(customRootDirectory: directory)),
    );
    await tester.pumpAndSettle();
    final controller = tester
        .widget<CanvasView>(find.byType(CanvasView))
        .controller;
    controller.setStylusOnlyMode(true);
    final revision = controller.revision;
    await binding.convertFlutterSurfaceToImage();
    Future<void> openDiagnostics() async {
      await tester.tap(find.byTooltip(vi.drawingOptions));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(vi.stylusDiagnostics));
      await tester.tap(find.text(vi.stylusDiagnostics));
      await tester.pumpAndSettle();
      expect(find.byType(StylusDiagnosticsPanel), findsOneWidget);
    }

    await openDiagnostics();
    await tester.tap(find.text(vi.diagnosticsStart));
    await tester.pumpAndSettle();
    expect(diagnostics.recording, isTrue);
    expect(find.byType(StylusDiagnosticsPanel), findsNothing);
    // Android screenshots are delivered to the host only after tests finish.
    // Signal via logcat so the host driver can inject during this live capture.
    // ignore: avoid_print
    print('Y700_NATIVE_CAPTURE_READY');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 12)),
    );
    await binding.takeScreenshot('diagnostics_ready');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await openDiagnostics();
    await tester.tap(find.text(vi.diagnosticsStop));
    await tester.pumpAndSettle();
    expect(diagnostics.recording, isFalse);
    final report = diagnostics.report!;
    final native = report['native'] as Map;
    expect(native['model'], isNotEmpty);
    expect(native['refreshHz'], greaterThan(0));
    expect(native['events'], greaterThan(1));
    expect(native['samples'], isNotEmpty);
    expect(
      (native['samples'] as List).any((s) => (s as Map)['toolType'] == 1),
      isTrue,
    );
    await binding.takeScreenshot('diagnostics_report');
    await tester.tap(find.text(vi.diagnosticsExport));
    await tester.pumpAndSettle();
    final path = (await Clipboard.getData(Clipboard.kTextPlain))!.text!;
    expect(path, contains('/stylus_diagnostics/ink_'));
    final file = File(path);
    expect(await file.exists(), isTrue);
    expect(await file.length(), greaterThan(100));
    await file.delete();
    expect(controller.document.strokes, isEmpty);
    expect(controller.revision, revision);
    expect(controller.isModified, isFalse);
    binding.reportData = {
      ...?binding.reportData,
      'phase': 'diagnostics',
      'capture': report,
      'provenance': 'ADB-injected touchscreen; not AP501U',
    };
    expect(tester.takeException(), isNull);
  });
}
