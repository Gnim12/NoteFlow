import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reminder_model.dart';

class ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final String? noteTitle;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderTile({
    super.key,
    required this.reminder,
    this.noteTitle,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          Icons.notifications_active,
          color: reminder.enabled
              ? theme.colorScheme.primary
              : theme.disabledColor,
        ),
        title: Text(
          noteTitle ??
              DateFormat("dd MMM yyyy 'à' HH:mm").format(reminder.dateTime),
        ),
        subtitle: Text(
          "${DateFormat("dd MMM yyyy 'à' HH:mm").format(reminder.dateTime)} · ${reminder.recurrenceLabel}",
        ),
        onTap: onEdit,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: reminder.enabled, onChanged: onToggle),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
