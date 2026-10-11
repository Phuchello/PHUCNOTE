import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

import 'y700_ink_driver.dart' show injectNativeCapture;

Future<void> main() async {
  final directory = Directory('artifacts/ink-engine/regression')
    ..createSync(recursive: true);
  final capture = injectNativeCapture(directory);
  await integrationDriver(
    writeResponseOnFailure: true,
    responseDataCallback: (data) async {
      await capture;
      if (data == null) return;
      await File('${directory.path}/regression.json').writeAsString(
        const JsonEncoder.withIndent('  ')
            .convert({...data}..remove('screenshots')),
      );
    },
    onScreenshot: (name, bytes, [args]) async {
      await File('${directory.path}/$name.png').writeAsBytes(bytes);
      return bytes.isNotEmpty;
    },
  );
}
