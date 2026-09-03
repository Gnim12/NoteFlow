import 'package:flutter/material.dart';

import '../../controllers/note_controller.dart';
import '../../core/errors/error_presenter.dart';
import '../../models/note_model.dart';
import '../../widgets/note_card.dart';

class TrashScreen extends StatefulWidget {
  final String userId;

  const TrashScreen({super.key, required this.userId});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final NoteController _noteController = NoteController.instance;

  List<Note> trashedNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTrash();
  }

  Future<void> loadTrash() async {
    final result = await _noteController.getTrashedNotes(widget.userId);

    if (!mounted) return;

    setState(() {
      trashedNotes = result;
      isLoading = false;
    });
  }

  Future<void> _restore(Note note) async {
    await _noteController.restoreFromTrash(note);
    if (!mounted) return;
    ErrorPresenter.showSuccess(context, "Note restaurée.");
    loadTrash();
  }

  Future<void> _deleteForever(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer définitivement"),
        content: const Text(
          "Cette note sera définitivement perdue. Voulez-vous continuer ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _noteController.deleteNotePermanently(note);
    if (!mounted) return;
    loadTrash();
  }

  Future<void> _emptyTrash() async {
    if (trashedNotes.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Vider la corbeille"),
        content: const Text(
          "Toutes les notes de la corbeille seront définitivement supprimées.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Vider"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _noteController.emptyTrash(widget.userId);
    if (!mounted) return;
    loadTrash();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Corbeille"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Vider la corbeille",
            onPressed: _emptyTrash,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trashedNotes.isEmpty
          ? Center(
              child: Text(
                "La corbeille est vide.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: trashedNotes.length,
              itemBuilder: (_, index) {
                final note = trashedNotes[index];

                return NoteCard(
                  note: note,
                  isTrash: true,
                  onRestore: () => _restore(note),
                  onDeleteForever: () => _deleteForever(note),
                );
              },
            ),
    );
  }
}
