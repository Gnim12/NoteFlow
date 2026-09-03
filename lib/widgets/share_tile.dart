import 'package:flutter/material.dart';

import '../models/shared_note_model.dart';

class ShareTile extends StatelessWidget {
  final SharedNote share;
  final VoidCallback onRevoke;

  const ShareTile({super.key, required this.share, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline),
      title: Text(share.sharedWithEmail),
      subtitle: Text(
        share.permission == SharePermission.write
            ? "Lecture et modification"
            : "Lecture seule",
      ),
      trailing: IconButton(
        icon: Icon(Icons.link_off, color: theme.colorScheme.error),
        tooltip: "Retirer l'accès",
        onPressed: onRevoke,
      ),
    );
  }
}
