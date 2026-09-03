import 'package:uuid/uuid.dart';

import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/sqlite_service.dart';

/// Les catégories changent rarement par rapport aux notes : elles sont donc
/// synchronisées de façon "best effort" (écriture locale immédiate, miroir
/// Firestore silencieusement ignoré hors ligne) plutôt que via la file
/// d'attente robuste utilisée pour les notes (cf. [SyncService]).
class CategoryController {
  CategoryController._();

  static final CategoryController instance = CategoryController._();
  final SqliteService _service = SqliteService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  static const _uuid = Uuid();

  Future<List<Category>> getCategories(String userId) {
    return _service.getCategories(userId);
  }

  Future<Category> createCategory({
    required String userId,
    required String name,
    required int color,
  }) async {
    final category = Category(
      id: _uuid.v4(),
      userId: userId,
      name: name.trim(),
      color: color,
      createdAt: DateTime.now(),
    );

    await _service.insertCategory(category);
    _mirrorToCloud(() => _firestoreService.setCategory(category));

    return category;
  }

  Future<void> updateCategory(Category category) async {
    await _service.updateCategory(category);
    _mirrorToCloud(() => _firestoreService.setCategory(category));
  }

  Future<void> deleteCategory({
    required String id,
    required String userId,
  }) async {
    await _service.deleteCategory(id: id, userId: userId);
    _mirrorToCloud(
      () => _firestoreService.deleteCategory(userId: userId, categoryId: id),
    );
  }

  void _mirrorToCloud(Future<void> Function() action) {
    action().catchError((_) {});
  }
}
