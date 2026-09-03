import 'package:flutter/material.dart';

import '../controllers/location_controller.dart';
import '../models/category_model.dart';
import '../models/location_model.dart';
import '../utils/app_colors.dart';
import '../views/location/location_picker_screen.dart';

class NoteForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isFavorite;
  final int selectedColor;
  final ValueChanged<bool> onFavoriteChanged;
  final ValueChanged<int> onColorChanged;
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final NoteLocation? location;
  final ValueChanged<NoteLocation?> onLocationChanged;

  const NoteForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.isFavorite,
    required this.selectedColor,
    required this.onFavoriteChanged,
    required this.onColorChanged,
    this.categories = const [],
    this.selectedCategoryId,
    required this.onCategoryChanged,
    this.tags = const [],
    required this.onTagsChanged,
    this.location,
    required this.onLocationChanged,
  });

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final value = _tagController.text.trim();
    if (value.isEmpty || widget.tags.contains(value)) {
      _tagController.clear();
      return;
    }

    widget.onTagsChanged([...widget.tags, value]);
    _tagController.clear();
  }

  void _removeTag(String tag) {
    widget.onTagsChanged(widget.tags.where((t) => t != tag).toList());
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<NoteLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: widget.location),
      ),
    );

    if (result != null) {
      widget.onLocationChanged(result);
    }
  }

  void _removeLocation() {
    widget.onLocationChanged(null);
  }

  Future<void> _openLocation() async {
    final location = widget.location;
    if (location == null) return;

    await LocationController.instance.openInMapsApp(location);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [0xFF2563EB, 0xFF10B981, 0xFFF59E0B, 0xFFEF4444, 0xFF8B5CF6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Titre",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: widget.titleController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Titre de la note",
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "Description",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: widget.descriptionController,
          maxLines: 6,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Écrivez votre note...",
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),

        const SizedBox(height: 25),

        Text(
          "Couleur",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: colors.map((color) {
            final selected = widget.selectedColor == color;

            return GestureDetector(
              onTap: () => widget.onColorChanged(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 46 : 38,
                height: selected ? 46 : 38,
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

        const SizedBox(height: 25),

        Text(
          "Catégorie",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text("Aucune"),
              selected: widget.selectedCategoryId == null,
              onSelected: (_) => widget.onCategoryChanged(null),
            ),
            ...widget.categories.map((category) {
              final selected = widget.selectedCategoryId == category.id;

              return ChoiceChip(
                avatar: CircleAvatar(backgroundColor: Color(category.color)),
                label: Text(category.name),
                selected: selected,
                onSelected: (_) => widget.onCategoryChanged(category.id),
              );
            }),
          ],
        ),

        const SizedBox(height: 25),

        Text(
          "Tags",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addTag(),
                decoration: InputDecoration(
                  hintText: "Ajouter un tag",
                  hintStyle: TextStyle(color: theme.hintColor),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: _addTag,
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) {
              return Chip(
                label: Text("#$tag"),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),
        ],

        const SizedBox(height: 25),

        Text(
          "Localisation",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 10),

        if (widget.location == null)
          OutlinedButton.icon(
            onPressed: _pickLocation,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text("Ajouter une localisation"),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.place, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.location!.displayLabel,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: _openLocation,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("Ouvrir"),
                    ),
                    TextButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.edit_location_alt_outlined),
                      label: const Text("Modifier"),
                    ),
                    TextButton.icon(
                      onPressed: _removeLocation,
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      label: Text(
                        "Supprimer",
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 25),

        SwitchListTile(
          value: widget.isFavorite,
          onChanged: widget.onFavoriteChanged,
          activeThumbColor: AppColors.primary,
          title: Text(
            "Ajouter aux favoris ⭐",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
