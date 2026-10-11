import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> collectAllocations(Directory directory) async {
  const adb = 'scratch/toolchain/android-sdk/platform-tools/adb.exe';
  final records = <Map<String, Object?>>[];
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  Process? logcat;
  try {
    final supplied = Platform.environment['VM_SERVICE_URL'];
    if (supplied == null) throw StateError('No host VM_SERVICE_URL');
    final service = Uri.parse(supplied);
    final base = service.replace(
      scheme: 'http',
      path: service.path.replaceFirst(RegExp(r'/ws$'), '/'),
    );
    Future<Map<String, dynamic>> rpc(
      String method,
      Map<String, String> parameters,
    ) async {
      final request = await client.getUrl(
        base.resolve(method).replace(queryParameters: parameters),
      );
      final response = await request.close();
      return jsonDecode(await utf8.decoder.bind(response).join())
          as Map<String, dynamic>;
    }

    logcat = await Process.start(adb, [
      '-s',
      'emulator-5554',
      'logcat',
      '-v',
      'brief',
      '-T',
      '1',
      'flutter:I',
      '*:S',
    ]);
    await for (final line
        in logcat.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      final match = RegExp(r'INK_ALLOC_(RESET|END):([^:]+):(isolates/\d+)')
          .firstMatch(line);
      if (match == null) continue;
      final reset = match[1] == 'RESET';
      final phase = match[2]!;
      final decoded = await rpc('getAllocationProfile', {
        'isolateId': match[3]!,
        'reset': '$reset',
      });
      final profile = decoded['result'] as Map<String, dynamic>?;
      final memory = await rpc('getMemoryUsage', {'isolateId': match[3]!});
      records.add({
        'phase': phase,
        'reset': reset,
        'status': profile == null ? 'UNAVAILABLE' : 'MEASURED_HEAP',
        'allocationStatus': (profile?['members'] as List?)?.isNotEmpty == true
            ? 'CLASS_STATS_RETURNED_SEE_SELECTION'
            : 'UNAVAILABLE_IN_THIS_MODE',
        'profileClassCount': (profile?['members'] as List?)?.length,
        'error': decoded['error'],
        'memoryUsage': memory,
        'dateLastAccumulatorReset': profile?['dateLastAccumulatorReset'],
        'classes': profile == null
            ? null
            : [
                for (final m in profile['members'] as List)
                  if ([
                    'PointVector',
                    'StrokePoint',
                    '_Path',
                    '_List',
                    '_GrowableList',
                  ].contains(m['class']['name']))
                    {
                      'name': m['class']['name'],
                      'instancesAccumulated': m['instancesAccumulated'],
                      'bytesAccumulated': m['bytesAccumulated'],
                      'instancesCurrent': m['instancesCurrent'],
                      'bytesCurrent': m['bytesCurrent'],
                    },
              ],
      });
      if (!reset) {
        final processMemory = await Process.run(adb, [
          '-s',
          'emulator-5554',
          'shell',
          'dumpsys',
          'meminfo',
          'com.phucnote.phucnote',
        ]);
        await File('${directory.path}/flutter_memory_$phase.txt')
            .writeAsString('${processMemory.stdout}\n${processMemory.stderr}');
      }
      if (!reset && phase == 'a2_repaint') break;
    }
  } catch (error) {
    records.add({'status': 'UNAVAILABLE', 'reason': error.toString()});
  } finally {
    logcat?.kill();
    client.close(force: true);
    await File('${directory.path}/flutter_allocations.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'captures': records,
        'limits': 'Dart counters and Android process snapshots; harness included; native/GPU outside Dart counters',
      }),
    );
  }
}

Future<void> main() async {
  final directory = Directory('artifacts/ink-engine')
    ..createSync(recursive: true);
  final allocations = collectAllocations(directory)
      .timeout(const Duration(minutes: 8));
  await integrationDriver(
    writeResponseOnFailure: true,
    responseDataCallback: (data) async {
      if (data == null) return;
      await allocations;
      await File('${directory.path}/flutter_profile.json').writeAsString(
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
