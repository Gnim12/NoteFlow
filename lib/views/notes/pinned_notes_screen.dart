import 'package:flutter/material.dart';

import '../../controllers/note_controller.dart';
import '../../models/note_model.dart';
import '../../widgets/note_card.dart';

class PinnedNotesScreen extends StatefulWidget {
  final String userId;

  const PinnedNotesScreen({super.key, required this.userId});

  @override
  State<PinnedNotesScreen> createState() => _PinnedNotesScreenState();
}

class _PinnedNotesScreenState extends State<PinnedNotesScreen> {
  final NoteController _noteController = NoteController.instance;

  List<Note> pinnedNotes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPinnedNotes();
  }

  Future<void> loadPinnedNotes() async {
    final notes = await _noteController.getNotes(widget.userId);

    setState(() {
      pinnedNotes = _noteController.pinnedOnly(notes);

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
