import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdf_functional_poc/main.dart';

import 'rendering_test.dart' show ready;
import 'ink_test.dart' show stylusStroke;

Future<void> rotate(WidgetTester tester, bool portrait) async {
  await SystemChrome.setPreferredOrientations([
    portrait ? DeviceOrientation.portraitUp : DeviceOrientation.landscapeLeft,
  ]);
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    final size = tester.view.physicalSize;
    if ((size.height > size.width) == portrait) {
      await tester.pump(const Duration(milliseconds: 500));
      return;
    }
  }
  fail('Android did not change physical orientation');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Real screenshots, thumbnail navigation, split dimensions/state and physical rotations',
    (tester) async {
      await rotate(tester, false);
      await tester.pumpWidget(const PocApp());
      final reader = tester.state<PdfReaderState>(find.byType(PdfReader));
      final session = reader.session;
      await ready(tester, session);
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
      final evidence = <Map<String, Object>>[];
      Future<void> snap(String name) async {
        await tester.pump(const Duration(milliseconds: 300));
        await ready(tester, session);
        expect(tester.takeException(), isNull);
        evidence.add({
          'name': name,
          'page': session.selectedPage + 1,
          'physicalWidth': tester.view.physicalSize.width,
          'physicalHeight': tester.view.physicalSize.height,
          'scale': reader.viewport.scale,
          'offsetX': reader.viewport.offset.dx,
          'offsetY': reader.viewport.offset.dy,
          'rasterWidth': session.bitmap!.image.width,
          'rasterHeight': session.bitmap!.image.height,
          'cacheBytes': session.cacheBytes,
          'cacheEntries': session.cacheCount,
        });
        await binding.takeScreenshot(name);
      }

      Future<void> tap(String tooltip) async {
        await tester.ensureVisible(find.byTooltip(tooltip));
        await tester.tap(find.byTooltip(tooltip));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await snap('01-pdf-page-1');
      await tap('Trang cuối');
      await ready(tester, session);
      expect(session.selectedPage, 3);
      await snap('02-pdf-page-4');
      await tap('Trang đầu');
      reader.viewport.zoom(2, reader.viewport.view.center(Offset.zero));
      await snap('03-pdf-200-percent');
      expect(reader.viewport.scale, 2);
      await tap('Vừa chiều rộng');
      expect(
        reader.viewport.screenBounds.width,
        closeTo(reader.viewport.view.width - 32, .001),
      );
      await snap('04-pdf-fit-width');
      await session.select(1);
      await ready(tester, session);
      reader.viewport.fit();
      await tap('Bút viết');
      var origin = tester.getTopLeft(
        find.byKey(const ValueKey('pdf-viewport')),
      );
      final points = [
        const Offset(160, 270),
        const Offset(180, 300),
        const Offset(200, 260),
        const Offset(210, 310),
        const Offset(230, 280),
        const Offset(250, 315),
        const Offset(280, 275),
      ];
      for (var i = 1; i < points.length; i++) {
        await stylusStroke(
          tester,
          origin + reader.viewport.toScreen(points[i - 1]),
          origin + reader.viewport.toScreen(points[i]),
        );
      }
      await tap('Bút đánh dấu');
      await stylusStroke(
        tester,
        origin + reader.viewport.toScreen(const Offset(110, 164)),
        origin + reader.viewport.toScreen(const Offset(460, 164)),
      );
      expect(reader.sheet.strokes, hasLength(7));
      final ink = jsonEncode(
        reader.sheet.strokes.map((s) => s.toJson()).toList(),
      );
      await snap('05-pdf-live-ink');
      reader.viewport.zoom(
        1.5,
        reader.viewport.toScreen(const Offset(220, 280)),
      );
      reader.viewport.pan(const Offset(30, 20));
      await snap('06-same-ink-after-zoom');
      expect(
        jsonEncode(reader.sheet.strokes.map((s) => s.toJson()).toList()),
        ink,
      );
      await tap('Chọn trang thu nhỏ');
      await tester.pump(const Duration(seconds: 1));
      await snap('07-pdf-thumbnails');
      await tester.tap(find.byKey(const ValueKey('thumbnail-2')));
      await tester.pump();
      await ready(tester, session);
      expect(session.selectedPage, 2);
      expect(reader.sheet.strokes, isEmpty);
      await reader.load(1);
      await ready(tester, session);
      reader.viewport.fit();
      await snap('08-slide-page-1');
      await tap('Trang cuối');
      await snap('09-slide-page-6');
      expect(session.selectedPage, 5);
      await tap('Học song song');
      await ready(tester, session);
      expect(reader.split, isTrue);
      final dimensions = <Map<String, double>>[];
      for (final ratio in [.4, .5, .6]) {
        await tester.tap(find.byKey(ValueKey('ratio-$ratio')));
        await tester.pump();
        final left = tester
            .getSize(find.byKey(const ValueKey('document-pane')))
            .width;
        final right = tester
            .getSize(find.byKey(const ValueKey('note-pane')))
            .width;
        expect(left / (left + right), closeTo(ratio, .001));
        expect(right, greaterThanOrEqualTo(480));
        dimensions.add({'ratio': ratio, 'leftDp': left, 'rightDp': right});
      }
      await tester.tap(find.byKey(const ValueKey('ratio-0.5')));
      await tester.pump();
      final oldWidth = tester
          .getSize(find.byKey(const ValueKey('document-pane')))
          .width;
      await tester.drag(
        find.byKey(const ValueKey('split-divider')),
        const Offset(80, 0),
      );
      await tester.pump();
      expect(
        tester.getSize(find.byKey(const ValueKey('document-pane'))).width,
        greaterThan(oldWidth + 40),
      );
      await tester.tap(find.byKey(const ValueKey('ratio-0.5')));
      await tester.pump();
      origin = tester.getTopLeft(find.byKey(const ValueKey('note-viewport')));
      await stylusStroke(
        tester,
        origin + reader.noteViewport.toScreen(const Offset(160, 260)),
        origin + reader.noteViewport.toScreen(const Offset(400, 340)),
      );
      expect(reader.noteSheet.strokes, hasLength(1));
      final note = jsonEncode(reader.noteSheet.strokes.single.toJson());
      final noteOffset = reader.noteViewport.offset;
      final noteScale = reader.noteViewport.scale;
      final fingerprints = <int>{};
      for (var page = 0; page < 6; page++) {
        await session.select(page);
        await ready(tester, session);
        fingerprints.add(
          (await session.bitmap!.image.toByteData())!.buffer.asUint8List().fold(
            0,
            (s, v) => (s * 31 + v) & 0x7fffffff,
          ),
        );
        expect(reader.noteViewport.offset, noteOffset);
        expect(reader.noteViewport.scale, noteScale);
        expect(jsonEncode(reader.noteSheet.strokes.single.toJson()), note);
      }
      expect(fingerprints, hasLength(6));
      reader.viewport.zoom(
        reader.viewport.scale * 1.2,
        reader.viewport.view.center(Offset.zero),
      );
      reader.viewport.pan(const Offset(15, 20));
      expect(reader.noteViewport.offset, noteOffset);
      final pdfOffset = reader.viewport.offset;
      reader.noteViewport.pan(const Offset(20, 10));
      expect(reader.viewport.offset, pdfOffset);
      reader.noteViewport.fit();
      reader.viewport.fit();
      await snap('10-split-real-slide-and-note');
      // Independent note page navigation is available in its horizontally scrollable toolbar.
      await tap('Trang ghi chú sau');
      expect(reader.notePage, 1);
      expect(reader.noteSheet.strokes, isEmpty);
      expect(session.selectedPage, 5);
      await tap('Trang ghi chú trước');
      expect(jsonEncode(reader.noteSheet.strokes.single.toJson()), note);
      await rotate(tester, true);
      await tester.pump();
      expect(find.byKey(const ValueKey('split-divider')), findsNothing);
      await tester.tap(find.text('Ghi chú', skipOffstage: true));
      await tester.pump();
      expect(reader.portraitNotes, isTrue);
      expect(reader.noteViewport.view.width, greaterThan(700));
      expect(
        reader.noteViewport.view.width,
        tester.getSize(find.byType(Scaffold)).width,
      );
      expect(jsonEncode(reader.noteSheet.strokes.single.toJson()), note);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Tài liệu', skipOffstage: true));
      await tester.pump();
      await tap('Học song song');
      await reader.load(0);
      await ready(tester, session);
      reader.viewport.fit();
      await snap('11-portrait-reader');
      expect(
        tester.view.physicalSize.height,
        greaterThan(tester.view.physicalSize.width),
      );
      await tap('Giao diện sáng/tối');
      expect(
        Theme.of(tester.element(find.byType(PdfReader))).brightness,
        Brightness.dark,
      );
      await snap('12-dark-atelier-reader');
      binding.reportData = {
        ...?binding.reportData,
        'screenshotsMetadata': evidence,
        'splitDimensions': dimensions,
        'SPLIT-01': 'PASS',
        'SPLIT-02': 'PASS',
        'SPLIT-03': 'PASS',
        'SPLIT-04': 'PASS',
        'thumbnailSelection': 'PASS',
        'renderTrace': session.trace,
      };
      await session.close();
      expect((await session.backend.stats())['documents'], 0);
      expect(session.cacheBytes, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      await SystemChrome.setPreferredOrientations([]);
    },
  );
}
