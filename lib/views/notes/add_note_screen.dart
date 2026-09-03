import 'package:flutter/material.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/note_controller.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_presenter.dart';
import '../../models/category_model.dart';
import '../../models/location_model.dart';
import '../../models/note_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/note_form.dart';

class AddNoteScreen extends StatefulWidget {
  final String userId;

  const AddNoteScreen({super.key, required this.userId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isFavorite = false;

  int selectedColor = 0xFF2563EB;
  String? selectedCategoryId;
  List<String> tags = [];
  List<Category> categories = [];
  NoteLocation? location;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await CategoryController.instance.getCategories(
      widget.userId,
    );

    if (!mounted) return;

    setState(() {
      categories = result;
    });
  }

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
      ErrorPresenter.showError(
        context,
        AppError.validation('Veuillez saisir un titre.'),
      );
      return;
    }

    if (description.isEmpty) {
      ErrorPresenter.showError(
        context,
        AppError.validation('Veuillez saisir une description.'),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final now = DateTime.now();
    final note = Note(
      userId: widget.userId,
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      color: selectedColor,
      isFavorite: isFavorite,
      categoryId: selectedCategoryId,
      tags: tags,
      location: location,
    );

    await NoteController.instance.createNote(note);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          onCategoryChanged: (categoryId) {
            setState(() {
              selectedCategoryId = categoryId;
            });
          },
          tags: tags,
          onTagsChanged: (value) {
            setState(() {
              tags = value;
            });
          },
          location: location,
          onLocationChanged: (value) {
            setState(() {
              location = value;
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

            label: Text(isSaving ? "Enregistrement..." : "Enregistrer"),
          ),
        ),
      ),
    );
  }
}
