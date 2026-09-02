import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/note_controller.dart';
import '../../models/note_model.dart';
import '../../models/user_model.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/header_home.dart';
import '../../widgets/note_card.dart';
import '../../widgets/search_box.dart';
import '../notes/add_note_screen.dart';
import '../notes/edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteController _noteController = NoteController.instance;

  int totalNotes = 0;
  int totalFavorites = 0;
  int todayNotes = 0;
  String selectedSort = "recent";
  List<Note> notes = [];
  List<Note> filteredNotes = [];

  bool isLoading = true;
  User? currentUser;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await loadCurrentUser();
    await loadNotes();
  }

  Future<void> loadCurrentUser() async {
    currentUser = AuthController.instance.currentUser;
  }

  Future<void> loadNotes() async {
    final result = await _noteController.getNotes(widget.user.id);
    final sorted = _noteController.sortPinnedFirst(result);

    setState(() {
      notes = sorted;
      filteredNotes = sorted;

      totalNotes = sorted.length;
      totalFavorites = _noteController.favoritesOnly(sorted).length;
      todayNotes = _noteController.createdToday(sorted).length;

      isLoading = false;
    });
  }

  void searchNotes(String query) {
    setState(() {
      filteredNotes = _noteController.search(notes, query);
    });
  }

  void sortNotes(String sortType) {
    setState(() {
      selectedSort = sortType;
      filteredNotes = _noteController.sort(filteredNotes, sortType);
    });
  }

  void showAllNotes() {
    setState(() {
      filteredNotes = List.from(notes);
    });
  }

  void showFavorites() {
    setState(() {
      filteredNotes = _noteController.favoritesOnly(notes);
    });
  }

  void showTodayNotes() {
    setState(() {
      filteredNotes = _noteController.createdToday(notes);
    });
  }

  Future<void> openAddNoteScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddNoteScreen(userId: widget.user.id)),
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
        content: const Text("Voulez-vous vraiment supprimer cette note ?"),
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
      await _noteController.deleteNote(id: note.id!, userId: note.userId);
      loadNotes();
    }
  }

  Future<void> toggleFavorite(Note note) async {
    await _noteController.toggleFavorite(note);
    loadNotes();
  }

  Future<void> togglePin(Note note) async {
    await _noteController.togglePin(note);
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: openAddNoteScreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadNotes,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeaderHome(user: currentUser ?? widget.user),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          DashboardCard(
                            icon: Icons.note_alt_rounded,
                            title: "Notes",
                            value: totalNotes.toString(),
                            color: const Color(0xFF3B82F6),
                            onTap: showAllNotes,
                          ),
                          DashboardCard(
                            icon: Icons.star_rounded,
                            title: "Favoris",
                            value: totalFavorites.toString(),
                            color: const Color(0xFFF4B400),
                            onTap: showFavorites,
                          ),
                          DashboardCard(
                            icon: Icons.calendar_today_rounded,
                            title: "Aujourd'hui",
                            value: todayNotes.toString(),
                            color: const Color(0xFF34A853),
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
                    ],
                  ),
                ),
              ),
              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredNotes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 90,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Aucune note trouvée",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Essayez un autre mot-clé.",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NoteCard(
                          note: filteredNotes[index],
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditNoteScreen(note: filteredNotes[index]),
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
                                builder: (_) =>
                                    EditNoteScreen(note: filteredNotes[index]),
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
                        ),
                      );
                    }, childCount: filteredNotes.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
