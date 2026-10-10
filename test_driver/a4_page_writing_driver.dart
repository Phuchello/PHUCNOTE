// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    responseDataCallback: null,
    onScreenshot: (name, bytes, [args]) async {
      if (bytes.isEmpty) return false;
      final directory = Directory('artifacts/checkpoint-09');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png')
          .writeAsBytes(bytes, flush: true);
      return true;
    },
  );
}
