import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../notes/add_note_screen.dart';
import '../notes/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../reminders/reminders_screen.dart';
import 'home_screen.dart';

/// Coquille principale de l'application une fois connecté : porte la barre
/// de navigation (Notes, Favoris, Ajouter, Rappels, Profil) et bascule entre
/// les écrans correspondants sans perdre l'état de chacun.
class MainShellScreen extends StatefulWidget {
  final User user;

  const MainShellScreen({super.key, required this.user});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _tabIndex = 0;

  // Incrémentés pour forcer le rechargement des onglets Notes/Favoris après
  // l'ajout d'une note depuis le bouton central.
  int _homeRefreshTick = 0;
  int _favoritesRefreshTick = 0;

  Future<void> _openAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNoteScreen(userId: widget.user.id),
      ),
    );

    if (result == true) {
      setState(() {
        _homeRefreshTick++;
        _favoritesRefreshTick++;
      });
    }
  }

  void _onTabTap(int index) {
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(key: ValueKey('home_$_homeRefreshTick'), user: widget.user),
      FavoritesScreen(
        key: ValueKey('favorites_$_favoritesRefreshTick'),
        userId: widget.user.id,
      ),
      const SizedBox.shrink(), // "Ajouter" n'est pas un onglet persistant.
      RemindersScreen(userId: widget.user.id),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: pages),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _tabIndex,
        onTap: _onTabTap,
        onAddPressed: _openAddNote,
      ),
    );
  }
}
