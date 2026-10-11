import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdf_functional_poc/main.dart';

import 'rendering_test.dart' show ready;

Future<void> stylusStroke(WidgetTester tester, Offset start, Offset end) async {
  final gesture = await tester.startGesture(
    start,
    kind: PointerDeviceKind.stylus,
  );
  for (var i = 1; i <= 12; i++) {
    await gesture.moveTo(Offset.lerp(start, end, i / 12)!);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pump();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'INK-01..05: dispatched stylus, inverse transform, page isolation, PDF readonly, exact history',
    (tester) async {
      await tester.pumpWidget(const PocApp());
      final reader = tester.state<PdfReaderState>(find.byType(PdfReader));
      await ready(tester, reader.session);
      await reader.session.select(1);
      await ready(tester, reader.session);
      await tester.tap(find.byTooltip('Bút viết'));
      await tester.pump();
      final origin = tester.getTopLeft(
        find.byKey(const ValueKey('pdf-viewport')),
      );
      final start = reader.viewport.toScreen(const Offset(180, 280));
      final end = reader.viewport.toScreen(const Offset(420, 320));
      await stylusStroke(tester, origin + start, origin + end);
      expect(reader.sheet.strokes, hasLength(1));
      expect(reader.sheet.strokes.single.points.first.x, closeTo(180, .001));
      final exact = jsonEncode(reader.sheet.strokes.single.toJson());
      final sheet = reader.sheet;
      reader.viewport.zoom(2, reader.viewport.toScreen(const Offset(300, 300)));
      reader.viewport.pan(const Offset(-40, 30));
      await tester.pump(const Duration(milliseconds: 300));
      await ready(tester, reader.session);
      expect(jsonEncode(sheet.strokes.single.toJson()), exact);
      expect(
        reader.viewport.toDocument(
          reader.viewport.toScreen(const Offset(180, 280)),
        ),
        const Offset(180, 280),
      );
      await reader.session.select(2);
      await ready(tester, reader.session);
      expect(reader.sheet.strokes, isEmpty);
      await reader.session.select(1);
      await ready(tester, reader.session);
      expect(identical(reader.sheet, sheet), isTrue);
      final before = (await reader.session.bitmap!.image.toByteData())!.buffer
          .asUint8List();
      await tester.tap(find.byTooltip('Tẩy nét mực'));
      await tester.pump();
      final erasePoint =
          origin + reader.viewport.toScreen(const Offset(300, 300));
      final eraser = await tester.startGesture(
        erasePoint,
        kind: PointerDeviceKind.stylus,
      );
      await eraser.cancel();
      await tester.pump();
      expect(sheet.strokes, isEmpty);
      expect(
        (await reader.session.bitmap!.image.toByteData())!.buffer.asUint8List(),
        before,
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byTooltip('Hoàn tác mực'));
        await tester.pump();
        expect(jsonEncode(sheet.strokes.single.toJson()), exact);
        await tester.tap(find.byTooltip('Làm lại mực'));
        await tester.pump();
        expect(sheet.strokes, isEmpty);
      }
      await tester.tap(find.byTooltip('Bút viết'));
      await tester.pump();
      final active = await tester.startGesture(
        origin + reader.viewport.toScreen(const Offset(300, 300)),
        kind: PointerDeviceKind.stylus,
      );
      await active.moveBy(const Offset(20, 10));
      await tester.pump();
      expect(sheet.active, isTrue);
      await reader.session.select(2);
      await ready(tester, reader.session);
      await active.cancel();
      expect(sheet.strokes, hasLength(1));
      expect(sheet.active, isFalse);
      expect(reader.sheet.strokes, isEmpty);
      binding.reportData = {
        ...?binding.reportData,
        'INK-01': 'PASS (Flutter stylus events; no physical stylus)',
        'INK-02': 'PASS',
        'INK-03': 'PASS',
        'INK-04': 'PASS',
        'INK-05': 'PASS',
      };
      expect(tester.takeException(), isNull);
      final closing = await tester.startGesture(
        origin + reader.viewport.toScreen(const Offset(300, 300)),
        kind: PointerDeviceKind.stylus,
      );
      await closing.moveBy(const Offset(10, 10));
      await tester.pump();
      expect(reader.sheet.active, isTrue);
      await reader.session.close();
      await tester.pumpWidget(const SizedBox.shrink());
      await closing.cancel();
      expect(tester.takeException(), isNull);
    },
  );
}
