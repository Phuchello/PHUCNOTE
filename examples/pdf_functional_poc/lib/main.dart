import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pdf_session.dart';
import 'page_viewport.dart';
import 'ink_sheet.dart';
import 'ink_surface.dart';

const fixtureRoot = 'assets/';
const fixtureNames = [
  'lecture_notes_discrete_math.pdf',
  'lecture_slides_network_security.pdf',
  'scanned_historical_notes.pdf',
];
const fixtureTitles = ['Toán rời rạc', 'An toàn mạng', 'Bản thảo lịch sử'];
const navy = Color(0xFF18324B);
const ivory = Color(0xFFFAF7F0);
const gold = Color(0xFFD4AF37);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 8;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 2 * 1024 * 1024;
  runApp(const PocApp());
}

class PocApp extends StatefulWidget {
  const PocApp({super.key});
  @override
  State<PocApp> createState() => _PocAppState();
}

class _PocAppState extends State<PocApp> {
  bool dark = false;
  @override
  void initState() {
    super.initState();
    PaintingBinding.instance.imageCache.maximumSize = 8;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 2 * 1024 * 1024;
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('vi', 'VN'),
    supportedLocales: const [Locale('vi', 'VN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: navy),
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        brightness: Brightness.dark,
      ),
    ),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: PdfReader(onTheme: () => setState(() => dark = !dark)),
  );
}

class PdfReader extends StatefulWidget {
  final VoidCallback onTheme;
  const PdfReader({super.key, required this.onTheme});
  @override
  State<PdfReader> createState() => PdfReaderState();
}

class PdfReaderState extends State<PdfReader> with WidgetsBindingObserver {
  final session = PdfSession();
  final viewport = PageViewport();
  final Map<String, InkSheet> sheets = {};
  InkTool tool = InkTool.hand;
  bool _disposing = false;
  bool _inkRebuildPending = false;
  bool split = false;
  bool portraitNotes = false;
  double splitRatio = .5;
  int notePage = 0;
  InkTool noteTool = InkTool.pen;
  final noteViewport = PageViewport();
  final Map<int, InkSheet> noteSheets = {};
  InkSheet get noteSheet => noteSheets.putIfAbsent(
    notePage,
    () => InkSheet()..addListener(_inkChanged),
  );
  InkSheet get sheet =>
      sheets.putIfAbsent('$document:${session.selectedPage}', () {
        final created = InkSheet()..addListener(_inkChanged);
        return created;
      });
  void _inkChanged() {
    if (!mounted || _disposing) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (_inkRebuildPending) return;
      _inkRebuildPending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _inkRebuildPending = false;
        if (mounted && !_disposing) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  int document = 0;
  Timer? _resolution;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    viewport.addListener(_requestResolution);
    noteViewport.addListener(_inkChanged);
    unawaited(session.openAsset('$fixtureRoot${fixtureNames.first}'));
  }

