import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/db.dart';
import '../models/item.dart';
import 'item_repository.dart';

class SyncedItemRepository implements ItemRepository {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  SyncedItemRepository(this._db, this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

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
  Future<void> saveItem(SavedItem item) async {
    final uid = _currentUserId ?? 'local';
    final toSave = item.copyWith(
      ownerId: uid,
      updatedAt: DateTime.now().toUtc(),
      isDirty: true,
    );

    // Write through to local database first
    await _db.upsertItem(toSave);

    // Sync to Supabase if authenticated
    if (_currentUserId != null) {
      try {
        await _supabase.from('saved_items').upsert(toSave.toJson());
        // Clean dirty flag on success
        await _db.upsertItem(toSave.copyWith(isDirty: false));
      } catch (_) {
        // Outbox keeps isDirty: true for sync worker
      }
    }
  }

  @override
  Future<void> archiveItem(String id, bool archive) async {
    final item = await _db.getItemById(id);
    if (item != null) {
      final updated = item.copyWith(
        archived: archive,
        updatedAt: DateTime.now().toUtc(),
        isDirty: true,
      );
      await _db.upsertItem(updated);

      if (_currentUserId != null) {
        try {
          await _supabase.from('saved_items').update({
            'archived': archive,
            'updated_at': updated.updatedAt.toIso8601String(),
          }).eq('id', id);
          await _db.upsertItem(updated.copyWith(isDirty: false));
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    await _db.markDeletedLocally(id);

    if (_currentUserId != null) {
      try {
        await _supabase.from('saved_items').delete().eq('id', id);
        await _db.purgeItem(id);
      } catch (_) {}
    }
  }

  Future<void> pullRemoteChanges() async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      final response = await _supabase
          .from('saved_items')
          .select()
          .order('updated_at', ascending: false);

      for (final map in response) {
        final remoteItem = SavedItem.fromJson(map);
        final local = await _db.getItemById(remoteItem.id);

        if (local == null) {
          await _db.upsertItem(remoteItem.copyWith(isDirty: false));
        } else if (!local.isDirty) {
          // If local has not been modified offline, update with remote
          if (remoteItem.updatedAt.isAfter(local.updatedAt)) {
            await _db.upsertItem(remoteItem.copyWith(isDirty: false));
          }
        }
      }
    } catch (_) {}
  }

  @override
  Future<List<SavedItem>> searchItems({
    String? query,
    ItemType? typeFilter,
    List<String>? tagFilters,
    bool archived = false,
  }) async {
    final items = archived
        ? await (_db.select(_db.items)..where((t) => t.isDeletedLocally.equals(false) & t.archived.equals(true))).get()
        : await (_db.select(_db.items)..where((t) => t.isDeletedLocally.equals(false) & t.archived.equals(false))).get();

    final all = items.map((r) => _db._rowToModel(r)).toList();

    return all.where((item) {
      if (typeFilter != null && item.type != typeFilter) return false;

      if (tagFilters != null && tagFilters.isNotEmpty) {
        final hasAllTags = tagFilters.every((t) => item.tags.contains(t.toLowerCase()));
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
