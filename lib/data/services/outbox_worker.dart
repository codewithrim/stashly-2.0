import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/db.dart';
import '../models/item.dart';
import 'sync_backoff.dart';

enum SyncStatus { synced, syncing, offline, hasPendingWrites }

class OutboxWorker {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  StreamSubscription? _connectivitySub;
  bool _isProcessing = false;
  int _consecutiveFailures = 0;

  OutboxWorker(this._db, this._supabase) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        flushOutbox();
      }
    });
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  Future<void> flushOutbox() async {
    if (_isProcessing) return;
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isProcessing = true;

    try {
      // 1. Process items marked as deleted locally
      final deletedItems = await (_db.select(_db.items)
            ..where((t) => t.isDeletedLocally.equals(true)))
          .get();

      for (final row in deletedItems) {
        try {
          await _supabase.from('saved_items').delete().eq('id', row.id);
          await _db.purgeItem(row.id);
        } catch (_) {
          // Keep in local DB to retry next cycle
          break;
        }
      }

      // 2. Process items marked as dirty (new or edited)
      final dirtyItems = await (_db.select(_db.items)
            ..where((t) => t.isDirty.equals(true) & t.isDeletedLocally.equals(false)))
          .get();

      for (final row in dirtyItems) {
        final item = _db._rowToModel(row).copyWith(ownerId: user.id);
        try {
          await _supabase.from('saved_items').upsert(item.toJson());
          // Mark locally as synced
          await _db.upsertItem(item.copyWith(isDirty: false));
          _consecutiveFailures = 0;
        } catch (_) {
          _consecutiveFailures++;
          break;
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Optimistic Concurrency check according to section 5.6
  Future<bool> updateWithOptimisticLock({
    required String id,
    required Map<String, dynamic> patch,
    required DateTime baseUpdatedAt,
  }) async {
    try {
      final rows = await _supabase
          .from('saved_items')
          .update(patch)
          .eq('id', id)
          .eq('updated_at', baseUpdatedAt.toIso8601String())
          .select();

      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
