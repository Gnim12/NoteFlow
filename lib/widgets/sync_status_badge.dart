import 'package:flutter/material.dart';

/// Indique à l'utilisateur si toutes les notes sont synchronisées avec
/// Firestore, ou s'il reste des opérations en attente (ex. réalisées hors
/// ligne) qui seront rejouées automatiquement au retour de la connexion.
class SyncStatusBadge extends StatelessWidget {
  final int pendingCount;

  const SyncStatusBadge({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final isSynced = pendingCount == 0;

    final color = isSynced ? Colors.green : Colors.orange;
    final icon = isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded;
    final label = isSynced
        ? "Synchronisé"
        : "$pendingCount modification${pendingCount > 1 ? 's' : ''} en attente";

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
