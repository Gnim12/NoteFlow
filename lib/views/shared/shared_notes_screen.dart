import 'package:flutter/material.dart';

import '../../controllers/sharing_controller.dart';
import '../../models/shared_note_model.dart';
import 'shared_note_detail_screen.dart';

class SharedNotesScreen extends StatefulWidget {
  final String userId;

  const SharedNotesScreen({super.key, required this.userId});

  @override
  State<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends State<SharedNotesScreen> {
  List<SharedNoteWithData> sharedNotes = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await SharingController.instance.getNotesSharedWithMe(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        sharedNotes = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = "Impossible de charger les notes partagées (connexion requise).";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Notes partagées avec moi")),
      body: RefreshIndicator(
        onRefresh: load,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              )
            : sharedNotes.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      "Aucune note partagée avec vous pour l'instant.",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: sharedNotes.length,
                itemBuilder: (_, index) {
                  final entry = sharedNotes[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        entry.share.permission == SharePermission.write
                            ? Icons.edit_outlined
                            : Icons.visibility_outlined,
                      ),
                      title: Text(entry.note.title),
                      subtitle: Text("Partagée par ${entry.share.ownerEmail ?? entry.share.ownerId}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SharedNoteDetailScreen(
                              note: entry.note,
                              permission: entry.share.permission,
                            ),
                          ),
                        ).then((_) => load());
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