  void _requestResolution() {
    _resolution?.cancel();
    _resolution = Timer(const Duration(milliseconds: 180), () {
      if (!mounted || session.pages.isEmpty) return;
      final width =
          (viewport.page.width *
                  viewport.scale *
                  MediaQuery.devicePixelRatioOf(context))
              .ceil();
      unawaited(
        session.select(
          session.selectedPage,
          width: ((width + 255) ~/ 256) * 256,
        ),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _resolution?.cancel();
    if (state == AppLifecycleState.resumed) _requestResolution();
  }

  @override
  void dispose() {
    _disposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _resolution?.cancel();
    viewport.dispose();
    noteViewport.dispose();
    session.dispose();
    for (final sheet in sheets.values) {
      sheet.removeListener(_inkChanged);
      sheet.end();
      sheet.dispose();
    }
    for (final sheet in noteSheets.values) {
      sheet.removeListener(_inkChanged);
      sheet.end();
      sheet.dispose();
    }
    super.dispose();
  }

  Future<void> load(int index) async {
    setState(() => document = index);
    await session.openAsset('$fixtureRoot${fixtureNames[index]}');
  }

  Widget button(String label, IconData icon, VoidCallback? action) =>
      IconButton(
        tooltip: label,
        onPressed: action,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: Icon(icon, size: 22),
      );
  Future<void> thumbnails() async {
    final id = session.documentId;
    if (id == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Chọn trang'),
        content: SizedBox(
          width: 330,
          height: 440,
          child: ListView.builder(
            itemCount: session.pages.length,
            itemBuilder: (context, index) => ListTile(
              key: ValueKey('thumbnail-$index'),
              minTileHeight: 100,
              leading: SizedBox(
                width: 80,
                child: FutureBuilder<Map<dynamic, dynamic>>(
                  future: session.backend.render(id, index, 128),
                  builder: (context, snapshot) => snapshot.hasData
                      ? Image.memory(
                          snapshot.data!['bytes'] as Uint8List,
                          fit: BoxFit.contain,
                          cacheWidth: 128,
                        )
                      : const Icon(Icons.picture_as_pdf),
                ),
              ),
              title: Text('Trang ${index + 1}'),
              selected: index == session.selectedPage,
              onTap: () {
                unawaited(session.select(index));
                Navigator.pop(dialog);
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([session, viewport]),
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: ivory,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fixtureTitles[document],
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              'Atelier PDF · Thử nghiệm riêng',
              style: TextStyle(fontSize: 12, color: gold),
            ),
          ],
        ),
        actions: [
          button(
            'Học song song',
            Icons.vertical_split,
            () => setState(() => split = !split),
          ),
          PopupMenuButton<int>(
            tooltip: 'Mở PDF mẫu',
            icon: const Icon(Icons.folder_open),
            onSelected: load,
            itemBuilder: (_) => [
              for (var i = 0; i < fixtureTitles.length; i++)
                PopupMenuItem(value: i, child: Text(fixtureTitles[i])),
            ],
          ),
          button(
            'Giao diện sáng/tối',
            Icons.brightness_6_outlined,
            widget.onTheme,
          ),
          button('Đóng PDF', Icons.close, () => unawaited(session.close())),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final entry in const {
                    InkTool.hand: (
                      'Di chuyển bằng chạm',
                      Icons.pan_tool_outlined,
                    ),
                    InkTool.pen: ('Bút viết', Icons.edit_outlined),
                    InkTool.highlighter: (
                      'Bút đánh dấu',
                      Icons.border_color_outlined,
                    ),
                    InkTool.eraser: ('Tẩy nét mực', Icons.auto_fix_normal),
                  }.entries)
                    IconButton(
                      tooltip: entry.value.$1,
                      isSelected: tool == entry.key,
                      constraints: const BoxConstraints.tightFor(
                        width: 48,
                        height: 48,
                      ),
                      onPressed: () => setState(() => tool = entry.key),
                      icon: Icon(entry.value.$2),
                      selectedIcon: Icon(entry.value.$2, color: gold),
                    ),
                  button(
                    'Hoàn tác mực',
                    Icons.undo,
                    sheet.canUndo ? sheet.undo : null,
                  ),
                  button(
                    'Làm lại mực',
                    Icons.redo,
                    sheet.canRedo ? sheet.redo : null,
                  ),
                  button(
                    'Trang đầu',
                    Icons.first_page,
                    session.pages.isEmpty
                        ? null
                        : () => unawaited(session.select(0)),
                  ),
                  button(
                    'Trang trước',
                    Icons.chevron_left,
                    session.selectedPage == 0
                        ? null
                        : () => unawaited(
                            session.select(session.selectedPage - 1),
                          ),
                  ),
                  Text(
                    'Trang ${session.pages.isEmpty ? 0 : session.selectedPage + 1} / ${session.pages.length}',
                    key: const ValueKey('page-counter'),
                  ),
                  button(
                    'Trang sau',
                    Icons.chevron_right,
                    session.selectedPage + 1 >= session.pages.length
                        ? null
                        : () => unawaited(
                            session.select(session.selectedPage + 1),
                          ),
                  ),
                  button(
                    'Trang cuối',
                    Icons.last_page,
                    session.pages.isEmpty
                        ? null
                        : () => unawaited(
                            session.select(session.pages.length - 1),
                          ),
                  ),
                  button('Chọn trang thu nhỏ', Icons.grid_view, thumbnails),
                  const SizedBox(width: 12),
                  button('Vừa trang', Icons.fit_screen, () => viewport.fit()),
                  button(
                    'Vừa chiều rộng',
                    Icons.width_full,
                    () => viewport.fit(width: true),
                  ),
                  button(
                    'Thu nhỏ',
                    Icons.remove,
                    () => viewport.zoom(
                      viewport.scale / 1.25,
                      viewport.view.center(Offset.zero),
                    ),
                  ),
                  Text(
                    '${(viewport.scale * 100).round()}%',
                    key: const ValueKey('zoom-counter'),
                  ),
                  button(
                    'Phóng to',
                    Icons.add,
                    () => viewport.zoom(
                      viewport.scale * 1.25,
                      viewport.view.center(Offset.zero),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Bút cảm ứng để viết · Chạm để di chuyển · Mực chỉ lưu trong phiên',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: split ? _splitStudy() : _documentCanvas()),
        ],
      ),
    ),
  );

  Widget _documentCanvas() => session.error != null
      ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(session.error!, key: const ValueKey('pdf-error')),
          ),
        )
      : session.pages.isEmpty
      ? Center(
          child: Text(
            session.opening
                ? 'Đang mở PDF…'
                : 'Tài liệu đã đóng. Chọn PDF mẫu để mở lại.',
          ),
        )
      : LayoutBuilder(
          builder: (context, constraints) {
            viewport.layout(
              session.pages[session.selectedPage],
              constraints.biggest,
            );
            return InkSurface(
              key: const ValueKey('pdf-viewport'),
              viewport: viewport,
              sheet: sheet,
              tool: tool,
              background: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF0F141C)
                          : const Color(0xFFE5DED1),
                    ),
                    CustomPaint(
                      painter: PdfPagePainter(viewport, session.bitmap),
                    ),
                    if (session.rendering && session.bitmap == null)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            );
          },
        );

