import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'localized_app.dart';

Future<void> stylusTap(WidgetTester tester, Finder finder) async {
  final gesture = await tester.startGesture(
    tester.getCenter(finder, warnIfMissed: false),
    kind: PointerDeviceKind.stylus,
  );
  await gesture.up();
}

Future<void> openDrawingOptions(WidgetTester tester) async {
  await stylusTap(tester, find.byTooltip(vi.drawingOptions));
  await tester.pumpAndSettle();
}

Future<void> tapDrawingOption(WidgetTester tester, String tooltip) async {
  await openDrawingOptions(tester);
  await tester.ensureVisible(find.byTooltip(tooltip));
  await stylusTap(tester, find.byTooltip(tooltip));
  await tester.pumpAndSettle();
}
