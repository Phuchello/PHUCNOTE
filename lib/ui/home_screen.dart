// Copyright (c) 2026 PhucNote Authors. All rights reserved.
// Use of this source code is governed by an AGPL-3.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/note_document.dart';
import '../core/storage/note_storage.dart';
import '../drawing/canvas_controller.dart';
import 'canvas_view.dart';
import 'toolbar_widget.dart';

/// Main workspace screen for PhucNote, integrating handwriting canvas,
/// floating tool palette, and note persistence lifecycle (Create / Save / Reopen).
class HomeScreen extends StatefulWidget {
  final NoteStorage noteStorage;

  const HomeScreen({
    super.key,
    required this.noteStorage,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CanvasController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = CanvasController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _createNewNote() {
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

  Future<void> _saveNote() async {
    setState(() => _isSaving = true);
    try {
      final file = await widget.noteStorage.saveNote(_controller.document);
      _controller.markSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: ${file.path.split('/').last}'),
            backgroundColor: Colors.green.shade800,
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
                            try {
                              final loaded = await widget.noteStorage.loadNote(file);
                              _controller.setDocument(loaded);
                              if (context.mounted) {
                                Navigator.pop(ctx);
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
        return Scaffold(
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
                onPressed: _isSaving ? null : _saveNote,
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
        );
      },
    );
  }
}
