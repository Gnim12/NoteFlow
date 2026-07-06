import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../utils/app_colors.dart';
import '../widgets/note_form.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  bool isFavorite = false;

  int selectedColor = 0xFF2563EB;

  bool isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveNote() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez saisir un titre."),
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez saisir une description."),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final note = Note(
      title: title,
      description: description,
      createdAt: DateTime.now(),
      color: selectedColor,
      isFavorite: isFavorite,
    );

    await DatabaseHelper.instance.insertNote(note);

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
        title: const Text("Nouvelle note"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: NoteForm(
          titleController: titleController,
          descriptionController: descriptionController,
          isFavorite: isFavorite,
          selectedColor: selectedColor,
          onFavoriteChanged: (value) {
            setState(() {
              isFavorite = value;
            });
          },
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : saveNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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

            label: Text(
              isSaving
                  ? "Enregistrement..."
                  : "Enregistrer",
            ),
          ),
        ),
      ),
    );
  }
}