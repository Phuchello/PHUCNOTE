// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/storage/note_storage.dart';
import 'ui/home_screen.dart';
import 'ui/app_theme.dart';
import 'l10n/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tablet system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final noteStorage = NoteStorage();
  runApp(PhucNoteApp(noteStorage: noteStorage));
}

class PhucNoteApp extends StatelessWidget {
  final NoteStorage noteStorage;
  final ThemeMode themeMode;

  const PhucNoteApp({
    super.key,
    required this.noteStorage,
    this.themeMode = ThemeMode.system,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appName,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [Locale('vi', 'VN')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: academicTheme(Brightness.light),
      darkTheme: academicTheme(Brightness.dark),
      home: HomeScreen(noteStorage: noteStorage),
    );
  }
}
