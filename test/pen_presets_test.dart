import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:phucnote/core/models/pen_preset.dart';
import 'package:phucnote/core/models/stroke_point.dart';
import 'package:phucnote/core/models/stroke_property.dart';
import 'package:phucnote/core/storage/bfly_serializer.dart';
import 'package:phucnote/core/storage/note_storage.dart';
import 'package:phucnote/core/storage/pen_preset_store.dart';
import 'package:phucnote/drawing/canvas_controller.dart';
import 'package:phucnote/drawing/stroke_geometry.dart';
import 'package:phucnote/ui/pen_preview.dart';

final samples = [
  for (var i = 0; i < 60; i++)
    StrokePoint(
      x: 20 + i * 0.5,
      y: 60 + 10 * math.sin(i * 0.2),
      pressure: 0.1 + (i % 20) / 22,
    ),
];

List<double> geometry(StrokeProperty property) {
  final path = StrokeGeometry.generatePath(samples, property);
  final bounds = path.getBounds();
  return [
    bounds.left,
    bounds.top,
    bounds.right,
    bounds.bottom,
    ...path.computeMetrics().map((metric) => metric.length),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All three presets produce measurably distinct outlines', () {
    final signatures = PenPreset.defaults
        .map((preset) => geometry(preset.property))
        .toList();
    for (var i = 0; i < signatures.length; i++) {
      for (var j = i + 1; j < signatures.length; j++) {
        final difference = [
          for (var k = 0; k < signatures[i].length; k++)
            (signatures[i][k] - signatures[j][k]).abs(),
        ].reduce((a, b) => a + b);
        expect(difference, greaterThan(1));
      }
    }
  });

  test(
    'Fountain simulation varies width with pressure; Ballpoint stays uniform',
    () {
      final points = [
        for (var i = 0; i <= 100; i++)
          StrokePoint(x: i * 3, y: 50, pressure: i < 50 ? 0.1 : 0.95),
      ];
      double thickness(Path path, double x) {
        var count = 0;
        for (double y = 30; y < 70; y += 0.05) {
          if (path.contains(Offset(x, y))) count++;
        }
        return count * 0.05;
      }

      for (final preset in [
        PenPreset.defaults.first,
        PenPreset.defaults.last,
      ]) {
        final path = StrokeGeometry.generatePath(points, preset.property);
        final low = thickness(path, 90);
        final high = thickness(path, 240);
        expect(low, greaterThan(0));
        if (preset.name == 'Ballpoint') {
          expect(high, closeTo(low, 0.1));
        } else {
          expect(high, greaterThan(low + 2));
        }
      }
    },
  );

  test('Continuous geometry parameters change the existing engine outline', () {
    final original = PenPreset.defaults.last.property;
    for (final property in [
      original.copyWith(strokeWidth: 5.137),
      original.copyWith(thinning: -0.37),
      original.copyWith(smoothing: 0.137),
      original.copyWith(streamline: 0.137),
    ]) {
      expect(geometry(property), isNot(geometry(original)));
    }
  });

  test('Preview color and opacity change painted pixels', () async {
    Future<List<int>> pixels(StrokeProperty property) async {
      final recorder = PictureRecorder();
      PenPreviewPainter(
        property: property,
        strokes: [samples],
      ).paint(Canvas(recorder), const Size(240, 132));
      final picture = recorder.endRecording();
      final image = await picture.toImage(240, 132);
      final bytes = await image.toByteData(format: ImageByteFormat.rawRgba);
      final result = bytes!.buffer.asUint8List().toList();
      image.dispose();
      picture.dispose();
      return result;
    }

    final property = PenPreset.defaults.last.property;
    final original = await pixels(property);
    expect(
      await pixels(property.copyWith(colorValue: 0xFF1565C0)),
      isNot(original),
    );
    expect(await pixels(property.copyWith(opacity: 0.37)), isNot(original));
  });

  test('Preset changes, undo/redo and disk reopen preserve exact ink and coordinates', () async {
    final directory = await Directory.systemTemp.createTemp('pen_roundtrip_');
    final controller = CanvasController();
    addTearDown(controller.dispose);
    addTearDown(() => directory.delete(recursive: true));
    final storage = NoteStorage(customRootDirectory: directory);
    for (final preset in PenPreset.defaults) {
      controller.setPenProperty(
        preset.property.copyWith(colorValue: 0xFF1565C0, opacity: 0.637),
      );
      controller.handlePointerDown(
        const PointerDownEvent(position: Offset(20, 30), pressure: 0.2),
      );
      controller.handlePointerMove(
        const PointerMoveEvent(position: Offset(50, 60), pressure: 0.8),
      );
      controller.handlePointerUp(const PointerUpEvent());
    }
    final original = controller.document.strokes
        .map((stroke) => stroke.toJson())
        .toList();
    final outlines = controller.document.strokes
        .map((s) => geometry(s.property))
        .toList();
    controller.setPenProperty(
      PenPreset.defaults.first.property.copyWith(strokeWidth: 21),
    );
    expect(
      controller.document.strokes.map((s) => geometry(s.property)),
      outlines,
    );
    for (var i = 0; i < 3; i++) {
      controller.undo();
      controller.redo();
      expect(controller.document.strokes.map((s) => s.toJson()), original);
    }
    final reopened = await storage.loadNote(
      await storage.saveNote(controller.document),
    );
    expect(reopened.strokes.map((s) => s.toJson()), original);
  });

  test(
    'Legacy Butterfly fixtures retain supported properties on roundtrip',
    () async {
      for (final name in ['document_v1.bfly', 'study.tbfly']) {
        final document = BflySerializer.decode(
          await File('test/fixtures/$name').readAsBytes(),
        );
        final original = document.strokes
            .map((stroke) => stroke.toJson())
            .toList();
        expect(original, isNotEmpty);
        final reopened = BflySerializer.decode(BflySerializer.encode(document));
        expect(reopened.strokes.map((stroke) => stroke.toJson()), original);
      }
    },
  );

  group('Personal preset settings', () {
    late Directory directory;
    late PenPresetStore store;
    setUp(() async {
      directory = await Directory.systemTemp.createTemp('pen_settings_');
      store = PenPresetStore(directory: directory);
    });
    tearDown(() => directory.delete(recursive: true));

    test('Named custom parameters survive restart; queued writes retain latest snapshot', () async {
      final first = PenPreset(
        'Study',
        PenPreset.defaults.last.property.copyWith(opacity: 0.63),
      );
      final second = PenPreset(
        'Blue notes',
        PenPreset.defaults[1].property.copyWith(colorValue: 0xFF1565C0),
      );
      final presets = [first];
      final a = store.save(presets);
      presets.add(second);
      final b = store.save(presets);
      await Future.wait([a, b]);
      final loaded = await PenPresetStore(directory: directory).load();
      expect(loaded.map((p) => p.toJson()), presets.map((p) => p.toJson()));
      expect(directory.listSync().whereType<File>(), isEmpty);
    });

    test('Invalid/duplicate names and nonfinite settings never replace good presets', () async {
      final original = PenPreset('Study', PenPreset.defaults.first.property);
      await store.save([original]);
      for (final invalid in [
        PenPreset('', original.property),
        PenPreset('Ballpoint', original.property),
        PenPreset('study', original.property),
        PenPreset('Bad', original.property.copyWith(smoothing: double.nan)),
      ]) {
        await expectLater(
          store.save([original, invalid]),
          throwsFormatException,
        );
        expect((await store.load()).single.toJson(), original.toJson());
      }
      await store.save([PenPreset('Recovered', original.property)]);
      expect((await store.load()).single.name, 'Recovered');
    });

    test('Malformed settings are reported and kept', () async {
      final file = File('${directory.path}/settings/pen_presets.json');
      await file.parent.create();
      for (final contents in [
        'invalid existing settings',
        jsonEncode([
          {
            'name': 'Bad color',
            'property': {
              ...PenPreset.defaults.first.property.toJson(),
              'color': 3.14,
            },
          },
        ]),
      ]) {
        await file.writeAsString(contents);
        await expectLater(store.load(), throwsFormatException);
        expect(await file.readAsString(), contents);
      }
    });

    test('Write failure is surfaced and does not poison the queue', () async {
      final obstructing = File('${directory.path}/settings');
      await obstructing.writeAsString('block directory creation');
      final preset = PenPreset('Study', PenPreset.defaults.first.property);
      await expectLater(
        store.save([preset]),
        throwsA(isA<FileSystemException>()),
      );
      await obstructing.delete();
      await store.save([preset]);
      expect((await store.load()).single.toJson(), preset.toJson());
    });
  });
}
