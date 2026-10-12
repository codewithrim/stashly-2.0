import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/db.dart';
import '../../data/models/item.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/synced_item_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncedItemRepository(db, Supabase.instance.client);
});

final activeItemsStreamProvider = StreamProvider<List<SavedItem>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchActiveItems();
});

final archivedItemsStreamProvider = StreamProvider<List<SavedItem>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchArchivedItems();
});

final itemDetailProvider = FutureProvider.family<SavedItem?, String>((ref, id) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemById(id);
});
