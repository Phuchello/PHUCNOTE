import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// VM service and Android PSS are collected by the host driver. On-device DDS
/// service URIs can refer to forwarded host ports, so do not HTTP-call them here.
Future<Map<String, dynamic>> allocationSnapshot({
  required String phase,
  bool reset = false,
}) async {
  final isolate = developer.Service.getIsolateId(Isolate.current);
  debugPrint('INK_ALLOC_${reset ? 'RESET' : 'END'}:$phase:$isolate');
  await Future<void>.delayed(const Duration(seconds: 2));
  return {
    'status': 'HOST_REQUESTED',
    'phase': phase,
    'isolateId': isolate,
    'resultsFile': 'flutter_allocations.json',
  };
}
