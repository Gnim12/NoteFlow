import 'package:flutter/material.dart';

import '../../controllers/note_controller.dart';
import '../../models/note_model.dart';
import '../../widgets/note_card.dart';
import 'edit_note_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final String userId;

  const FavoritesScreen({super.key, required this.userId});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final NoteController _noteController = NoteController.instance;

  List<Note> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final notes = await _noteController.getNotes(widget.userId);

    if (!mounted) return;

    setState(() {
      favorites = _noteController.favoritesOnly(notes);
      isLoading = false;
    });
  }

  Future<void> _openNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)),
    );

    if (result == true) load();
  }

  Future<void> _delete(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Déplacer vers la corbeille"),
        content: const Text("Voulez-vous déplacer cette note vers la corbeille ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déplacer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _noteController.moveToTrash(note);
      load();
    }
  }

  Future<void> _toggleFavorite(Note note) async {
    await _noteController.toggleFavorite(note);
    load();
  }

  Future<void> _togglePin(Note note) async {
    await _noteController.togglePin(note);
    load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Favoris")),
      body: RefreshIndicator(
        onRefresh: load,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favorites.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      "Aucune note favorite pour l'instant.",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: favorites.length,
                itemBuilder: (_, index) {
                  final note = favorites[index];

                  return NoteCard(
                    note: note,
                    onTap: () => _openNote(note),
                    onEdit: () => _openNote(note),
                    onDelete: () => _delete(note),
                    onFavorite: () => _toggleFavorite(note),
                    onPin: () => _togglePin(note),
                  );
                },
              ),
      ),
    );
  }
}
