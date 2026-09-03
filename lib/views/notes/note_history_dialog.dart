import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/note_controller.dart';
import '../../models/note_version_model.dart';

/// Affiche l'historique des versions précédentes d'une note. Renvoie la
/// version choisie par l'utilisateur pour restauration, ou `null`.
Future<NoteVersion?> showNoteHistoryDialog(
  BuildContext context, {
  required String noteId,
}) {
  return showDialog<NoteVersion>(
    context: context,
    builder: (_) => _NoteHistoryDialog(noteId: noteId),
  );
}

class _NoteHistoryDialog extends StatefulWidget {
  final String noteId;

  const _NoteHistoryDialog({required this.noteId});

  @override
  State<_NoteHistoryDialog> createState() => _NoteHistoryDialogState();
}

class _NoteHistoryDialogState extends State<_NoteHistoryDialog> {
  List<NoteVersion> versions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await NoteController.instance.getVersions(widget.noteId);

    if (!mounted) return;

    setState(() {
      versions = result;
      isLoading = false;
    });
  }

  Future<void> _confirmRestore(NoteVersion version) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Restaurer cette version"),
        content: Text(
          "Le titre et le contenu seront remplacés par cette version du "
          "${DateFormat("dd MMM yyyy 'à' HH:mm").format(version.savedAt)}. "
          "Vous pourrez encore annuler avant d'enregistrer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Restaurer"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pop(context, version);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text("Historique des modifications"),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : versions.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Aucune version précédente enregistrée.",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 350),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: versions.length,
                  itemBuilder: (_, index) {
                    final version = versions[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        version.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DateFormat(
                          "dd MMM yyyy 'à' HH:mm",
                        ).format(version.savedAt),
                      ),
                      trailing: TextButton(
                        onPressed: () => _confirmRestore(version),
                        child: const Text("Restaurer"),
                      ),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fermer"),
        ),
      ],
    );
  }
}
