import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdf_functional_poc/main.dart';
import 'package:pdf_functional_poc/pdf_session.dart';

Future<void> ready(WidgetTester tester, PdfSession session) async {
  for (var i = 0; i < 600; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (session.error != null) fail(session.error!);
    if (!session.opening &&
        !session.rendering &&
        session.bitmap != null &&
        session.displayedPage == session.selectedPage) {
      return;
    }
  }
  fail('Native PDF render did not settle');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'PDF-01..10/LIFE-01: real bytes, all pages, transforms, races, corrupt and close',
    (tester) async {
      await tester.pumpWidget(const PocApp());
      final reader = tester.state<PdfReaderState>(find.byType(PdfReader));
      final session = reader.session;
      await ready(tester, session);
      expect(session.pages, hasLength(4));
      expect(session.pages.first.aspectRatio, closeTo(595 / 841, .002));
      final fingerprints = <int>[];
      for (var page = 0; page < 4; page++) {
        await session.select(page);
        await ready(tester, session);
        final pixels = (await session.bitmap!.image.toByteData())!;
        final data = pixels.buffer.asUint8List();
        expect(data.any((v) => v < 200), isTrue);
        fingerprints.add(
          data.fold(0, (sum, value) => (sum * 31 + value) & 0x7fffffff),
        );
        expect(session.displayedPage, page);
      }
      expect(fingerprints.toSet(), hasLength(4));
      final fit = reader.viewport.scale;
      reader.viewport.fit(width: true);
      expect(reader.viewport.scale, greaterThan(fit));
      reader.viewport.zoom(2, reader.viewport.view.center(Offset.zero));
      reader.viewport.pan(const Offset(-75, 60));
      await tester.pump(const Duration(milliseconds: 300));
      await ready(tester, session);
      expect(reader.viewport.scale, 2);
      final beforePan = reader.viewport.offset;
      final surface = find.byKey(const ValueKey('pdf-viewport'));
      await tester.drag(surface, const Offset(60, 40));
      await tester.pump();
      expect((reader.viewport.offset - beforePan).distance, greaterThan(30));
      final beforePinch = reader.viewport.scale;
      final center = tester.getCenter(surface);
      final left = await tester.startGesture(
        center - const Offset(40, 0),
        pointer: 41,
      );
      final right = await tester.startGesture(
        center + const Offset(40, 0),
        pointer: 42,
      );
      await left.moveTo(center - const Offset(90, 0));
      await tester.pump();
      await right.moveTo(center + const Offset(90, 0));
      await tester.pump();
      await left.up();
      await right.up();
      expect(reader.viewport.scale, greaterThan(beforePinch));
      await tester.pump(const Duration(milliseconds: 300));
      await ready(tester, session);
      expect(session.cacheBytes, lessThanOrEqualTo(PdfSession.cacheBudget));
      expect(session.cacheCount, lessThanOrEqualTo(2));
      final rapid = [
        session.select(0),
        session.select(1),
        session.select(2),
        session.select(3),
        session.select(1),
      ];
      await Future.wait(rapid);
      await ready(tester, session);
      expect(session.selectedPage, 1);
      expect(session.displayedPage, 1);
      await reader.load(1);
      await ready(tester, session);
      expect(session.pages, hasLength(6));
      expect(session.pages.first.aspectRatio, closeTo(16 / 9, .001));
      final slides = <int>{};
      for (var page = 0; page < 6; page++) {
        await session.select(page);
        await ready(tester, session);
        final data = (await session.bitmap!.image.toByteData())!.buffer
            .asUint8List();
        slides.add(
          data.fold(0, (sum, value) => (sum * 31 + value) & 0x7fffffff),
        );
      }
      expect(slides, hasLength(6));
      await reader.load(2);
      await ready(tester, session);
      expect(session.pages, hasLength(1));
      expect(session.bitmap!.image.width, greaterThan(128));
      await session.openBytes(Uint8List.fromList(utf8.encode('not a PDF')));
      await tester.pump();
      expect(session.error, contains('Không thể mở PDF'));
      expect((await session.backend.stats())['documents'], 0);
      for (var i = 0; i < 3; i++) {
        await reader.load(0);
        await ready(tester, session);
        await session.close();
        expect(session.cacheBytes, 0);
        expect((await session.backend.stats())['documents'], 0);
      }
      binding.reportData = {
        ...?binding.reportData,
        'renderingTrace': session.trace,
      };
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
