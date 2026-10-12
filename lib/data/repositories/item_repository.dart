import '../models/item.dart';

abstract class ItemRepository {
  Stream<List<SavedItem>> watchActiveItems();
  Stream<List<SavedItem>> watchArchivedItems();
  Future<SavedItem?> getItemById(String id);
  Future<void> saveItem(SavedItem item);
  Future<void> archiveItem(String id, bool archive);
  Future<void> deleteItem(String id);
  Future<List<SavedItem>> searchItems({
    String? query,
    ItemType? typeFilter,
    List<String>? tagFilters,
    bool archived = false,
  });
  Future<void> wipeLocalData();
}
