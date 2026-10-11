import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'y700_regression_test.dart' as existing;
import '../test/p02_input_correctness_test.dart' as input;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  existing.main();
  group('P02 owned input and final UP regressions (synthetic)', input.main);
}
