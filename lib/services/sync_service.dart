import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/sync_queue_entry.dart';
import 'firestore_service.dart';
import 'sqlite_service.dart';

class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final SqliteService _sqlite = SqliteService.instance;
  final FirestoreService _firestore = FirestoreService.instance;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _watchedUserId;
  bool _isFlushing = false;

  /// Écoute les changements de connectivité et rejoue automatiquement la
  /// file d'attente dès que le réseau revient. À appeler une fois qu'un
  /// utilisateur est authentifié (ex. au démarrage de l'accueil).
  void watchConnectivity(String userId) {
    _watchedUserId = userId;

    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (!results.contains(ConnectivityResult.none) &&
          _watchedUserId != null) {
        flush(_watchedUserId!);
      }
    });
  }

  void stopWatchingConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _watchedUserId = null;
  }

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<int> pendingCount(String userId) => _sqlite.getSyncQueueCount(userId);

  Future<void> enqueueUpsert({
    required String userId,
    required String noteId,
  }) async {
    await _sqlite.enqueueSync(
      userId: userId,
      noteId: noteId,
      operation: SyncOperation.upsert,
    );
    unawaited(flush(userId));
  }

  Future<void> enqueueDelete({
    required String userId,
    required String noteId,
  }) async {
    await _sqlite.enqueueSync(
      userId: userId,
      noteId: noteId,
      operation: SyncOperation.delete,
    );
    unawaited(flush(userId));
  }

  Future<void> enqueueDeleteAll(String userId) async {
    await _sqlite.enqueueSync(userId: userId, operation: SyncOperation.deleteAll);
    unawaited(flush(userId));
  }

  /// Rejoue la file d'attente dans l'ordre. S'arrête au premier échec (hors
  /// ligne, ou erreur Firestore) pour réessayer plus tard sans perdre l'ordre
  /// des opérations restantes.
  Future<void> flush(String userId) async {
    if (_isFlushing) return;
    _isFlushing = true;

    try {
      if (!await _isOnline()) return;

      final queue = await _sqlite.getSyncQueue(userId);

      for (final entry in queue) {
        try {
          await _applyToCloud(entry);
          await _sqlite.removeSyncQueueEntry(entry.id);
        } catch (_) {
          break;
        }
      }
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _applyToCloud(SyncQueueEntry entry) async {
    switch (entry.operation) {
      case SyncOperation.upsert:
        final note = await _sqlite.getNoteById(entry.noteId!, entry.userId);
        if (note == null) return;

        final remote = await _firestore.getNote(
          userId: entry.userId,
          noteId: note.id!,
        );

        if (remote == null || !remote.updatedAt.isAfter(note.updatedAt)) {
          await _firestore.setNote(note);
        }
        break;

      case SyncOperation.delete:
        await _firestore.deleteNote(userId: entry.userId, noteId: entry.noteId!);
        break;

      case SyncOperation.deleteAll:
        await _firestore.deleteAllNotes(entry.userId);
        break;
    }
  }
}
