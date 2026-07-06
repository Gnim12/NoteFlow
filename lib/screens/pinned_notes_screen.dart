import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';

class PinnedNotesScreen extends StatefulWidget {
  const PinnedNotesScreen({super.key});

  @override
  State<PinnedNotesScreen> createState() =>
      _PinnedNotesScreenState();
}

class _PinnedNotesScreenState
    extends State<PinnedNotesScreen> {

  List<Note> pinnedNotes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPinnedNotes();
  }

  Future<void> loadPinnedNotes() async {
    final notes =
        await DatabaseHelper.instance.getNotes();

    setState(() {
      pinnedNotes = notes
          .where((note) => note.isPinned)
          .toList();

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes épinglées"),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : pinnedNotes.isEmpty
              ? const Center(
                  child: Text(
                    "Aucune note épinglée.",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: pinnedNotes.length,
                  itemBuilder: (_, index) {
                    return NoteCard(
                      note: pinnedNotes[index],
                    );
                  },
                ),
    );
  }
}