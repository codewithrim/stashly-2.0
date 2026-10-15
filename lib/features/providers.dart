import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/db.dart';
import '../../data/models/item.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/synced_item_repository.dart';
import '../../data/services/attachment_service.dart';
import '../../data/services/data_ownership_service.dart';
import '../../data/services/reminder_service.dart';
import '../../data/services/share_link_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncedItemRepository(db, Supabase.instance.client);
});

final attachmentServiceProvider = Provider<AttachmentService>((ref) {
  return AttachmentService(Supabase.instance.client);
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService.instance;
});

final shareLinkServiceProvider = Provider<ShareLinkService>((ref) {
  return ShareLinkService(Supabase.instance.client);
});

final dataOwnershipServiceProvider = Provider<DataOwnershipService>((ref) {
  final db = ref.watch(databaseProvider);
  final repo = ref.watch(itemRepositoryProvider);
  return DataOwnershipService(db, Supabase.instance.client, repo);
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

final itemShareLinkProvider =
    FutureProvider.family<ShareLinkInfo?, String>((ref, id) {
  final service = ref.watch(shareLinkServiceProvider);
  return service.getActiveLinkForItem(id);
});
