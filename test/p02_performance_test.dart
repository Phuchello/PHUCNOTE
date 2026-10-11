import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/ink_benchmark/p02_measurements.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'P02 matched dense cache measurements',
    () async {
      final result = p02DensityBenchmark();
      final directory = Directory('artifacts/p02-ink-hardening')
        ..createSync(recursive: true);
      await File('${directory.path}/cache-desktop.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(result));
      final runs = result['runs'] as List<Map<String, Object>>;
      expect(runs, hasLength(108));
      for (final run in runs) {
        final cache = run['cache'] as Map<String, int>;
        expect(cache['entries'], lessThanOrEqualTo(128));
        expect(cache['points'], lessThanOrEqualTo(20000));
      }
    },
    skip: !const bool.fromEnvironment('P02_MEASURE'),
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
