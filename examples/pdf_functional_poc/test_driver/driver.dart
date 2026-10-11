import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final output = Directory('../../artifacts/pdf-functional-poc');
  await output.create(recursive: true);
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      await File('${output.path}/$name.png').writeAsBytes(bytes, flush: true);
      return bytes.isNotEmpty;
    },
    responseDataCallback: (data) async {
      final trace = Map<String, dynamic>.from(data ?? {})
        ..remove('screenshots');
      final name = data?.containsKey('SPLIT-01') == true
          ? 'acceptance-trace'
          : data?.containsKey('renderingTrace') == true
          ? 'rendering-trace'
          : data?.containsKey('INK-01') == true
          ? 'ink-trace'
          : 'test-trace';
      await File('${output.path}/$name.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(trace));
    },
  );
}
