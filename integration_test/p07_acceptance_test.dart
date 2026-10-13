import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'p02_regression_test.dart' as prior;
import '../test/p03_stylus_first_test.dart' as defaults;
import '../test/p05_navigation_test.dart' as navigation;
import '../test/p05_preference_race_test.dart' as preferences;
import '../test/p05_restore_error_test.dart' as restore;
import '../test/p05_late_preference_test.dart' as delayed;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  prior.main();
  group('P07 Acceptance Suite', () {
    group('P03 Stylus Defaults', defaults.main);
    group('P05 Navigation', navigation.main);
    group('P05 Preference Race', preferences.main);
    group('P05 Restore Error', restore.main);
    group('P05 Late Preference', delayed.main);
  });
}
