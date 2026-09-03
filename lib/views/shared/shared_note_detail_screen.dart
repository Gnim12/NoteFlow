import 'package:flutter/material.dart';

import '../../controllers/sharing_controller.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_presenter.dart';
import '../../models/note_model.dart';
import '../../models/shared_note_model.dart';
import '../../utils/app_colors.dart';

/// Affiche une note partagée par un autre utilisateur. Contrairement à
/// [EditNoteScreen], tout se fait directement sur Firestore (pas de cache
/// SQLite ni de file de synchronisation) : une connexion est nécessaire.
class SharedNoteDetailScreen extends StatefulWidget {
  final Note note;
  final SharePermission permission;

  const SharedNoteDetailScreen({
    super.key,
    required this.note,
    required this.permission,
  });

  @override
  State<SharedNoteDetailScreen> createState() =>
      _SharedNoteDetailScreenState();
}

class _SharedNoteDetailScreenState extends State<SharedNoteDetailScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  bool isSaving = false;

  bool get canEdit => widget.permission == SharePermission.write;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    descriptionController = TextEditingController(
      text: widget.note.description,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ErrorPresenter.showError(
        context,
        AppError.validation('Veuillez remplir tous les champs.'),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await SharingController.instance.updateSharedNote(
        widget.note.copyWith(title: title, description: description),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ErrorPresenter.showError(
        context,
        AppError.persistence('Impossible d\'enregistrer (connexion requise).', e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(canEdit ? "Modifier (partagée)" : "Note partagée"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!canEdit)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, color: theme.hintColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text("Vous consultez cette note en lecture seule."),
                    ),
                  ],
                ),
              ),
            Text(
              "Titre",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              readOnly: !canEdit,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Description",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              readOnly: !canEdit,
              maxLines: 8,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: canEdit
          ? SafeArea(
              minimum: const EdgeInsets.all(20),
              child: SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? "Enregistrement..." : "Enregistrer"),
                ),
              ),
            )
          : null,
    );
  }
}
