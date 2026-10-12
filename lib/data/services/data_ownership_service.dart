import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors.dart';
import '../local/db.dart';
import '../repositories/item_repository.dart';

class DataOwnershipService {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  final ItemRepository _itemRepository;

  DataOwnershipService(this._db, this._supabase, this._itemRepository);

  /// Builds a complete JSON export of all items, tags, timestamps, and attachment metadata
  Future<File> exportUserDataJson() async {
    final user = _supabase.auth.currentUser;
    final activeItems = await _db.getAllActiveItems();
    final archivedItems = await (_db.select(_db.items)
          ..where((tbl) => tbl.isDeletedLocally.equals(false))
          ..where((tbl) => tbl.archived.equals(true)))
        .get();

    final allItems = [
      ...activeItems,
      ...archivedItems.map((r) => _db.rowToModel(r)),
    ];

    final exportData = {
      'app': 'Stashly 2.0',
      'version': '1.0.0',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'user_id': user?.id ?? 'local_user',
      'user_email': user?.email ?? 'local@stashly.app',
      'total_items': allItems.length,
      'items': allItems.map((item) => item.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/stashly_export_$timestamp.json');

    await file.writeAsString(jsonString);
    return file;
  }

  /// Exports and triggers the system share sheet
  Future<void> exportAndShare() async {
    final file = await exportUserDataJson();
    final xFile = XFile(file.path, mimeType: 'application/json');
    await Share.shareXFiles([xFile], text: 'My Stashly Data Export');
  }

  /// Calls the Supabase Edge Function to delete account (auth, storage, database)
  /// then wipes the local cache.
  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      // Offline mode account wipe
      await _itemRepository.wipeLocalData();
      return;
    }

    try {
      final response = await _supabase.functions.invoke('delete-account');
      if (response.status != 200) {
        throw UnknownException('Edge Function failed to delete account (Status: ${response.status})');
      }

      // Wipe local storage and sign out
      await _itemRepository.wipeLocalData();
      await _supabase.auth.signOut();
    } catch (e) {
      throw UnknownException('Account deletion failed: $e');
    }
  }
}
