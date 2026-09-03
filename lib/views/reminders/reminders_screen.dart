import 'package:flutter/material.dart';

import '../../controllers/note_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../models/note_model.dart';
import '../../models/reminder_model.dart';
import '../../widgets/reminder_tile.dart';
import '../notes/edit_note_screen.dart';
import 'reminder_form_dialog.dart';

class RemindersScreen extends StatefulWidget {
  final String userId;

  const RemindersScreen({super.key, required this.userId});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderController _reminderController = ReminderController.instance;
  final NoteController _noteController = NoteController.instance;

  List<Reminder> reminders = [];
  Map<String, Note> notesById = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  Future<void> loadReminders() async {
    final result = await _reminderController.getAllReminders(widget.userId);
    final notes = <String, Note>{};

    for (final reminder in result) {
      if (notes.containsKey(reminder.noteId)) continue;
      final note = await _noteController.getNoteById(
        reminder.noteId,
        widget.userId,
      );
      if (note != null) notes[reminder.noteId] = note;
    }

    if (!mounted) return;

    setState(() {
      reminders = result;
      notesById = notes;
      isLoading = false;
    });
  }

  Future<void> _toggle(Reminder reminder, bool enabled) async {
    final note = notesById[reminder.noteId];
    if (note == null) return;

    await _reminderController.updateReminder(
      reminder: reminder.copyWith(enabled: enabled),
      note: note,
    );
    loadReminders();
  }

  Future<void> _edit(Reminder reminder) async {
    final draft = await showReminderFormDialog(context, initial: reminder);
    if (draft == null) return;

    final note = notesById[reminder.noteId];
    if (note == null) return;

    await _reminderController.updateReminder(
      reminder: reminder.copyWith(
        dateTime: draft.dateTime,
        recurrence: draft.recurrence,
        customIntervalDays: draft.customIntervalDays,
      ),
      note: note,
    );
    loadReminders();
  }

  Future<void> _delete(Reminder reminder) async {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Rappels")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reminders.isEmpty
          ? Center(
              child: Text(
                "Aucun rappel programmé.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: reminders.length,
              itemBuilder: (_, index) {
                final reminder = reminders[index];
                final note = notesById[reminder.noteId];

                return ReminderTile(
                  reminder: reminder,
                  noteTitle: note?.title,
                  onToggle: (value) => _toggle(reminder, value),
                  onEdit: () {
                    if (note != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditNoteScreen(note: note),
                        ),
                      ).then((_) => loadReminders());
                    } else {
                      _edit(reminder);
                    }
                  },
                  onDelete: () => _delete(reminder),
                );
              },
            ),
    );
  }
}
