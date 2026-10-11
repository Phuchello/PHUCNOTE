import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PdfBackend {
  final MethodChannel channel;
  const PdfBackend({this.channel = const MethodChannel('phucnote_pdf_poc')});
  Future<Map<dynamic, dynamic>> open(Uint8List bytes) async =>
      (await channel.invokeMapMethod('open', {'bytes': bytes}))!;
  Future<Map<dynamic, dynamic>> render(int id, int page, int width) async =>
      (await channel.invokeMapMethod('render', {
        'id': id,
        'page': page,
        'width': width,
      }))!;
  Future<void> close(int id) => channel.invokeMethod('close', {'id': id});
  Future<Map<dynamic, dynamic>> stats() async =>
      (await channel.invokeMapMethod('stats'))!;
}

class PageBitmap {
  final int page;
  final ui.Image image;
  final double renderMs;
  PageBitmap(this.page, this.image, this.renderMs);
  int get bytes => image.width * image.height * 4;
}

/// Latest requested page wins; only one native request/decode runs at a time.
/// No entire-document bitmap preload. Metadata alone is read at open.
class PdfSession extends ChangeNotifier {
  final PdfBackend backend;
  PdfSession({this.backend = const PdfBackend()});
  List<ui.Size> pages = [];
  int selectedPage = 0;
  int? displayedPage;
  String? error;
  bool opening = false;
  bool rendering = false;
  double openMs = 0;
  final List<Map<String, Object>> trace = [];
  final _cache = <String, PageBitmap>{};
  int? _id;
  int _epoch = 0;
  int _request = 0;
  int _completedRequest = -1;
  int _width = 1000;
  bool _disposed = false;
  Future<void>? _draining;
  PageBitmap? bitmap;
  static const cacheBudget = 24 * 1024 * 1024;
  int get cacheBytes => _cache.values.fold(0, (sum, page) => sum + page.bytes);
  int get cacheCount => _cache.length;
  int? get documentId => _id;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void _clearCache() {
    bitmap = null;
    displayedPage = null;
    for (final entry in _cache.values) {
      entry.image.dispose();
    }
    _cache.clear();
  }

  Future<void> openBytes(Uint8List bytes) => _open(Future.value(bytes));

  Future<void> _open(Future<Uint8List> source) async {
    final epoch = ++_epoch;
    ++_request;
    final old = _id;
    _id = null;
    pages = [];
    selectedPage = 0;
    error = null;
    opening = true;
    _clearCache();
    _emit();
    final watch = Stopwatch()..start();
    try {
      final values = await Future.wait<Object?>([
        source,
        if (old != null) backend.close(old),
      ]);
      final bytes = values.first as Uint8List;
      if (epoch != _epoch || _disposed) return;
      final response = await backend.open(bytes);
      final id = response['id'] as int;
      if (epoch != _epoch || _disposed) {
        await backend.close(id);
        return;
      }
      _id = id;
      pages = (response['pages'] as List)
          .map(
            (dynamic p) => ui.Size(
              (p['width'] as num).toDouble(),
              (p['height'] as num).toDouble(),
            ),
          )
          .toList();
      openMs = watch.elapsedMicroseconds / 1000;
      trace.add({'event': 'open', 'ms': openMs, 'pages': pages.length});
      opening = false;
      _emit();
      await select(0);
    } catch (_) {
      if (epoch != _epoch || _disposed) return;
      opening = false;
      error = 'Không thể mở PDF. Tệp có thể bị hỏng hoặc không được hỗ trợ.';
      _emit();
    }
  }

  Future<void> openAsset(String path) => _open(() async {
    // Also capture synchronous asset-loader errors before the open transaction.
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }());

  Future<void> select(int page, {int? width}) {
    if (_id == null || page < 0 || page >= pages.length || _disposed) {
      return Future.value();
    }
    selectedPage = page;
    _width = (width ?? _width).clamp(128, 2304);
    ++_request;
    error = null;
    // Never show a previous page beneath a new counter or annotation layer.
    if (displayedPage != page) {
      bitmap = null;
      displayedPage = null;
    }
    _emit();
    return _ensureDrain();
  }

  Future<void> _ensureDrain() async {
    if (_draining != null) {
      await _draining;
      if (!_disposed && _id != null && _completedRequest != _request) {
        await _ensureDrain();
      }
      return;
    }
    final future = _drain();
    _draining = future;
    try {
      await future;
    } finally {
      if (identical(_draining, future)) _draining = null;
    }
    if (!_disposed && _id != null && _completedRequest != _request) {
      await _ensureDrain();
    }
  }

  Future<void> _drain() async {
    rendering = true;
    _emit();
    var completed = -1;
    try {
      while (!_disposed && _id != null && completed != _request) {
        final request = _request;
        final epoch = _epoch;
        final id = _id!;
        final page = selectedPage;
        final width = _width;
        final key = '$epoch:$page:$width';
        try {
          var entry = _cache.remove(key);
          if (entry == null) {
            final started = Stopwatch()..start();
            final response = await backend.render(id, page, width);
            final codec = await ui.instantiateImageCodec(
              response['bytes'] as Uint8List,
            );
            final frame = await codec.getNextFrame();
            codec.dispose();
            entry = PageBitmap(
              page,
              frame.image,
              (response['renderMs'] as num).toDouble(),
            );
            if (_disposed ||
                epoch != _epoch ||
                id != _id ||
                request != _request) {
              entry.image.dispose();
              completed = request;
              continue;
            }
            trace.add({
              'event': 'render',
              'page': page,
              'width': entry.image.width,
              'height': entry.image.height,
              'nativeMs': entry.renderMs,
              'transitionMs': started.elapsedMicroseconds / 1000,
            });
          }
          _cache[key] = entry;
          bitmap = entry;
          displayedPage = page;
          while (_cache.length > 2 || cacheBytes > cacheBudget) {
            final oldest = _cache.keys.first;
            if (_cache[oldest] == bitmap) break;
            _cache.remove(oldest)!.image.dispose();
          }
          completed = request;
          _completedRequest = request;
          _emit();
        } catch (_) {
          // A closed document or obsolete request must not poison the new one.
          if (!_disposed &&
              epoch == _epoch &&
              id == _id &&
              request == _request) {
            error =
                'Không thể hiển thị trang PDF. Hãy đóng tài liệu và mở lại.';
            _completedRequest = request;
          }
          completed = request;
          _emit();
        }
      }
    } finally {
      rendering = false;
      _emit();
    }
  }

  Future<void> close() async {
    ++_epoch;
    ++_request;
    final id = _id;
    _id = null;
    opening = false;
    pages = [];
    _clearCache();
    _emit();
    if (id != null) await backend.close(id);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(close());
    super.dispose();
  }
}
