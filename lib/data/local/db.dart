import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../models/item.dart';

part 'db.g.dart';

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().withDefault(const Constant('local'))();
  TextColumn get type => text()();
  TextColumn get title => text().withLength(max: 200).withDefault(const Constant(''))();
  TextColumn get content => text().nullable().withLength(max: 20000)();
  TextColumn get url => text().nullable().withLength(max: 2048)();
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // stored as JSON array string
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get remindAt => dateTime().nullable()();
  TextColumn get attachmentPath => text().nullable()();
  TextColumn get attachmentName => text().nullable()();
  TextColumn get attachmentMime => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Outbox / Local Sync tracking
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeletedLocally => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Drafts extends Table {
  TextColumn get targetId => text()(); // Item ID or 'new'
  TextColumn get type => text()();
  TextColumn get title => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {targetId};
}

@DriftDatabase(tables: [Items, Drafts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'stashly_local');
  }

  // Helper conversions
  Future<List<SavedItem>> getAllActiveItems() async {
    final query = select(items)
      ..where((tbl) => tbl.isDeletedLocally.equals(false) & tbl.archived.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);
    final rows = await query.get();
    return rows.map(rowToModel).toList();
  }

  Stream<List<SavedItem>> watchActiveItems() {
    final query = select(items)
      ..where((tbl) => tbl.isDeletedLocally.equals(false) & tbl.archived.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);
    return query.watch().map((rows) => rows.map(rowToModel).toList());
  }

  Stream<List<SavedItem>> watchArchivedItems() {
    final query = select(items)
      ..where((tbl) => tbl.isDeletedLocally.equals(false) & tbl.archived.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);
    return query.watch().map((rows) => rows.map(rowToModel).toList());
  }

  Future<SavedItem?> getItemById(String id) async {
    final query = select(items)..where((tbl) => tbl.id.equals(id) & tbl.isDeletedLocally.equals(false));
    final row = await query.getSingleOrNull();
    return row == null ? null : rowToModel(row);
  }

  Future<void> upsertItem(SavedItem item) async {
    await into(items).insertOnConflictUpdate(
      ItemsCompanion(
        id: Value(item.id),
        ownerId: Value(item.ownerId),
        type: Value(item.type.name),
        title: Value(item.title),
        content: Value(item.content),
        url: Value(item.url),
        tags: Value(jsonEncode(item.tags)),
        archived: Value(item.archived),
        remindAt: Value(item.remindAt),
        attachmentPath: Value(item.attachmentPath),
        attachmentName: Value(item.attachmentName),
        attachmentMime: Value(item.attachmentMime),
        createdAt: Value(item.createdAt),
        updatedAt: Value(item.updatedAt),
        isDirty: Value(item.isDirty),
        isDeletedLocally: Value(item.isDeletedLocally),
      ),
    );
  }

  Future<void> markDeletedLocally(String id) async {
    await (update(items)..where((tbl) => tbl.id.equals(id))).write(
      const ItemsCompanion(
        isDeletedLocally: Value(true),
        isDirty: Value(true),
      ),
    );
  }

  Future<void> purgeItem(String id) async {
    await (delete(items)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> wipeAllData() async {
    await delete(items).go();
    await delete(drafts).go();
  }

  SavedItem rowToModel(Item row) {
    List<String> tagsList = [];
    try {
      final decoded = jsonDecode(row.tags);
      if (decoded is List) tagsList = decoded.map((e) => e.toString()).toList();
    } catch (_) {}

    return SavedItem(
      id: row.id,
      ownerId: row.ownerId,
      type: ItemType.fromString(row.type),
      title: row.title,
      content: row.content,
      url: row.url,
      tags: tagsList,
      archived: row.archived,
      remindAt: row.remindAt,
      attachmentPath: row.attachmentPath,
      attachmentName: row.attachmentName,
      attachmentMime: row.attachmentMime,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDirty: row.isDirty,
      isDeletedLocally: row.isDeletedLocally,
    );
  }
}
