import 'package:flutter/material.dart';
import 'edit_note_screen.dart';
import '../database/database_helper.dart';
import '../models/note.dart';
import '../widgets/header_home.dart';
import '../widgets/note_card.dart';
import '../widgets/search_box.dart';
import 'add_note_screen.dart';
import 'package:diacritic/diacritic.dart';
import '../widgets/dashboard_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalNotes = 0;
  int totalFavorites = 0;
  int todayNotes = 0;
  String selectedSort = "recent";
  List<Note> notes = [];
  List<Note> filteredNotes = [];

  bool isLoading = true;

  final TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final result = await DatabaseHelper.instance.getNotes();
    result.sort((a, b) {
      if (a.isPinned == b.isPinned) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return a.isPinned ? -1 : 1;
    });

    setState(() {
    notes = result;
    filteredNotes = result;

    totalNotes = result.length;

    totalFavorites = result
        .where((e) => e.isFavorite)
        .length;

    todayNotes = result.where((note) {
      final now = DateTime.now();

      return note.createdAt.year == now.year &&
          note.createdAt.month == now.month &&
          note.createdAt.day == now.day;
    }).length;

    isLoading = false;
  });
  }
  void searchNotes(String query) {
    final search = removeDiacritics(
      query.toLowerCase().trim(),
    );

    if (search.isEmpty) {
      setState(() {
        filteredNotes = List.from(notes);
      });
      return;
    }

    final results = notes.where((note) {
      final title = removeDiacritics(
        note.title.toLowerCase(),
      );

      final description = removeDiacritics(
        note.description.toLowerCase(),
      );

      return title.contains(search) ||
          description.contains(search);
    }).toList();

    setState(() {
      filteredNotes = results;
    });
  }
  void sortNotes(String sortType) {
    setState(() {
      selectedSort = sortType;

      switch (sortType) {
        case "recent":
          filteredNotes.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          break;

        case "old":
          filteredNotes.sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
          );
          break;

        case "title":
          filteredNotes.sort(
            (a, b) => a.title.compareTo(b.title),
          );
          break;

        case "favorite":
          filteredNotes.sort(
            (a, b) => b.isFavorite
                .toString()
                .compareTo(a.isFavorite.toString()),
          );
          break;

        case "color":
          filteredNotes.sort(
            (a, b) => a.color.compareTo(b.color),
          );
          break;
      }
    });
  }
  void showAllNotes() {
    setState(() {
      filteredNotes = List.from(notes);
    });
  }

  void showFavorites() {
    setState(() {
      filteredNotes =
          notes.where((e) => e.isFavorite).toList();
    });
  }

  void showTodayNotes() {
    final now = DateTime.now();

    setState(() {
      filteredNotes = notes.where((note) {
        return note.createdAt.year == now.year &&
            note.createdAt.month == now.month &&
            note.createdAt.day == now.day;
      }).toList();
    });
  }

  Future<void> openAddNoteScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddNoteScreen(),
      ),
    );

    if (result == true) {
      loadNotes();
    }
  }
  Future<void> deleteNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Supprimer"),
        content: const Text(
          "Voulez-vous vraiment supprimer cette note ?",
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

    if (confirm == true) {
      await DatabaseHelper.instance.deleteNote(note.id!);
      loadNotes();
    }
  }

  Future<void> toggleFavorite(Note note) async {
    final updated = note.copyWith(
      isFavorite: !note.isFavorite,
    );

    await DatabaseHelper.instance.updateNote(updated);

    loadNotes();
  }
  Future<void> togglePin(Note note) async {

    final updated = note.copyWith(
      isPinned: !note.isPinned,
    );

    await DatabaseHelper.instance
        .updateNote(updated);

    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: openAddNoteScreen,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadNotes,
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                HeaderHome(
                  username: widget.username,
                ),

                const SizedBox(height: 20),

                  Row(
                    children: [

                      DashboardCard(
                        icon: Icons.note_alt_rounded,
                        title: "Notes",
                        value: totalNotes.toString(),
                        color: const Color(0xFF3B82F6), // Bleu
                        onTap: showAllNotes,
                      ),

                      DashboardCard(
                        icon: Icons.star_rounded,
                        title: "Favoris",
                        value: totalFavorites.toString(),
                        color: const Color(0xFFF4B400), // Jaune doré
                        onTap: showFavorites,
                      ),

                      DashboardCard(
                        icon: Icons.calendar_today_rounded,
                        title: "Aujourd'hui",
                        value: todayNotes.toString(),
                        color: const Color(0xFF34A853), // Vert
                        onTap: showTodayNotes,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                SearchBox(
                  controller: searchController,
                  onChanged: searchNotes,
                  onSortSelected: sortNotes,
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : filteredNotes.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 90,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Aucune note trouvée",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Essayez un autre mot-clé.",
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, index) {
                                return NoteCard(
                                  note: filteredNotes[index],

                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditNoteScreen(
                                          note: filteredNotes[index],
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      loadNotes();
                                    }
                                  },

                                  onEdit: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditNoteScreen(
                                          note: filteredNotes[index],
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      loadNotes();
                                    }
                                  },

                                  onDelete: () {
                                    deleteNote(filteredNotes[index]);
                                  },

                                  onFavorite: () {
                                    toggleFavorite(filteredNotes[index]);
                                  },

                                  onPin: () {
                                    togglePin(filteredNotes[index]);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}