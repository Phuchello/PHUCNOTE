import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_test.dart' as app;
import 'a4_page_writing_test.dart' as a4;
import 'tablet_ui_test.dart' as tablet;
import 'pen_studio_test.dart' as pen;
import 'landscape_visual_test.dart' as landscape;
import 'portrait_visual_test.dart' as portrait;
import 'ui_premium_test.dart' as premium;

// Run the existing regressions and final visual acceptance in one APK.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Existing app regressions', app.main);
  group('A4 page-aware regressions', a4.main);
  group('Tablet and Zen regressions', tablet.main);
  group('Pen Studio regressions', pen.main);
  group('Landscape visual regressions', landscape.main);
  group('Portrait visual regressions', portrait.main);
  group('Premium Vietnamese acceptance', premium.main);
}
