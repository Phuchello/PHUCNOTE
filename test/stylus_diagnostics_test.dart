import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/diagnostics/stylus_diagnostics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Percentiles never invent values for an empty capture', () {
    expect(timingDistribution([]), {'count': 0});
    expect(timingDistribution([1, 2, 3, 4, 5])['p95'], 5);
  });
  test('Historical and interleaved pointers stay separate; new strokes reset timing', () {
    Map<String, Object> sample(
      int device,
      int pointer,
      int tool,
      int time,
      int action, {
      bool history = false,
      int index = 0,
      int actionIndex = 0,
    }) => {
      'deviceId': device,
      'pointerId': pointer,
      'toolType': tool,
      'uptimeMs': time,
      'action': action,
      'historical': history,
      'pointerIndex': index,
      'actionIndex': actionIndex,
    };
    final summary = inputTimingSummary([
      sample(1, 10, 2, 100, 0),
      sample(1, 20, 1, 101, 0),
      sample(1, 10, 2, 104, 2, history: true),
      sample(1, 20, 1, 109, 2),
      sample(1, 10, 2, 108, 2),
      sample(1, 10, 2, 108, 1),
      sample(1, 10, 2, 200, 0),
      sample(1, 10, 2, 204, 2),
    ]);
    final groups = summary['deltaMsByDevicePointerTool'] as Map;
    expect((groups['1:10:2'] as Map)['p50'], 4);
    expect((groups['1:10:2'] as Map)['count'], 3);
    expect((groups['1:20:1'] as Map)['p50'], 8);
    expect(summary['sameTimestampSamples'], 1);
  });
  test('Channel capture reports observed refresh budget and persists no document metadata', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(StylusDiagnostics.channel, (call) async {
          calls.add(call.method);
          return {
            'model': 'test model',
            'refreshChanges': [
              {'hz': 90.0},
            ],
            'samples': [],
          };
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(StylusDiagnostics.channel, null),
    );
    final diagnostics = StylusDiagnostics();
    await diagnostics.start();
    expect(diagnostics.recording, isTrue);
    final report = await diagnostics.stop();
    expect(diagnostics.recording, isFalse);
    expect(report['singleRefreshBudgetMs'], closeTo(1000 / 90, 0.001));
    expect(report['buildMs'], {'count': 0});
    expect(report['physicalAcceptance'], contains('NOT EXECUTED'));
    expect(calls, ['start', 'stop']);
  });
}
