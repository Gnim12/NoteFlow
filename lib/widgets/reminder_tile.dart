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

  String get _subtitle {
    if (reminder.isLocationBased) {
      final place = reminder.placeName ?? "lieu choisi";
      final radius = reminder.radiusMeters?.round() ?? 0;
      return "À l'approche de $place (${radius}m)";
    }

    return "${DateFormat("dd MMM yyyy 'à' HH:mm").format(reminder.dateTime)} · ${reminder.recurrenceLabel}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          reminder.isLocationBased
              ? Icons.location_on
              : Icons.notifications_active,
          color: reminder.enabled
              ? theme.colorScheme.primary
              : theme.disabledColor,
        ),
        title: Text(
          noteTitle ??
              (reminder.isLocationBased
                  ? (reminder.placeName ?? "Rappel géolocalisé")
                  : DateFormat(
                      "dd MMM yyyy 'à' HH:mm",
                    ).format(reminder.dateTime)),
        ),
        subtitle: Text(_subtitle),
        onTap: reminder.isLocationBased ? null : onEdit,
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
