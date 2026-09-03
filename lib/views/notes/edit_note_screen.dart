import 'dart:io';

import 'package:flutter/material.dart';

import '../../controllers/attachment_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/note_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../controllers/sharing_controller.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_presenter.dart';
import '../../models/attachment_model.dart';
import '../../models/category_model.dart';
import '../../models/location_model.dart';
import '../../models/note_model.dart';
import '../../models/reminder_model.dart';
import '../../models/shared_note_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/attachment_list.dart';
import '../../widgets/note_form.dart';
import '../../widgets/reminder_tile.dart';
import '../../widgets/share_tile.dart';
import '../reminders/reminder_form_dialog.dart';
import '../shared/share_note_dialog.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late bool isFavorite;
  late int selectedColor;
  late String? selectedCategoryId;
  late List<String> tags;
  NoteLocation? location;
  List<Category> categories = [];
  List<Attachment> attachments = [];
  bool isLoadingAttachments = true;
  List<Reminder> reminders = [];
  bool isLoadingReminders = true;
  List<SharedNote> shares = [];
  bool isLoadingShares = true;

  bool isSaving = false;

  final AttachmentController _attachmentController =
      AttachmentController.instance;
  final ReminderController _reminderController = ReminderController.instance;
  final SharingController _sharingController = SharingController.instance;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.note.title);

    descriptionController = TextEditingController(
      text: widget.note.description,
    );

    isFavorite = widget.note.isFavorite;
    selectedColor = widget.note.color;
    selectedCategoryId = widget.note.categoryId;
    tags = List.from(widget.note.tags);
    location = widget.note.location;

    loadCategories();
    loadAttachments();
    loadReminders();
    loadShares();
  }

  Future<void> loadShares() async {
    final result = await _sharingController.getSharesForNote(widget.note);

    if (!mounted) return;

    setState(() {
      shares = result;
      isLoadingShares = false;
    });
  }

  Future<void> _shareNote() async {
    final draft = await showShareNoteDialog(context);
    if (draft == null) return;

    final result = await _sharingController.shareNote(
      note: widget.note,
      email: draft.email,
      permission: draft.permission,
    );

    if (!mounted) return;

    if (result.isFailure) {
      ErrorPresenter.showError(context, result.error!);
      return;
    }

    ErrorPresenter.showSuccess(context, "Note partagée avec ${draft.email}.");
    loadShares();
  }

  Future<void> _revokeShare(SharedNote share) async {
    await _sharingController.revokeShare(share.id);
    loadShares();
  }

  Future<void> loadReminders() async {
    final result = await _reminderController.getReminders(widget.note.id!);

    if (!mounted) return;

    setState(() {
      reminders = result;
      isLoadingReminders = false;
    });
  }

  Future<void> _addReminder() async {
    final draft = await showReminderFormDialog(context);
    if (draft == null) return;

    await _reminderController.createReminder(
      note: widget.note,
      dateTime: draft.dateTime,
      recurrence: draft.recurrence,
      customIntervalDays: draft.customIntervalDays,
    );

    loadReminders();
  }

  Future<void> _editReminder(Reminder reminder) async {
    final draft = await showReminderFormDialog(context, initial: reminder);
    if (draft == null) return;

    await _reminderController.updateReminder(
      reminder: reminder.copyWith(
        dateTime: draft.dateTime,
        recurrence: draft.recurrence,
        customIntervalDays: draft.customIntervalDays,
      ),
      note: widget.note,
    );

    loadReminders();
  }

  Future<void> _toggleReminder(Reminder reminder, bool enabled) async {
    await _reminderController.updateReminder(
      reminder: reminder.copyWith(enabled: enabled),
      note: widget.note,
    );

    loadReminders();
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer le rappel"),
        content: const Text("Voulez-vous supprimer ce rappel ?"),
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

    await _reminderController.deleteReminder(reminder);
    loadReminders();
  }

  Future<void> loadCategories() async {
    final result = await CategoryController.instance.getCategories(
      widget.note.userId,
    );

    if (!mounted) return;

    setState(() {
      categories = result;
    });
  }

  Future<void> loadAttachments() async {
    await _attachmentController.retryPendingUploads(widget.note.id!);
    final result = await _attachmentController.getAttachments(
      widget.note.id!,
    );

    if (!mounted) return;

    setState(() {
      attachments = result;
      isLoadingAttachments = false;
    });
  }

  Future<void> _pickAttachment() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              const ListTile(
                title: Center(
                  child: Text(
                    "Ajouter une pièce jointe",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Image depuis la galerie"),
                onTap: () => Navigator.pop(context, "gallery"),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Prendre une photo"),
                onTap: () => Navigator.pop(context, "camera"),
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text("Fichier"),
                onTap: () => Navigator.pop(context, "file"),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Annuler"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );

    if (choice == null) return;

    Attachment? attachment;

    switch (choice) {
      case "gallery":
        attachment = await _attachmentController.addImageFromGallery(
          noteId: widget.note.id!,
          userId: widget.note.userId,
        );
        break;
      case "camera":
        attachment = await _attachmentController.addImageFromCamera(
          noteId: widget.note.id!,
          userId: widget.note.userId,
        );
        break;
      case "file":
        attachment = await _attachmentController.addFile(
          noteId: widget.note.id!,
          userId: widget.note.userId,
        );
        break;
    }

    if (attachment == null || !mounted) return;

    setState(() {
      attachments = [...attachments, attachment!];
    });
  }

  Future<void> _deleteAttachment(Attachment attachment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer la pièce jointe"),
        content: Text("Supprimer \"${attachment.fileName}\" ?"),
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

    await _attachmentController.deleteAttachment(attachment);

    if (!mounted) return;

    setState(() {
      attachments = attachments.where((a) => a.id != attachment.id).toList();
    });
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateNote() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ErrorPresenter.showError(
        context,
        AppError.validation('Veuillez remplir tous les champs.'),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final updatedNote = widget.note
        .copyWith(
          title: title,
          description: description,
          color: selectedColor,
          isFavorite: isFavorite,
          categoryId: selectedCategoryId,
          tags: tags,
        )
        .copyWithLocation(location);

    await NoteController.instance.updateNote(updatedNote);

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
        title: const Text("Modifier la note"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NoteForm(
              titleController: titleController,
              descriptionController: descriptionController,
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

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pièces jointes",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: _pickAttachment,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (isLoadingAttachments)
              const Center(child: CircularProgressIndicator())
            else
              AttachmentList(
                attachments: attachments,
                onDelete: _deleteAttachment,
                onTap: _openAttachment,
              ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rappels",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: _addReminder,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (isLoadingReminders)
              const Center(child: CircularProgressIndicator())
            else if (reminders.isEmpty)
              Text(
                "Aucun rappel pour cette note.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              Column(
                children: reminders.map((reminder) {
                  return ReminderTile(
                    reminder: reminder,
                    onToggle: (value) => _toggleReminder(reminder, value),
                    onEdit: () => _editReminder(reminder),
                    onDelete: () => _deleteReminder(reminder),
                  );
                }).toList(),
              ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Partage",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: _shareNote,
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (isLoadingShares)
              const Center(child: CircularProgressIndicator())
            else if (shares.isEmpty)
              Text(
                "Cette note n'est partagée avec personne.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              Column(
                children: shares.map((share) {
                  return ShareTile(
                    share: share,
                    onRevoke: () => _revokeShare(share),
                  );
                }).toList(),
              ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),

        child: SizedBox(
          height: 55,

          child: ElevatedButton.icon(
            onPressed: isSaving ? null : updateNote,

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),

            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),

            label: Text(isSaving ? "Modification..." : "Enregistrer"),
          ),
        ),
      ),
    );
  }
}
