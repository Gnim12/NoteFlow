import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../providers/theme_provider.dart';
import '../services/pdf_service.dart';
import 'login_screen.dart';
import 'pinned_notes_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
      await DatabaseHelper.instance.deleteAllNotes();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Toutes les notes ont été supprimées.",
            ),
          ),
        );
      }
    }
  }

  // =====================================================
  // EXPORT PDF
  // =====================================================

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final List<Note> notes =
          await DatabaseHelper.instance.getNotes();

      if (notes.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Aucune note à exporter.",
              ),
            ),
          );
        }
        return;
      }

      await PdfService.exportNotes(notes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur lors de l'export : $e",
            ),
          ),
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
        content: const Text(
          "Voulez-vous vraiment vous déconnecter ?",
        ),
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
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
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 8,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? Colors.blue,
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Paramètres"),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 20),

          // ==========================================
          // MODE SOMBRE
          // ==========================================

          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            child: SwitchListTile(
              secondary: const Icon(
                Icons.dark_mode,
                color: Colors.indigo,
              ),
              title: const Text("Mode sombre"),
              subtitle: const Text(
                "Activer le thème sombre",
              ),
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
            icon: Icons.push_pin,
            title: "Notes épinglées",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PinnedNotesScreen(),
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
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "NoteFlow",
                applicationVersion: "1.0.0",
                applicationLegalese:
                    "© 2026 NoteFlow\nProjet Flutter DCLIC",
              );
            },
          ),

          const SizedBox(height: 40),

          const Center(
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Center(
            child: Text(
              "Développé avec Flutter",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}