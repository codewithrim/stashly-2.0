import '../local/db.dart';
import '../models/item.dart';
import 'item_repository.dart';

class LocalItemRepository implements ItemRepository {
  final AppDatabase _db;

  LocalItemRepository(this._db);

  @override
  Stream<List<SavedItem>> watchActiveItems() {
    return _db.watchActiveItems();
  }

  @override
  Stream<List<SavedItem>> watchArchivedItems() {
    return _db.watchArchivedItems();
  }

  @override
  Future<SavedItem?> getItemById(String id) {
    return _db.getItemById(id);
  }

  @override
  Future<void> saveItem(SavedItem item) {
    final updated = item.copyWith(
      updatedAt: DateTime.now().toUtc(),
      isDirty: true,
    );
    return _db.upsertItem(updated);
  }

  @override
  Future<void> archiveItem(String id, bool archive) async {
    final item = await _db.getItemById(id);
    if (item != null) {
      await _db.upsertItem(item.copyWith(
        archived: archive,
        updatedAt: DateTime.now().toUtc(),
        isDirty: true,
      ));
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    await _db.markDeletedLocally(id);
  }

  @override
  Future<List<SavedItem>> searchItems({
    String? query,
    ItemType? typeFilter,
    List<String>? tagFilters,
    bool archived = false,
  }) async {
    final items = archived
        ? await (_db.select(_db.items)
              ..where((t) => t.isDeletedLocally.equals(false))
              ..where((t) => t.archived.equals(true)))
            .get()
        : await (_db.select(_db.items)
              ..where((t) => t.isDeletedLocally.equals(false))
              ..where((t) => t.archived.equals(false)))
            .get();

    final all = items.map((r) => _db.rowToModel(r)).toList();

    return all.where((item) {
      if (typeFilter != null && item.type != typeFilter) return false;

      if (tagFilters != null && tagFilters.isNotEmpty) {
        final hasAllTags =
            tagFilters.every((t) => item.tags.contains(t.toLowerCase()));
        if (!hasAllTags) return false;
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(q);
        final matchesContent = item.content?.toLowerCase().contains(q) ?? false;
        final matchesUrl = item.url?.toLowerCase().contains(q) ?? false;
        final matchesTag = item.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchesTitle && !matchesContent && !matchesUrl && !matchesTag) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Future<void> wipeLocalData() {
    return _db.wipeAllData();
  }
}
