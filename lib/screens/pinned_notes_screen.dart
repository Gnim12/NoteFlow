import 'package:flutter/material.dart';

import '../models/note.dart';
import '../repositories/notes_repository.dart';
import '../widgets/note_card.dart';

class PinnedNotesScreen extends StatefulWidget {
  final int userId;

  const PinnedNotesScreen({super.key, required this.userId});

  @override
  State<PinnedNotesScreen> createState() => _PinnedNotesScreenState();
}

class _PinnedNotesScreenState extends State<PinnedNotesScreen> {
  List<Note> pinnedNotes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPinnedNotes();
  }

  Future<void> loadPinnedNotes() async {
    final notes = await NotesRepository.instance.getNotes(widget.userId);

    setState(() {
      pinnedNotes = notes.where((note) => note.isPinned).toList();

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Notes épinglées")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pinnedNotes.isEmpty
          ? Center(
              child: Text(
                "Aucune note épinglée.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: pinnedNotes.length,
              itemBuilder: (_, index) {
                return NoteCard(note: pinnedNotes[index]);
              },
            ),
    );
  }
}
