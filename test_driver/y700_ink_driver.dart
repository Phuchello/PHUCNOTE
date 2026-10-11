import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> injectNativeCapture(Directory directory) async {
  const adb = 'scratch/toolchain/android-sdk/platform-tools/adb.exe';
  final device =
      Platform.environment['PHUCNOTE_TEST_DEVICE'] ?? 'emulator-5554';
  Future<ProcessResult> command(List<String> args) =>
      Process.run(adb, ['-s', device, ...args]);
  final logcat = await Process.start(adb, [
    '-s',
    device,
    'logcat',
    '-v',
    'brief',
    '-T',
    '1',
    'flutter:I',
    '*:S',
  ]);
  try {
    await logcat.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .firstWhere((line) => line.contains('Y700_NATIVE_CAPTURE_READY'))
        .timeout(const Duration(minutes: 8));
    final remote =
        '/data/misc/perfetto-traces/phucnote_ink_${DateTime.now().millisecondsSinceEpoch}.pftrace';
    final trace = command([
      'shell',
      'perfetto',
      '-o',
      remote,
      '-t',
      '6s',
      'sched',
      'gfx',
      'view',
      'input',
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final input = await command([
      'shell',
      'input',
      'touchscreen',
      'swipe',
      '500',
      '600',
      '1000',
      '900',
      '500',
    ]);
    if (input.exitCode != 0) {
      throw StateError('ADB injection failed: ${input.stderr}');
    }
    final captured = await trace;
    await File('${directory.path}/android-trace-command.txt').writeAsString(
      'No-root Perfetto, 6s sched/gfx/view/input; ADB touchscreen injection\nexit=${captured.exitCode}\n${captured.stdout}\n${captured.stderr}',
    );
    if (captured.exitCode != 0) {
      throw StateError('Perfetto failed: ${captured.stderr}');
    }
    final pulled = await command([
      'pull',
      remote,
      '${directory.path}/android_diagnostics.pftrace',
    ]);
    if (pulled.exitCode != 0) {
      throw StateError('Trace pull failed: ${pulled.stderr}');
    }
  } finally {
    logcat.kill();
  }
}

Future<void> main() async {
  final directory = Directory('artifacts/y700-gen4-ink');
  await directory.create(recursive: true);
  Object? injectionError;
  final injection = Platform.environment['PHUCNOTE_NATIVE_CAPTURE'] == '1'
      ? injectNativeCapture(directory).catchError((Object error) {
          injectionError = error;
        })
      : null;
  await integrationDriver(
    writeResponseOnFailure: true,
    responseDataCallback: (data) async {
      if (data == null) return;
      if (injection != null) {
        await injection;
      }
      if (injectionError != null) {
        throw StateError('Native capture failed: $injectionError');
      }
      final phase = data['phase'] ?? 'regression';
      await File('${directory.path}/$phase.json').writeAsString(
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
