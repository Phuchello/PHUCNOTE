// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import 'app_theme.dart';
import '../core/models/note_document.dart';
import '../core/storage/note_storage.dart';
import '../core/storage/input_preferences_store.dart';
import '../drawing/canvas_controller.dart';
import 'canvas_view.dart';
import 'toolbar_widget.dart';

/// Main workspace screen for PhucNote, integrating handwriting canvas,
/// floating tool palette, and data safety guarantees (atomic autosave,
/// unsaved change warnings, and switch guards).
class HomeScreen extends StatefulWidget {
  final NoteStorage noteStorage;
  final InputPreferencesStore? inputPreferences;

  const HomeScreen({super.key, required this.noteStorage, this.inputPreferences});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final CanvasController _controller;
  bool _isSaving = false;
  Future<void>? _saveFuture;
  Timer? _autosaveTimer;
  DateTime? _lastSavedAt;
  bool _zenMode = false;
  bool _initializedTitle = false;
  late final InputPreferencesStore _inputPreferences;
  bool _inputReady = false;
  bool _inputChoiceChanged = false;
  bool _restoringInput = false;
  bool _lastInputMode = true;

  @override
  void initState() {
    super.initState();
    _controller = CanvasController();
    _inputPreferences = widget.inputPreferences ?? InputPreferencesStore(
      directory: widget.noteStorage.customRootDirectory,
    );
    _controller.addListener(_onCanvasChanged);
    WidgetsBinding.instance.addObserver(this);
    unawaited(_restoreInputPreference());
  }

