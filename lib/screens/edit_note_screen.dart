import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../utils/app_colors.dart';
import '../widgets/note_form.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;

  const EditNoteScreen({
    super.key,
    required this.note,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late bool isFavorite;
  late int selectedColor;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.note.title);

    descriptionController =
        TextEditingController(
      text: widget.note.description,
    );

    isFavorite = widget.note.isFavorite;
    selectedColor = widget.note.color;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateNote() async {
    final title = titleController.text.trim();
    final description =
        descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final updatedNote = widget.note.copyWith(
      title: title,
      description: description,
      color: selectedColor,
      isFavorite: isFavorite,
    );

    await DatabaseHelper.instance
        .updateNote(updatedNote);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text(
          "Modifier la note",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: NoteForm(
          titleController: titleController,
          descriptionController:
              descriptionController,
          isFavorite: isFavorite,
          selectedColor: selectedColor,
          onFavoriteChanged: (value) {
            setState(() {
              isFavorite = value;
            });
          },
          onColorChanged: (value) {
            setState(() {
              selectedColor = value;
            });
          },
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),

        child: SizedBox(
          height: 55,

          child: ElevatedButton.icon(
            onPressed:
                isSaving ? null : updateNote,

            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.primary,
              foregroundColor:
                  Colors.white,
            ),

            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),

            label: Text(
              isSaving
                  ? "Modification..."
                  : "Enregistrer",
            ),
          ),
        ),
      ),
    );
  }
}