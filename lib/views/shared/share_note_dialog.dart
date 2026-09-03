import 'package:flutter/material.dart';

import '../../models/shared_note_model.dart';

typedef ShareDraft = ({String email, SharePermission permission});

Future<ShareDraft?> showShareNoteDialog(BuildContext context) {
  return showDialog<ShareDraft>(
    context: context,
    builder: (_) => const _ShareNoteDialog(),
  );
}

class _ShareNoteDialog extends StatefulWidget {
  const _ShareNoteDialog();

  @override
  State<_ShareNoteDialog> createState() => _ShareNoteDialogState();
}

class _ShareNoteDialogState extends State<_ShareNoteDialog> {
  final _emailController = TextEditingController();
  SharePermission permission = SharePermission.read;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Partager la note"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Email de l'utilisateur",
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          RadioGroup<SharePermission>(
            groupValue: permission,
            onChanged: (value) => setState(() => permission = value!),
            child: const Column(
              children: [
                RadioListTile<SharePermission>(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Lecture seule"),
                  value: SharePermission.read,
                ),
                RadioListTile<SharePermission>(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Lecture et modification"),
                  value: SharePermission.write,
                ),
              ],
            ),
          ),
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
              email: _emailController.text.trim(),
              permission: permission,
            ));
          },
          child: const Text("Partager"),
        ),
      ],
    );
  }
}
