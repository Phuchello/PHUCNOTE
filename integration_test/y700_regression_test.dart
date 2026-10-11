import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'ui_premium_regression_test.dart' as existing;
import 'y700_diagnostics_test.dart' as diagnostics;
import '../test/y700_touch_cancel_test.dart' as cancellation;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  existing.main();
  group('Y700 diagnostic observer smoke test', diagnostics.main);
  group(
    'Touch cancellation regression (synthetic pointers)',
    cancellation.main,
  );
}
