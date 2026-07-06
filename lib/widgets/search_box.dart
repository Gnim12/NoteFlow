import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSortSelected;

  const SearchBox({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black26
                : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: "Rechercher une note...",
          hintStyle: TextStyle(
            color: theme.hintColor,
          ),

          prefixIcon: Icon(
            Icons.search,
            color: theme.iconTheme.color,
          ),

          suffixIcon: PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              color: theme.iconTheme.color,
            ),
            onSelected: onSortSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "recent",
                child: Text("📅 Plus récentes"),
              ),
              PopupMenuItem(
                value: "old",
                child: Text("📅 Plus anciennes"),
              ),
              PopupMenuItem(
                value: "title",
                child: Text("🔤 Titre (A → Z)"),
              ),
              PopupMenuItem(
                value: "favorite",
                child: Text("⭐ Favoris"),
              ),
              PopupMenuItem(
                value: "color",
                child: Text("🎨 Couleur"),
              ),
            ],
          ),

          filled: true,
          fillColor: theme.cardColor,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}