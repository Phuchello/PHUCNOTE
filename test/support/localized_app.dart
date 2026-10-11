import 'package:flutter/material.dart';
import 'package:phucnote/l10n/generated/app_localizations_vi.dart';
import 'package:phucnote/l10n/l10n.dart';
import 'package:phucnote/ui/app_theme.dart';

final vi = AppLocalizationsVi();
Widget localizedApp({
  required Widget home,
  ThemeMode themeMode = ThemeMode.light,
}) => MaterialApp(
  locale: const Locale('vi', 'VN'),
  supportedLocales: const [Locale('vi', 'VN')],
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: academicTheme(Brightness.light),
  darkTheme: academicTheme(Brightness.dark),
  themeMode: themeMode,
  home: home,
);
