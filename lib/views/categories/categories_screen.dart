import 'package:flutter/material.dart';

import '../../controllers/category_controller.dart';
import '../../core/errors/error_presenter.dart';
import '../../models/category_model.dart';

const _categoryColors = [
  0xFF2563EB,
  0xFF10B981,
  0xFFF59E0B,
  0xFFEF4444,
  0xFF8B5CF6,
  0xFFEC4899,
];

class CategoriesScreen extends StatefulWidget {
  final String userId;

  const CategoriesScreen({super.key, required this.userId});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryController _controller = CategoryController.instance;

  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await _controller.getCategories(widget.userId);

    if (!mounted) return;

    setState(() {
      categories = result;
      isLoading = false;
    });
  }

  Future<void> _openCategoryDialog({Category? category}) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    int selectedColor = category?.color ?? _categoryColors.first;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(category == null ? "Nouvelle catégorie" : "Modifier la catégorie"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: "Nom de la catégorie"),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: _categoryColors.map((color) {
                      final selected = selectedColor == color;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? Colors.black : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Enregistrer"),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;

    final name = nameController.text.trim();
    if (name.isEmpty) return;

    if (category == null) {
      await _controller.createCategory(
        userId: widget.userId,
        name: name,
        color: selectedColor,
      );
    } else {
      await _controller.updateCategory(
        category.copyWith(name: name, color: selectedColor),
      );
    }

    if (!mounted) return;
    loadCategories();
  }

  Future<void> _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer la catégorie"),
        content: Text(
          "Les notes associées à \"${category.name}\" redeviendront sans catégorie.",
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

    if (confirm != true) return;

    await _controller.deleteCategory(id: category.id!, userId: widget.userId);

    if (!mounted) return;
    ErrorPresenter.showSuccess(context, "Catégorie supprimée.");
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catégories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? Center(
              child: Text(
                "Aucune catégorie pour l'instant.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(category.color),
                    ),
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openCategoryDialog(category: category),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
