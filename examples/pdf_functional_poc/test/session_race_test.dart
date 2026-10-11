import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_functional_poc/pdf_session.dart';

class DeferredBackend extends PdfBackend {
  final Uint8List png;
  DeferredBackend(this.png);
  int nextId = 0, calls = 0;
  final handles = <int>{};
  final firstRender = Completer<Map<dynamic, dynamic>>();
  @override
  Future<Map<dynamic, dynamic>> open(Uint8List bytes) async {
    final id = ++nextId;
    handles.add(id);
    return {
      'id': id,
      'pages': [
        {'width': 595, 'height': 841},
        {'width': 595, 'height': 841},
      ],
    };
  }

  Map<dynamic, dynamic> response(int page) => {
    'bytes': png,
    'page': page,
    'renderMs': 1.0,
  };
  @override
  Future<Map<dynamic, dynamic>> render(int id, int page, int width) async {
    if (++calls == 1) return firstRender.future;
    return response(page);
  }

  @override
  Future<void> close(int id) async {
    handles.remove(id);
  }
}

Future<Uint8List> pixel() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xff18324b), ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(1, 1);
  picture.dispose();
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer
      .asUint8List();
  image.dispose();
  return bytes;
}

Future<void> until(bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('PDF-08: pending render coalesces navigation to latest page', () async {
    final backend = DeferredBackend(await pixel());
    final session = PdfSession(backend: backend);
    final opening = session.openBytes(Uint8List(1));
    await until(() => backend.calls == 1);
    final requests = [session.select(1), session.select(0), session.select(1)];
    backend.firstRender.complete(backend.response(0));
    await opening;
    await Future.wait(requests);
    expect(session.displayedPage, 1);
    expect(backend.calls, 2);
    expect(session.error, isNull);
    await session.close();
    expect(backend.handles, isEmpty);
    session.dispose();
  });
  test('Old render failure cannot poison a newer opened document', () async {
    final backend = DeferredBackend(await pixel());
    final session = PdfSession(backend: backend);
    final old = session.openBytes(Uint8List(1));
    await until(() => backend.calls == 1);
    final newer = session.openBytes(Uint8List(2));
    await until(() => backend.nextId == 2);
    backend.firstRender.completeError(StateError('old renderer closed'));
    await old;
    await newer;
    expect(session.error, isNull);
    expect(session.displayedPage, 0);
    expect(session.documentId, 2);
    await session.close();
    expect(backend.handles, isEmpty);
    session.dispose();
  });
  test(
    'Missing asset returns Vietnamese error and releases current document',
    () async {
      final backend = DeferredBackend(await pixel());
      backend.firstRender.complete(backend.response(0));
      final session = PdfSession(backend: backend);
      await session.openBytes(Uint8List(1));
      await session.openAsset('assets/missing.pdf');
      expect(session.error, contains('Không thể mở PDF'));
      expect(session.pages, isEmpty);
      expect(backend.handles, isEmpty);
      session.dispose();
    },
  );
}
