import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/attachment_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/note_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../controllers/sharing_controller.dart';
import '../../core/errors/error_presenter.dart';
import '../../models/attachment_model.dart';
import '../../models/category_model.dart';
import '../../models/note_model.dart';
import '../../models/reminder_model.dart';
import '../../utils/app_colors.dart';
import '../location/location_picker_screen.dart';
import '../shared/share_note_dialog.dart';
import 'edit_note_screen.dart';

/// Vue en lecture seule d'une note : contenu, lieu et pièces jointes, avec
/// un accès rapide à la modification, au partage et à la suppression.
class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note note;

  Category? category;
  List<Reminder> reminders = [];
  List<Attachment> attachments = [];
  bool isLoading = true;

  /// Devient `true` dès que la note est modifiée ou déplacée vers la
  /// corbeille, pour que l'écran appelant sache qu'il doit se rafraîchir.
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    note = widget.note;
    _load();
  }

  Future<void> _load() async {
    final categories = await CategoryController.instance.getCategories(
      note.userId,
    );
    final loadedReminders = await ReminderController.instance.getReminders(
      note.id!,
    );
    final loadedAttachments = await AttachmentController.instance
        .getAttachments(note.id!);

    if (!mounted) return;

    final matches = categories.where((c) => c.id == note.categoryId);

    setState(() {
      category = matches.isEmpty ? null : matches.first;
      reminders = loadedReminders;
      attachments = loadedAttachments;
      isLoading = false;
    });
  }

  Reminder? get _nextReminder {
    final upcoming = reminders.where((r) => r.enabled).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  String _dayLabel(DateTime dateTime) {
    final now = DateTime.now();
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return "Aujourd'hui ${DateFormat('HH:mm').format(dateTime)}";
    if (diff == 1) return "Demain ${DateFormat('HH:mm').format(dateTime)}";
    return DateFormat("dd MMM, HH:mm").format(dateTime);
  }

  Future<void> _edit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)),
    );

    if (result != true || !mounted) return;

    final refreshed = await NoteController.instance.getNoteById(
      note.id!,
      note.userId,
    );
    if (!mounted || refreshed == null) return;

    setState(() {
      note = refreshed;
      _changed = true;
    });
    _load();
  }

  Future<void> _share() async {
    final draft = await showShareNoteDialog(context);
    if (draft == null) return;

    final result = await SharingController.instance.shareNote(
      note: note,
      email: draft.email,
      permission: draft.permission,
    );

    if (!mounted) return;

    if (result.isFailure) {
      ErrorPresenter.showError(context, result.error!);
      return;
    }

    ErrorPresenter.showSuccess(context, "Note partagée avec ${draft.email}.");
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Déplacer vers la corbeille"),
        content: const Text(
          "Voulez-vous déplacer cette note vers la corbeille ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déplacer"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await NoteController.instance.moveToTrash(note);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _openAttachment(Attachment attachment) {
    if (attachment.type != AttachmentType.image) {
      ErrorPresenter.showSuccess(context, attachment.fileName);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(child: Image.file(File(attachment.localPath))),
      ),
    );
  }

  void _viewOnMap() {
    if (note.location == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: note.location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextReminder = _nextReminder;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onSurface,
          title: const Text(
            "NoteFlow",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: "Modifier",
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (category != null)
                          _Badge(
                            icon: Icons.folder_outlined,
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

                    const SizedBox(height: 16),

                    Text(
                      note.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 18,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 15,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                "dd MMM yyyy, HH:mm",
                              ).format(note.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                        if (nextReminder != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_active_outlined,
                                size: 15,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _dayLabel(nextReminder.dateTime),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        note.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),

                    if (note.location != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: .12),
                              child: Icon(
                                Icons.location_on,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Lieu",
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    note.location!.placeName ??
                                        note.location!.address ??
                                        "${note.location!.latitude.toStringAsFixed(5)}, "
                                            "${note.location!.longitude.toStringAsFixed(5)}",
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: _viewOnMap,
                                    child: Text(
                                      "Voir sur la carte",
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Pièces jointes (${attachments.length})",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: attachments.map((attachment) {
                            return ListTile(
                              leading: attachment.type == AttachmentType.image
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(attachment.localPath),
                                        width: 42,
                                        height: 42,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: theme
                                          .colorScheme
                                          .error
                                          .withValues(alpha: .12),
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                              title: Text(
                                attachment.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _openAttachment(attachment),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _edit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text("Modifier"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _share,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text("Partager"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: TextButton.icon(
                        onPressed: _delete,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Supprimer"),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;

  const _Badge({this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
