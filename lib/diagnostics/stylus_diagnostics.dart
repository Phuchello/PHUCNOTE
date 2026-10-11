import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

Map<String, Object> timingDistribution(Iterable<num> values) {
  final sorted =
      values.map((v) => v.toDouble()).where((v) => v.isFinite).toList()..sort();
  if (sorted.isEmpty) return {'count': 0};
  double at(double p) => sorted[((sorted.length - 1) * p).ceil()];
  return {
    'count': sorted.length,
    'p50': at(.5),
    'p95': at(.95),
    'p99': at(.99),
    'max': sorted.last,
  };
}

/// Deltas remain separated by native input device and pointer, including history.
Map<String, Object> inputTimingSummary(List<dynamic> samples) {
  final previous = <String, num>{};
  final deltas = <String, List<num>>{};
  var simultaneous = 0;
  for (final raw in samples) {
    final sample = Map<String, dynamic>.from(raw as Map);
    final key =
        '${sample['deviceId']}:${sample['pointerId']}:${sample['toolType']}';
    final time = sample['uptimeMs'] as num;
    final isActionPointer =
        sample['pointerIndex'] == sample['actionIndex'] ||
        sample['action'] == 3;
    final action = sample['historical'] == true || !isActionPointer
        ? 2
        : sample['action'];
    if (action == 0 || action == 5) previous.remove(key);
    final last = previous[key];
    if (last != null) {
      final delta = time - last;
      if (delta > 0) (deltas[key] ??= []).add(delta);
      if (delta == 0) simultaneous++;
    }
    previous[key] = time;
    if (action == 1 || action == 3 || action == 6) previous.remove(key);
  }
  return {
    'deltaMsByDevicePointerTool': deltas.map(
      (key, value) => MapEntry(key, timingDistribution(value)),
    ),
    'sameTimestampSamples': simultaneous,
  };
}

class StylusDiagnostics with WidgetsBindingObserver {
  static final instance = StylusDiagnostics();
  static const channel = MethodChannel('phucnote/stylus_diagnostics');
  static const capacity = 10000;
  final _frames = Queue<Map<String, num>>();
  int _droppedFrames = 0;
  bool recording = false;
  Map<String, dynamic>? report;

  Map? get _nativeReport => report?['native'] as Map?;
  bool get hasCapture => _nativeReport != null;
  String get model => _nativeReport?['model']?.toString() ?? '';
  String get androidRelease =>
      _nativeReport?['androidRelease']?.toString() ?? '';
  String get refreshHz => _nativeReport?['refreshHz']?.toString() ?? '';
  String get eventCount => _nativeReport?['events']?.toString() ?? '';
  String get cancellations => _nativeReport?['cancellations']?.toString() ?? '';
  String get historyCount =>
      _nativeReport?['historicalSamples']?.toString() ?? '';
  String get droppedSamples =>
      _nativeReport?['droppedSamples']?.toString() ?? '';
  String get frameSummary => report?['totalMs']?.toString() ?? '';

  Future<void> start() async {
    if (recording) return;
    await channel.invokeMethod<Object?>('start');
    _frames.clear();
    _droppedFrames = 0;
    report = null;
    recording = true;
    SchedulerBinding.instance.addTimingsCallback(_timings);
    WidgetsBinding.instance.addObserver(this);
  }

  void _timings(List<FrameTiming> batch) {
    if (!recording) return;
    for (final f in batch) {
      if (_frames.length == capacity) {
        _frames.removeFirst();
        _droppedFrames++;
      }
      _frames.add({
        'buildMs': f.buildDuration.inMicroseconds / 1000,
        'rasterMs': f.rasterDuration.inMicroseconds / 1000,
        'totalMs': f.totalSpan.inMicroseconds / 1000,
      });
    }
  }

  Future<Map<String, dynamic>> stop() async {
    recording = false;
    SchedulerBinding.instance.removeTimingsCallback(_timings);
    WidgetsBinding.instance.removeObserver(this);
    final native = Map<String, dynamic>.from(
      (await channel.invokeMethod<Map<Object?, Object?>>('stop')) ?? {},
    );
    final rates = (native['refreshChanges'] as List? ?? [])
        .map((v) => (v as Map)['hz'] as num)
        .toSet();
    final rate = rates.length == 1 ? rates.single.toDouble() : null;
    final budget = rate != null && rate > 0 ? 1000 / rate : null;
    report = {
      'target': 'Lenovo Y700 Gen 4 / AP501U; verify model externally',
      'physicalAcceptance': 'NOT EXECUTED by software diagnostics alone',
      'native': native,
      'flutterFrames': _frames.toList(),
      'droppedFlutterFrames': _droppedFrames,
      'inputTiming': inputTimingSummary(native['samples'] as List? ?? []),
      'buildMs': timingDistribution(_frames.map((f) => f['buildMs']!)),
      'rasterMs': timingDistribution(_frames.map((f) => f['rasterMs']!)),
      'totalMs': timingDistribution(_frames.map((f) => f['totalMs']!)),
      'singleRefreshBudgetMs': budget,
      'framesOverBuildOrRasterBudget': budget == null
          ? null
          : _frames
                .where((f) => f['buildMs']! > budget || f['rasterMs']! > budget)
                .length,
    };
    return report!;
  }

  Future<File> export() async {
    if (recording || report == null) await stop();
    final directory = Directory(
      '${(await getApplicationSupportDirectory()).path}/stylus_diagnostics',
    );
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}/ink_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    return file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
      flush: true,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (recording &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached)) {
      unawaited(
        stop().catchError((Object error) {
          report = {'error': error.toString()};
          return report!;
        }),
      );
    }
  }
}
