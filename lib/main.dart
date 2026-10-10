// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/storage/note_storage.dart';
import 'ui/home_screen.dart';

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

  const PhucNoteApp({
    super.key,
    required this.noteStorage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PHUCNOTE',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
          surface: const Color(0xFFFBFBF9), // Warm Paper Ivory
        ),
        scaffoldBackgroundColor: const Color(0xFFFBFBF9),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFFF5F5F0),
          foregroundColor: Color(0xFF1E1E1E),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF90CAF9),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
      home: HomeScreen(noteStorage: noteStorage),
    );
  }
}
