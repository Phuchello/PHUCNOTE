// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async => integrationDriver(
  responseDataCallback: null,
  onScreenshot: (name, bytes, [args]) async {
    if (bytes.isEmpty) return false;
    final directory = Directory('artifacts/visual-redesign-v2');
    await directory.create(recursive: true);
    final file = File('${directory.path}/$name.png');
    await file.writeAsBytes(bytes, flush: true);
    stdout.writeln('Saved screenshot: ${file.path} (${bytes.length} bytes)');
    return true;
  },
);