  Widget _noteCanvas() => Column(
    children: [
      Material(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final entry in const {
                InkTool.pen: ('Bút ghi chú', Icons.edit_outlined),
                InkTool.highlighter: (
                  'Đánh dấu ghi chú',
                  Icons.border_color_outlined,
                ),
                InkTool.eraser: ('Tẩy ghi chú', Icons.auto_fix_normal),
              }.entries)
                IconButton(
                  tooltip: entry.value.$1,
                  isSelected: noteTool == entry.key,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  onPressed: () => setState(() => noteTool = entry.key),
                  icon: Icon(entry.value.$2),
                  selectedIcon: Icon(entry.value.$2, color: gold),
                ),
              button(
                'Hoàn tác ghi chú',
                Icons.undo,
                noteSheet.canUndo ? noteSheet.undo : null,
              ),
              button(
                'Làm lại ghi chú',
                Icons.redo,
                noteSheet.canRedo ? noteSheet.redo : null,
              ),
              button(
                'Trang ghi chú trước',
                Icons.chevron_left,
                notePage == 0 ? null : () => setState(() => notePage--),
              ),
              Text(
                'Ghi chú ${notePage + 1} / 3',
                key: const ValueKey('note-counter'),
              ),
              button(
                'Trang ghi chú sau',
                Icons.chevron_right,
                notePage == 2 ? null : () => setState(() => notePage++),
              ),
              button(
                'Vừa trang ghi chú',
                Icons.fit_screen,
                () => noteViewport.fit(),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            noteViewport.layout(const Size(595, 841), constraints.biggest);
            return InkSurface(
              key: const ValueKey('note-viewport'),
              viewport: noteViewport,
              sheet: noteSheet,
              tool: noteTool,
              background: CustomPaint(painter: NotePaperPainter(noteViewport)),
            );
          },
        ),
      ),
    ],
  );

  Widget _splitStudy() => LayoutBuilder(
    builder: (context, constraints) {
      final landscape =
          constraints.maxWidth >= 900 &&
          constraints.maxWidth > constraints.maxHeight;
      return Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (landscape) ...[
                    const Text('Tỷ lệ'),
                    for (final ratio in [.4, .5, .6])
                      TextButton(
                        key: ValueKey('ratio-$ratio'),
                        onPressed: () => setState(() => splitRatio = ratio),
                        child: Text(
                          '${(ratio * 100).round()}:${((1 - ratio) * 100).round()}',
                        ),
                      ),
                  ] else ...[
                    TextButton(
                      onPressed: () => setState(() => portraitNotes = false),
                      child: Text(
                        'Tài liệu',
                        style: TextStyle(color: !portraitNotes ? gold : null),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => portraitNotes = true),
                      child: Text(
                        'Ghi chú',
                        style: TextStyle(color: portraitNotes ? gold : null),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: landscape
                ? LayoutBuilder(
                    builder: (context, panes) {
                      final usable = panes.maxWidth - 48;
                      return Row(
                        children: [
                          SizedBox(
                            key: const ValueKey('document-pane'),
                            width: usable * splitRatio,
                            child: _documentCanvas(),
                          ),
                          GestureDetector(
                            key: const ValueKey('split-divider'),
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) => setState(
                              () => splitRatio =
                                  (splitRatio + details.delta.dx / usable)
                                      .clamp(.4, .6),
                            ),
                            child: const SizedBox(
                              width: 48,
                              child: Center(
                                child: Icon(Icons.drag_indicator, color: gold),
                              ),
                            ),
                          ),
                          Expanded(
                            key: const ValueKey('note-pane'),
                            child: _noteCanvas(),
                          ),
                        ],
                      );
                    },
                  )
                : IndexedStack(
                    index: portraitNotes ? 1 : 0,
                    children: [_documentCanvas(), _noteCanvas()],
                  ),
          ),
        ],
      );
    },
  );
}

class NotePaperPainter extends CustomPainter {
  final PageViewport viewport;
  NotePaperPainter(this.viewport);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE5DED1),
    );
    canvas.save();
    canvas.translate(viewport.offset.dx, viewport.offset.dy);
    canvas.scale(viewport.scale);
    canvas.drawRect(viewport.pageBounds, Paint()..color = ivory);
    final line = Paint()
      ..color = const Color(0x33285DC2)
      ..strokeWidth = .7;
    for (double y = 36; y < viewport.page.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(viewport.page.width, y), line);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NotePaperPainter oldDelegate) => true;
}

class PdfPagePainter extends CustomPainter {
  final PageViewport viewport;
  final PageBitmap? bitmap;
  PdfPagePainter(this.viewport, this.bitmap);
  @override
  void paint(Canvas canvas, Size size) {
    final source = bitmap;
    if (source == null) return;
    canvas.drawRect(viewport.screenBounds.inflate(1), Paint()..color = gold);
    canvas.drawImageRect(
      source.image,
      Offset.zero &
          Size(source.image.width.toDouble(), source.image.height.toDouble()),
      viewport.screenBounds,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant PdfPagePainter old) => true;
}
