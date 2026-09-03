import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/reminder_model.dart';

typedef ReminderDraft = ({
  DateTime dateTime,
  RecurrenceType recurrence,
  int? customIntervalDays,
});

Future<ReminderDraft?> showReminderFormDialog(
  BuildContext context, {
  Reminder? initial,
}) {
  return showDialog<ReminderDraft>(
    context: context,
    builder: (_) => _ReminderFormDialog(initial: initial),
  );
}

class _ReminderFormDialog extends StatefulWidget {
  final Reminder? initial;

  const _ReminderFormDialog({this.initial});

  @override
  State<_ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<_ReminderFormDialog> {
  late DateTime dateTime;
  late RecurrenceType recurrence;
  late int customIntervalDays;

  @override
  void initState() {
    super.initState();

    final initial = widget.initial;
    dateTime = initial?.dateTime ?? DateTime.now().add(const Duration(hours: 1));
    recurrence = initial?.recurrence ?? RecurrenceType.none;
    customIntervalDays = initial?.customIntervalDays ?? 2;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) return;

    setState(() {
      dateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        dateTime.hour,
        dateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime),
    );

    if (picked == null) return;

    setState(() {
      dateTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? "Nouveau rappel" : "Modifier le rappel"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(DateFormat("dd MMM yyyy").format(dateTime)),
            onTap: _pickDate,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text(DateFormat("HH:mm").format(dateTime)),
            onTap: _pickTime,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<RecurrenceType>(
            initialValue: recurrence,
            decoration: const InputDecoration(labelText: "Récurrence"),
            items: const [
              DropdownMenuItem(
                value: RecurrenceType.none,
                child: Text("Ponctuel"),
              ),
              DropdownMenuItem(
                value: RecurrenceType.daily,
                child: Text("Quotidien"),
              ),
              DropdownMenuItem(
                value: RecurrenceType.weekly,
                child: Text("Hebdomadaire"),
              ),
              DropdownMenuItem(
                value: RecurrenceType.monthly,
                child: Text("Mensuel"),
              ),
              DropdownMenuItem(
                value: RecurrenceType.custom,
                child: Text("Personnalisé (tous les N jours)"),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => recurrence = value);
            },
          ),
          if (recurrence == RecurrenceType.custom) ...[
            const SizedBox(height: 10),
            TextFormField(
              initialValue: customIntervalDays.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Tous les N jours"),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed > 0) {
                  customIntervalDays = parsed;
                }
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, (
              dateTime: dateTime,
              recurrence: recurrence,
              customIntervalDays: recurrence == RecurrenceType.custom
                  ? customIntervalDays
                  : null,
            ));
          },
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }
}