  Future<void> _restoreInputPreference() async {
    try {
      final saved = await _inputPreferences.load();
      if (!mounted) return;
      if (!_inputChoiceChanged) {
        _restoringInput = true;
        _lastInputMode = saved;
        _controller.setStylusOnlyMode(saved);
        _restoringInput = false;
      }
      setState(() => _inputReady = true);
      if (_inputChoiceChanged) unawaited(_persistInputPreference());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noteSaveFailed)),
      );
      setState(() => _inputReady = true);
      if (_inputChoiceChanged) unawaited(_persistInputPreference());
    }
  }

  Future<void> _persistInputPreference() async {
    try {
      await _inputPreferences.save(_controller.stylusOnlyMode);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noteSaveFailed)),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTitle) {
      _initializedTitle = true;
      _controller.setDocument(NoteDocument(title: context.l10n.untitledNote));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosaveTimer?.cancel();
    _controller.removeListener(_onCanvasChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      if (_controller.isModified) {
        _saveNote(silent: true);
      }
    }
  }

  void _onCanvasChanged() {
    if (!_restoringInput && _lastInputMode != _controller.stylusOnlyMode) {
      _lastInputMode = _controller.stylusOnlyMode;
      _inputChoiceChanged = true;
      if (_inputReady) unawaited(_persistInputPreference());
    }
    _autosaveTimer?.cancel();
    if (_controller.isModified) {
      // Debounce autosave: trigger after 1500ms of inking inactivity
      _autosaveTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted && _controller.isModified) {
          _saveNote(silent: true);
        }
      });
    }
  }

  Future<void> _saveNote({bool silent = false}) async {
    if (_saveFuture != null) return _saveFuture!;
    final completion = Completer<void>();
    _saveFuture = completion.future;
    _autosaveTimer?.cancel();
    setState(() => _isSaving = true);
    try {
      do {
        final document = _controller.document;
        final revision = _controller.revision;
        final snapshot = NoteDocument.fromJson(document.toJson());
        final file = await widget.noteStorage.saveNote(snapshot);
        if (!mounted) return;
        _controller.markSaved(document: document, revision: revision);
        if (identical(document, _controller.document)) {
          _lastSavedAt = DateTime.now();
          if (!silent && !_controller.isModified) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n.savedTo(file.uri.pathSegments.last),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } while (_controller.isModified);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.noteSaveFailed,
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      _saveFuture = null;
      if (mounted) {
        setState(() => _isSaving = false);
        if (_controller.isModified) _onCanvasChanged();
      }
      completion.complete();
    }
  }

  /// Guards against data loss: prompts or auto-saves when current document has unsaved modifications.
  Future<bool> _ensureSavedBeforeAction(String actionDescription) async {
    if (!_controller.isModified) return true;

    // Prompt user on what to do with unsaved modifications
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.unsavedTitle),
        content: Text(
          context.l10n.unsavedBody(
            _controller.document.title,
            actionDescription,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.discardChanges),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: Text(context.l10n.saveAndProceed),
          ),
        ],
      ),
    );

    if (result == 'save') {
      await _saveNote(silent: false);
      return !_controller.isModified;
    } else if (result == 'discard') {
      return true;
    }
    return false; // Cancelled
  }

  Future<void> _createNewNote() async {
    final canProceed = await _ensureSavedBeforeAction(
      context.l10n.actionCreateNote,
    );
    if (!canProceed || !mounted) return;

    final titleController = TextEditingController(
      text: context.l10n.generatedNoteTitle(context.uiDateTime(DateTime.now())),
    );
    PaperTemplate selectedTemplate = PaperTemplate.ruled;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(context.l10n.createNote),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.noteTitle,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaperTemplate>(
                  initialValue: selectedTemplate,
                  decoration: InputDecoration(
                    labelText: context.l10n.paperTemplate,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: PaperTemplate.ruled,
                      child: Text(context.l10n.paperRuled),
                    ),
                    DropdownMenuItem(
                      value: PaperTemplate.grid,
                      child: Text(context.l10n.paperGrid),
                    ),
                    DropdownMenuItem(
                      value: PaperTemplate.blank,
                      child: Text(context.l10n.paperBlank),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => selectedTemplate = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final newDoc = NoteDocument(
                  title: title.isEmpty ? context.l10n.untitledNote : title,
                  paperTemplate: selectedTemplate,
                );
                _lastSavedAt = null;
                _controller.setDocument(newDoc);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.createdNote(newDoc.title)),
                  ),
                );
              },
              child: Text(context.l10n.create),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOpenNoteDialog() async {
    List<File> notes;
    try {
      notes = await widget.noteStorage.listSavedNotes();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.noteListFailed)));
      }
      return;
    }
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.savedNotes(notes.length),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: context.l10n.close,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                if (notes.isEmpty)
                  Expanded(child: Center(child: Text(context.l10n.emptyNotes)))
                else
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final file = notes[index];
                        final filename = file.uri.pathSegments.last;
                        final modified = file.lastModifiedSync();
                        final sizeKb = context.uiDecimal(
                          file.lengthSync() / 1024,
                          digits: 1,
                        );

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.description_outlined),
                          ),
                          title: Text(filename),
                          subtitle: Text(
                            context.l10n.noteModified(
                              context.uiDateTime(modified),
                              sizeKb,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: context.l10n.deleteNote,
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () async {
                              try {
                                await widget.noteStorage.deleteNote(file);
                              } catch (_) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(ctx.l10n.noteDeleteFailed),
                                    ),
                                  );
                                }
                                return;
                              }
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                _showOpenNoteDialog();
                              }
                            },
                          ),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final canProceed = await _ensureSavedBeforeAction(
                              context.l10n.actionOpenNote,
                            );
                            if (!canProceed || !mounted) return;

                            try {
                              final loaded = await widget.noteStorage.loadNote(
                                file,
                              );
                              _lastSavedAt = file.lastModifiedSync();
                              _controller.setDocument(loaded);
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      this.context.l10n.loadedNote(
                                        loaded.title,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } catch (_) {
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      this.context.l10n.noteLoadFailed,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _renameNote() {
    final titleController = TextEditingController(
      text: _controller.document.title,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.renameNote),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: InputDecoration(labelText: context.l10n.noteTitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                _controller.renameDocument(newTitle);
              }
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.rename),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final doc = _controller.document;
        return PopScope(
          canPop: !_zenMode && !_controller.isModified,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (_zenMode) {
              setState(() => _zenMode = false);
              return;
            }
            final canProceed = await _ensureSavedBeforeAction(
              context.l10n.actionExitApp,
            );
            if (canProceed && context.mounted) {
              Navigator.pop(context);
            }
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            // AppBar supplies its own overlay while visible. In Zen the
            // system bars sit on ivory paper, which needs dark icons.
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: StudioTokens.paper,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              appBar: _zenMode
                  ? null
                  : AppBar(
                      toolbarHeight:
                          (MediaQuery.textScalerOf(context).scale(18) * 1.35 +
                                  MediaQuery.textScalerOf(context).scale(12) *
                                      1.5 +
                                  10)
                              .clamp(64, double.infinity),
                      titleSpacing: 12,
                      leading: MediaQuery.sizeOf(context).width >= 600
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.menu_book_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : null,
                      title: Tooltip(
                        message: context.l10n.renameHint,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _renameNote,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        doc.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      _isSaving
                                          ? Icons.sync
                                          : _controller.isModified
                                          ? Icons.edit_note
                                          : Icons.check_circle_outline,
                                      size: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _isSaving
                                            ? context.l10n.saving
                                            : _controller.isModified
                                            ? context.l10n.unsaved
                                            : _lastSavedAt != null
                                            ? context.l10n.savedAt(
                                                context.uiTime(_lastSavedAt!),
                                              )
                                            : context.l10n.noChanges,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        // New Note
                        IconButton(
                          icon: const Icon(Icons.note_add_outlined),
                          tooltip: context.l10n.newNote,
                          onPressed: _createNewNote,
                        ),
                        // Open Notes
                        IconButton(
                          icon: const Icon(Icons.folder_open_outlined),
                          tooltip: context.l10n.openNotes,
                          onPressed: _showOpenNoteDialog,
                        ),
                        // Save Note
                        FilledButton.icon(
                          icon: _isSaving
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 18),
                          label: Text(context.l10n.save),
                          onPressed: _isSaving
                              ? null
                              : () => _saveNote(silent: false),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
              body: Stack(
                children: [
                  // Canvas View
                  Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: !_inputReady,
                      child: CanvasView(
                        key: const ValueKey('editor-canvas'),
                        controller: _controller,
                        paperColor: StudioTokens.paper,
                      ),
                    ),
                  ),

                  // Floating Ergonomic Toolbar
                  if (!_zenMode)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: ToolbarWidget(
                            controller: _controller,
                            onEnterZen: () => setState(() => _zenMode = true),
                          ),
                        ),
                      ),
                    ),
                  if (_zenMode)
                    Positioned(
                      top: 12,
                      right: 16,
                      child: SafeArea(
                        child: Tooltip(
                          message: context.l10n.exitZen,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            icon: const Icon(Icons.fullscreen_exit, size: 20),
                            label: Text(context.l10n.exitZen),
                            onPressed: () => setState(() => _zenMode = false),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
