import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/errors/app_error.dart';
import '../core/errors/error_presenter.dart';
import '../models/note.dart';
import '../providers/theme_provider.dart';
import '../repositories/notes_repository.dart';
import '../services/pdf_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import 'pinned_notes_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  final int userId;

  const SettingsScreen({super.key, required this.userId});

  static final Uri _privacyPolicyUrl = Uri.parse(
    'https://gnim12.github.io/noteflow-legal/',
  );

  static final Uri _termsOfUseUrl = Uri.parse(
    'https://gnim12.github.io/noteflow-legal/',
  );

  // =====================================================
  // SUPPRIMER TOUTES LES NOTES
  // =====================================================

  Future<void> _deleteAllNotes(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer toutes les notes"),
        content: const Text(
          "Cette action est irréversible.\n\nVoulez-vous continuer ?",
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
      await NotesRepository.instance.deleteAllNotes(userId);

      if (context.mounted) {
        ErrorPresenter.showSuccess(
          context,
          'Toutes les notes ont été supprimées.',
        );
      }
    }
  }

  // =====================================================
  // EXPORT PDF
  // =====================================================

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final List<Note> notes = await NotesRepository.instance.getNotes(userId);

      if (notes.isEmpty) {
        if (context.mounted) {
          ErrorPresenter.showError(
            context,
            AppError.validation('Aucune note à exporter.'),
          );
        }
        return;
      }

      await PdfService.exportNotes(notes);
    } catch (e) {
      if (context.mounted) {
        ErrorPresenter.showError(
          context,
          AppError.persistence('Erreur lors de l’export PDF.', e),
        );
      }
    }
  }

  // =====================================================
  // DÉCONNEXION
  // =====================================================

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déconnexion"),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await SessionService.instance.logout();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _openExternalLink(BuildContext context, Uri url) async {
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ErrorPresenter.showError(
        context,
        AppError.unexpected('Impossible d’ouvrir le lien.'),
      );
    }
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("À propos"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NoteFlow",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Version 1.0.0"),
            const SizedBox(height: 8),
            Text(
              "© 2026 NoteFlow\nProjet Flutter DCLIC",
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _openExternalLink(context, _privacyPolicyUrl),
              child: const Text("Politique de confidentialité"),
            ),
            TextButton(
              onPressed: () => _openExternalLink(context, _termsOfUseUrl),
              child: const Text("Conditions d’utilisation"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // WIDGET CARTE
  // =====================================================

  Widget buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(title: const Text("Paramètres")),

      body: ListView(
        children: [
          const SizedBox(height: 20),

          // ==========================================
          // MODE SOMBRE
          // ==========================================
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: Colors.indigo),
              title: const Text("Mode sombre"),
              subtitle: const Text("Activer le thème sombre"),
              value: themeProvider.isDark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ),

          // ==========================================
          // NOTES ÉPINGLÉES
          // ==========================================
          buildTile(
            icon: Icons.person,
            title: "Mon profil",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          buildTile(
            icon: Icons.push_pin,
            title: "Notes épinglées",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PinnedNotesScreen(userId: userId),
                ),
              );
            },
          ),

          // ==========================================
          // EXPORT PDF
          // ==========================================
          buildTile(
            icon: Icons.picture_as_pdf,
            title: "Exporter les notes (PDF)",
            onTap: () => _exportPdf(context),
          ),

          // ==========================================
          // SUPPRIMER TOUTES LES NOTES
          // ==========================================
          buildTile(
            icon: Icons.delete_forever,
            color: Colors.red,
            title: "Supprimer toutes les notes",
            onTap: () => _deleteAllNotes(context),
          ),

          // ==========================================
          // DÉCONNEXION
          // ==========================================
          buildTile(
            icon: Icons.logout,
            color: Colors.orange,
            title: "Se déconnecter",
            onTap: () => _logout(context),
          ),

          // ==========================================
          // À PROPOS
          // ==========================================
          buildTile(
            icon: Icons.info_outline,
            title: "À propos",
            onTap: () => _showAboutDialog(context),
          ),

          const SizedBox(height: 40),

          Center(
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              "Développé avec Flutter",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
