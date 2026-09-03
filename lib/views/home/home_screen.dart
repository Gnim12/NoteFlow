import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/note_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../models/category_model.dart';
import '../../models/note_model.dart';
import '../../models/user_model.dart';
import '../../services/sync_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/header_home.dart';
import '../../widgets/note_card.dart';
import '../../widgets/search_box.dart';
import '../../widgets/sync_status_badge.dart';
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
  final CategoryController _categoryController = CategoryController.instance;

  int totalNotes = 0;
  int totalFavorites = 0;
  int todayNotes = 0;
  String selectedSort = "recent";
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  List<Category> categories = [];
  String? selectedCategoryId;

  bool isLoading = true;
  User? currentUser;
  int pendingSyncCount = 0;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SyncService.instance.watchConnectivity(widget.user.id);
    initialize();
  }

  @override
  void dispose() {
    SyncService.instance.stopWatchingConnectivity();
    searchController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    await loadCurrentUser();
    await _noteController.syncFromCloud(widget.user.id);
    await loadNotes();
    // Android annule les alarmes programmées après un redémarrage : on les
    // reprogramme à chaque ouverture de l'accueil.
    ReminderController.instance.rescheduleAll(widget.user.id);
  }

  Future<void> loadCurrentUser() async {
    currentUser = AuthController.instance.currentUser;
  }

  Future<void> loadNotes() async {
    final result = await _noteController.getNotes(widget.user.id);
    final sorted = _noteController.sortPinnedFirst(result);
    final pending = await _noteController.pendingSyncCount(widget.user.id);
    final loadedCategories = await _categoryController.getCategories(
      widget.user.id,
    );

    if (!mounted) return;

    setState(() {
      notes = sorted;
      categories = loadedCategories;
      filteredNotes = _applyCategoryFilter(sorted);

      totalNotes = sorted.length;
      totalFavorites = _noteController.favoritesOnly(sorted).length;
      todayNotes = _noteController.createdToday(sorted).length;
      pendingSyncCount = pending;

      isLoading = false;
    });
  }

  List<Note> _applyCategoryFilter(List<Note> source) {
    return _noteController.filterByCategory(source, selectedCategoryId);
  }

  void searchNotes(String query) {
    setState(() {
      filteredNotes = _noteController.search(
        _applyCategoryFilter(notes),
        query,
      );
    });
  }

  void sortNotes(String sortType) {
    setState(() {
      selectedSort = sortType;
      filteredNotes = _noteController.sort(filteredNotes, sortType);
    });
  }

  void filterByCategory(String? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      filteredNotes = _applyCategoryFilter(notes);
    });
  }

  void showAllNotes() {
    setState(() {
      selectedCategoryId = null;
      filteredNotes = List.from(notes);
    });
  }

  void showFavorites() {
    setState(() {
      filteredNotes = _noteController.favoritesOnly(_applyCategoryFilter(notes));
    });
  }

  void showTodayNotes() {
    setState(() {
      filteredNotes = _noteController.createdToday(_applyCategoryFilter(notes));
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
                      const SizedBox(height: 12),
                      SyncStatusBadge(pendingCount: pendingSyncCount),
                      const SizedBox(height: 8),
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
                      if (categories.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ChoiceChip(
                                label: const Text("Toutes"),
                                selected: selectedCategoryId == null,
                                onSelected: (_) => filterByCategory(null),
                              ),
                              const SizedBox(width: 8),
                              ...categories.map(
                                (category) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    avatar: CircleAvatar(
                                      backgroundColor: Color(category.color),
                                    ),
                                    label: Text(category.name),
                                    selected: selectedCategoryId == category.id,
                                    onSelected: (_) =>
                                        filterByCategory(category.id),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      final categoryId = filteredNotes[index].categoryId;
                      final matches = categories.where((c) => c.id == categoryId);
                      final category = matches.isEmpty ? null : matches.first;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NoteCard(
                          note: filteredNotes[index],
                          category: category,
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
