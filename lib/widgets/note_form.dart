import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class NoteForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isFavorite;
  final int selectedColor;
  final ValueChanged<bool> onFavoriteChanged;
  final ValueChanged<int> onColorChanged;

  const NoteForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.isFavorite,
    required this.selectedColor,
    required this.onFavoriteChanged,
    required this.onColorChanged,
  });

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
          controller: titleController,
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
          controller: descriptionController,
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
            final selected = selectedColor == color;

            return GestureDetector(
              onTap: () => onColorChanged(color),
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

        SwitchListTile(
          value: isFavorite,
          onChanged: onFavoriteChanged,
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
