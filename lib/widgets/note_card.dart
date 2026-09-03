import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/category_model.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Category? category;
  final bool isTrash;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final VoidCallback? onPin;
  final VoidCallback? onRestore;
  final VoidCallback? onDeleteForever;

  const NoteCard({
    super.key,
    required this.note,
    this.category,
    this.isTrash = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFavorite,
    this.onPin,
    this.onRestore,
    this.onDeleteForever,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Row(
          children: [
            // Barre colorée
            Container(
              width: 8,
              height: 110,
              decoration: BoxDecoration(
                color: Color(note.color),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// =====================
                    /// TITRE
                    /// =====================
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),

                        if (note.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.push_pin,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                          ),

                        if (note.isFavorite)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),

                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case "edit":
                                onEdit?.call();
                                break;

                              case "pin":
                                onPin?.call();
                                break;

                              case "favorite":
                                onFavorite?.call();
                                break;

                              case "delete":
                                onDelete?.call();
                                break;

                              case "restore":
                                onRestore?.call();
                                break;

                              case "delete_forever":
                                onDeleteForever?.call();
                                break;
                            }
                          },
                          itemBuilder: (context) => isTrash
                              ? [
                                  const PopupMenuItem(
                                    value: "restore",
                                    child: ListTile(
                                      leading: Icon(Icons.restore),
                                      title: Text("Restaurer"),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: "delete_forever",
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.delete_forever,
                                        color: theme.colorScheme.error,
                                      ),
                                      title: Text(
                                        "Supprimer définitivement",
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                              : [
                                  const PopupMenuItem(
                                    value: "edit",
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text("Modifier"),
                                    ),
                                  ),

                                  PopupMenuItem(
                                    value: "pin",
                                    child: ListTile(
                                      leading: Icon(
                                        note.isPinned
                                            ? Icons.push_pin
                                            : Icons.push_pin_outlined,
                                      ),
                                      title: Text(
                                        note.isPinned
                                            ? "Désépingler"
                                            : "Épingler",
                                      ),
                                    ),
                                  ),

                                  PopupMenuItem(
                                    value: "favorite",
                                    child: ListTile(
                                      leading: Icon(
                                        note.isFavorite
                                            ? Icons.star
                                            : Icons.star_border,
                                      ),
                                      title: Text(
                                        note.isFavorite
                                            ? "Retirer des favoris"
                                            : "Ajouter aux favoris",
                                      ),
                                    ),
                                  ),

                                  const PopupMenuDivider(),

                                  PopupMenuItem(
                                    value: "delete",
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.delete,
                                        color: theme.colorScheme.error,
                                      ),
                                      title: Text(
                                        "Supprimer",
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// =====================
                    /// DESCRIPTION
                    /// =====================
                    Text(
                      note.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    if (category != null || note.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (category != null)
                            _Badge(
                              label: category!.name,
                              color: Color(category!.color),
                            ),
                          ...note.tags.map(
                            (tag) => _Badge(
                              label: "#$tag",
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),

                    /// =====================
                    /// DATE & HEURE
                    /// =====================
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 15,
                          color: theme.hintColor,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          DateFormat("dd MMM yyyy").format(note.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),

                        const Spacer(),

                        Icon(
                          Icons.access_time,
                          size: 15,
                          color: theme.hintColor,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          DateFormat("HH:mm").format(note.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
