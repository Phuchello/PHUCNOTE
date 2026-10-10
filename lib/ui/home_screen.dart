// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/note_document.dart';
import '../core/storage/note_storage.dart';
import '../drawing/canvas_controller.dart';
import 'canvas_view.dart';
import 'toolbar_widget.dart';

/// Main workspace screen for PhucNote, integrating handwriting canvas,
/// floating tool palette, and data safety guarantees (atomic autosave,
/// unsaved change warnings, and switch guards).
class HomeScreen extends StatefulWidget {
  final NoteStorage noteStorage;

  const HomeScreen({
    super.key,
    required this.noteStorage,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final CanvasController _controller;
  bool _isSaving = false;
  Timer? _autosaveTimer;
  DateTime? _lastSavedAt;

  @override
  void initState() {
    super.initState();
    _controller = CanvasController();
    _controller.addListener(_onCanvasChanged);
    WidgetsBinding.instance.addObserver(this);
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
      if (_controller.isModified && !_isSaving) {
        _saveNote(silent: true);
      }
    }
  }

  void _onCanvasChanged() {
    if (_controller.isModified) {
      _autosaveTimer?.cancel();
      // Debounce autosave: trigger after 1500ms of inking inactivity
      _autosaveTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted && _controller.isModified && !_isSaving) {
          _saveNote(silent: true);
        }
      });
    }
  }

  Future<void> _saveNote({bool silent = false}) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final file = await widget.noteStorage.saveNote(_controller.document);
      _controller.markSaved();
      _lastSavedAt = DateTime.now();
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: ${file.path.split('/').last}'),
            backgroundColor: Colors.green.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        title: const Text('Unsaved Modifications'),
        content: Text(
          'Note "${_controller.document.title}" has unsaved changes.\n'
          'What would you like to do before $actionDescription?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard Changes'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text('Save & Proceed'),
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
    final canProceed = await _ensureSavedBeforeAction('creating a new note');
    if (!canProceed || !mounted) return;

    final titleController = TextEditingController(
      text: 'Note ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
    );
    PaperTemplate selectedTemplate = PaperTemplate.ruled;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Create New Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Note Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaperTemplate>(
                initialValue: selectedTemplate,
                decoration: const InputDecoration(
                  labelText: 'Paper Template',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: PaperTemplate.ruled, child: Text('Ruled Paper')),
                  DropdownMenuItem(value: PaperTemplate.grid, child: Text('Grid / Engineering Paper')),
                  DropdownMenuItem(value: PaperTemplate.blank, child: Text('Blank Canvas')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedTemplate = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final newDoc = NoteDocument(
                  title: title.isEmpty ? 'Untitled Note' : title,
                  paperTemplate: selectedTemplate,
                );
                _controller.setDocument(newDoc);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Created: "${newDoc.title}"')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOpenNoteDialog() async {
    final notes = await widget.noteStorage.listSavedNotes();
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
                      'Saved Notes (${notes.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                if (notes.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No saved notes found. Create and save one!'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final file = notes[index];
                        final filename = file.path.split('/').last;
                        final modified = file.lastModifiedSync();
                        final sizeKb = (file.lengthSync() / 1024).toStringAsFixed(1);

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.description_outlined),
                          ),
                          title: Text(filename),
                          subtitle: Text(
                            'Modified: ${DateFormat('yyyy-MM-dd HH:mm').format(modified)} • $sizeKb KB',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              await widget.noteStorage.deleteNote(file);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                _showOpenNoteDialog();
                              }
                            },
                          ),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final canProceed = await _ensureSavedBeforeAction('opening another note');
                            if (!canProceed || !context.mounted) return;

                            try {
                              final loaded = await widget.noteStorage.loadNote(file);
                              _controller.setDocument(loaded);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Loaded: "${loaded.title}"')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error loading note: $e')),
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
    final titleController = TextEditingController(text: _controller.document.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Note'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                setState(() {
                  _controller.document.title = newTitle;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
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
          canPop: !_controller.isModified,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final canProceed = await _ensureSavedBeforeAction('exiting the application');
            if (canProceed && context.mounted) {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 8,
              title: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _renameNote,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          doc.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit, size: 16, color: Colors.grey),
                      if (_controller.isModified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Unsaved',
                            style: TextStyle(fontSize: 10, color: Colors.brown, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else if (_lastSavedAt != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Saved',
                            style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                // New Note
                IconButton(
                  icon: const Icon(Icons.note_add_outlined),
                  tooltip: 'New Note',
                  onPressed: _createNewNote,
                ),
                // Open Notes
                IconButton(
                  icon: const Icon(Icons.folder_open_outlined),
                  tooltip: 'Open Notes',
                  onPressed: _showOpenNoteDialog,
                ),
                // Save Note
                FilledButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save'),
                  onPressed: _isSaving ? null : () => _saveNote(silent: false),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Stack(
              children: [
                // Canvas View
                Positioned.fill(
                  child: CanvasView(
                    controller: _controller,
                    paperColor: const Color(0xFFFBFBF9), // Warm Paper Ivory
                  ),
                ),

                // Floating Ergonomic Toolbar
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: ToolbarWidget(controller: _controller),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
