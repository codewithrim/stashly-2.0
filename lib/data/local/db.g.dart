// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20000),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2048),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _remindAtMeta =
      const VerificationMeta('remindAt');
  @override
  late final GeneratedColumn<DateTime> remindAt = GeneratedColumn<DateTime>(
      'remind_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _attachmentPathMeta =
      const VerificationMeta('attachmentPath');
  @override
  late final GeneratedColumn<String> attachmentPath = GeneratedColumn<String>(
      'attachment_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attachmentNameMeta =
      const VerificationMeta('attachmentName');
  @override
  late final GeneratedColumn<String> attachmentName = GeneratedColumn<String>(
      'attachment_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attachmentMimeMeta =
      const VerificationMeta('attachmentMime');
  @override
  late final GeneratedColumn<String> attachmentMime = GeneratedColumn<String>(
      'attachment_mime', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedLocallyMeta =
      const VerificationMeta('isDeletedLocally');
  @override
  late final GeneratedColumn<bool> isDeletedLocally = GeneratedColumn<bool>(
      'is_deleted_locally', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ownerId,
        type,
        title,
        content,
        url,
        tags,
        archived,
        remindAt,
        attachmentPath,
        attachmentName,
        attachmentMime,
        createdAt,
        updatedAt,
        isDirty,
        isDeletedLocally
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('remind_at')) {
      context.handle(_remindAtMeta,
          remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta));
    }
    if (data.containsKey('attachment_path')) {
      context.handle(
          _attachmentPathMeta,
          attachmentPath.isAcceptableOrUnknown(
              data['attachment_path']!, _attachmentPathMeta));
    }
    if (data.containsKey('attachment_name')) {
      context.handle(
          _attachmentNameMeta,
          attachmentName.isAcceptableOrUnknown(
              data['attachment_name']!, _attachmentNameMeta));
    }
    if (data.containsKey('attachment_mime')) {
      context.handle(
          _attachmentMimeMeta,
          attachmentMime.isAcceptableOrUnknown(
              data['attachment_mime']!, _attachmentMimeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted_locally')) {
      context.handle(
          _isDeletedLocallyMeta,
          isDeletedLocally.isAcceptableOrUnknown(
              data['is_deleted_locally']!, _isDeletedLocallyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      remindAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}remind_at']),
      attachmentPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment_path']),
      attachmentName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment_name']),
      attachmentMime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment_mime']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeletedLocally: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_deleted_locally'])!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String id;
  final String ownerId;
  final String type;
  final String title;
  final String? content;
  final String? url;
  final String tags;
  final bool archived;
  final DateTime? remindAt;
  final String? attachmentPath;
  final String? attachmentName;
  final String? attachmentMime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeletedLocally;
  const Item(
      {required this.id,
      required this.ownerId,
      required this.type,
      required this.title,
      this.content,
      this.url,
      required this.tags,
      required this.archived,
      this.remindAt,
      this.attachmentPath,
      this.attachmentName,
      this.attachmentMime,
      required this.createdAt,
      required this.updatedAt,
      required this.isDirty,
      required this.isDeletedLocally});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['tags'] = Variable<String>(tags);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<DateTime>(remindAt);
    }
    if (!nullToAbsent || attachmentPath != null) {
      map['attachment_path'] = Variable<String>(attachmentPath);
    }
    if (!nullToAbsent || attachmentName != null) {
      map['attachment_name'] = Variable<String>(attachmentName);
    }
    if (!nullToAbsent || attachmentMime != null) {
      map['attachment_mime'] = Variable<String>(attachmentMime);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted_locally'] = Variable<bool>(isDeletedLocally);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      type: Value(type),
      title: Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      tags: Value(tags),
      archived: Value(archived),
      remindAt: remindAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindAt),
      attachmentPath: attachmentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentPath),
      attachmentName: attachmentName == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentName),
      attachmentMime: attachmentMime == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentMime),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDirty: Value(isDirty),
      isDeletedLocally: Value(isDeletedLocally),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      url: serializer.fromJson<String?>(json['url']),
      tags: serializer.fromJson<String>(json['tags']),
      archived: serializer.fromJson<bool>(json['archived']),
      remindAt: serializer.fromJson<DateTime?>(json['remindAt']),
      attachmentPath: serializer.fromJson<String?>(json['attachmentPath']),
      attachmentName: serializer.fromJson<String?>(json['attachmentName']),
      attachmentMime: serializer.fromJson<String?>(json['attachmentMime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeletedLocally: serializer.fromJson<bool>(json['isDeletedLocally']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String?>(content),
      'url': serializer.toJson<String?>(url),
      'tags': serializer.toJson<String>(tags),
      'archived': serializer.toJson<bool>(archived),
      'remindAt': serializer.toJson<DateTime?>(remindAt),
      'attachmentPath': serializer.toJson<String?>(attachmentPath),
      'attachmentName': serializer.toJson<String?>(attachmentName),
      'attachmentMime': serializer.toJson<String?>(attachmentMime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeletedLocally': serializer.toJson<bool>(isDeletedLocally),
    };
  }

  Item copyWith(
          {String? id,
          String? ownerId,
          String? type,
          String? title,
          Value<String?> content = const Value.absent(),
          Value<String?> url = const Value.absent(),
          String? tags,
          bool? archived,
          Value<DateTime?> remindAt = const Value.absent(),
          Value<String?> attachmentPath = const Value.absent(),
          Value<String?> attachmentName = const Value.absent(),
          Value<String?> attachmentMime = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDirty,
          bool? isDeletedLocally}) =>
      Item(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        type: type ?? this.type,
        title: title ?? this.title,
        content: content.present ? content.value : this.content,
        url: url.present ? url.value : this.url,
        tags: tags ?? this.tags,
        archived: archived ?? this.archived,
        remindAt: remindAt.present ? remindAt.value : this.remindAt,
        attachmentPath:
            attachmentPath.present ? attachmentPath.value : this.attachmentPath,
        attachmentName:
            attachmentName.present ? attachmentName.value : this.attachmentName,
        attachmentMime:
            attachmentMime.present ? attachmentMime.value : this.attachmentMime,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDirty: isDirty ?? this.isDirty,
        isDeletedLocally: isDeletedLocally ?? this.isDeletedLocally,
      );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      url: data.url.present ? data.url.value : this.url,
      tags: data.tags.present ? data.tags.value : this.tags,
      archived: data.archived.present ? data.archived.value : this.archived,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      attachmentPath: data.attachmentPath.present
          ? data.attachmentPath.value
          : this.attachmentPath,
      attachmentName: data.attachmentName.present
          ? data.attachmentName.value
          : this.attachmentName,
      attachmentMime: data.attachmentMime.present
          ? data.attachmentMime.value
          : this.attachmentMime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeletedLocally: data.isDeletedLocally.present
          ? data.isDeletedLocally.value
          : this.isDeletedLocally,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('tags: $tags, ')
          ..write('archived: $archived, ')
          ..write('remindAt: $remindAt, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('attachmentName: $attachmentName, ')
          ..write('attachmentMime: $attachmentMime, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeletedLocally: $isDeletedLocally')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      ownerId,
      type,
      title,
      content,
      url,
      tags,
      archived,
      remindAt,
      attachmentPath,
      attachmentName,
      attachmentMime,
      createdAt,
      updatedAt,
      isDirty,
      isDeletedLocally);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.type == this.type &&
          other.title == this.title &&
          other.content == this.content &&
          other.url == this.url &&
          other.tags == this.tags &&
          other.archived == this.archived &&
          other.remindAt == this.remindAt &&
          other.attachmentPath == this.attachmentPath &&
          other.attachmentName == this.attachmentName &&
          other.attachmentMime == this.attachmentMime &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDirty == this.isDirty &&
          other.isDeletedLocally == this.isDeletedLocally);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> content;
  final Value<String?> url;
  final Value<String> tags;
  final Value<bool> archived;
  final Value<DateTime?> remindAt;
  final Value<String?> attachmentPath;
  final Value<String?> attachmentName;
  final Value<String?> attachmentMime;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDirty;
  final Value<bool> isDeletedLocally;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    this.tags = const Value.absent(),
    this.archived = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.attachmentName = const Value.absent(),
    this.attachmentMime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String type,
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    this.tags = const Value.absent(),
    this.archived = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.attachmentName = const Value.absent(),
    this.attachmentMime = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDirty = const Value.absent(),
    this.isDeletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? url,
    Expression<String>? tags,
    Expression<bool>? archived,
    Expression<DateTime>? remindAt,
    Expression<String>? attachmentPath,
    Expression<String>? attachmentName,
    Expression<String>? attachmentMime,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDirty,
    Expression<bool>? isDeletedLocally,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (url != null) 'url': url,
      if (tags != null) 'tags': tags,
      if (archived != null) 'archived': archived,
      if (remindAt != null) 'remind_at': remindAt,
      if (attachmentPath != null) 'attachment_path': attachmentPath,
      if (attachmentName != null) 'attachment_name': attachmentName,
      if (attachmentMime != null) 'attachment_mime': attachmentMime,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeletedLocally != null) 'is_deleted_locally': isDeletedLocally,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownerId,
      Value<String>? type,
      Value<String>? title,
      Value<String?>? content,
      Value<String?>? url,
      Value<String>? tags,
      Value<bool>? archived,
      Value<DateTime?>? remindAt,
      Value<String?>? attachmentPath,
      Value<String?>? attachmentName,
      Value<String?>? attachmentMime,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDirty,
      Value<bool>? isDeletedLocally,
      Value<int>? rowid}) {
    return ItemsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      url: url ?? this.url,
      tags: tags ?? this.tags,
      archived: archived ?? this.archived,
      remindAt: remindAt ?? this.remindAt,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentMime: attachmentMime ?? this.attachmentMime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeletedLocally: isDeletedLocally ?? this.isDeletedLocally,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime>(remindAt.value);
    }
    if (attachmentPath.present) {
      map['attachment_path'] = Variable<String>(attachmentPath.value);
    }
    if (attachmentName.present) {
      map['attachment_name'] = Variable<String>(attachmentName.value);
    }
    if (attachmentMime.present) {
      map['attachment_mime'] = Variable<String>(attachmentMime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeletedLocally.present) {
      map['is_deleted_locally'] = Variable<bool>(isDeletedLocally.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('tags: $tags, ')
          ..write('archived: $archived, ')
          ..write('remindAt: $remindAt, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('attachmentName: $attachmentName, ')
          ..write('attachmentMime: $attachmentMime, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeletedLocally: $isDeletedLocally, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, Draft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _savedAtMeta =
      const VerificationMeta('savedAt');
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
      'saved_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [targetId, type, title, content, url, tags, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(Insertable<Draft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('saved_at')) {
      context.handle(_savedAtMeta,
          savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta));
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {targetId};
  @override
  Draft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Draft(
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      savedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}saved_at'])!,
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class Draft extends DataClass implements Insertable<Draft> {
  final String targetId;
  final String type;
  final String? title;
  final String? content;
  final String? url;
  final String tags;
  final DateTime savedAt;
  const Draft(
      {required this.targetId,
      required this.type,
      this.title,
      this.content,
      this.url,
      required this.tags,
      required this.savedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target_id'] = Variable<String>(targetId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['tags'] = Variable<String>(tags);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      targetId: Value(targetId),
      type: Value(type),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      tags: Value(tags),
      savedAt: Value(savedAt),
    );
  }

  factory Draft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Draft(
      targetId: serializer.fromJson<String>(json['targetId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String?>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      url: serializer.fromJson<String?>(json['url']),
      tags: serializer.fromJson<String>(json['tags']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'targetId': serializer.toJson<String>(targetId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String?>(title),
      'content': serializer.toJson<String?>(content),
      'url': serializer.toJson<String?>(url),
      'tags': serializer.toJson<String>(tags),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  Draft copyWith(
          {String? targetId,
          String? type,
          Value<String?> title = const Value.absent(),
          Value<String?> content = const Value.absent(),
          Value<String?> url = const Value.absent(),
          String? tags,
          DateTime? savedAt}) =>
      Draft(
        targetId: targetId ?? this.targetId,
        type: type ?? this.type,
        title: title.present ? title.value : this.title,
        content: content.present ? content.value : this.content,
        url: url.present ? url.value : this.url,
        tags: tags ?? this.tags,
        savedAt: savedAt ?? this.savedAt,
      );
  Draft copyWithCompanion(DraftsCompanion data) {
    return Draft(
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      url: data.url.present ? data.url.value : this.url,
      tags: data.tags.present ? data.tags.value : this.tags,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Draft(')
          ..write('targetId: $targetId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('tags: $tags, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(targetId, type, title, content, url, tags, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Draft &&
          other.targetId == this.targetId &&
          other.type == this.type &&
          other.title == this.title &&
          other.content == this.content &&
          other.url == this.url &&
          other.tags == this.tags &&
          other.savedAt == this.savedAt);
}

class DraftsCompanion extends UpdateCompanion<Draft> {
  final Value<String> targetId;
  final Value<String> type;
  final Value<String?> title;
  final Value<String?> content;
  final Value<String?> url;
  final Value<String> tags;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.targetId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    this.tags = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String targetId,
    required String type,
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    this.tags = const Value.absent(),
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  })  : targetId = Value(targetId),
        type = Value(type),
        savedAt = Value(savedAt);
  static Insertable<Draft> custom({
    Expression<String>? targetId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? url,
    Expression<String>? tags,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (targetId != null) 'target_id': targetId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (url != null) 'url': url,
      if (tags != null) 'tags': tags,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith(
      {Value<String>? targetId,
      Value<String>? type,
      Value<String?>? title,
      Value<String?>? content,
      Value<String?>? url,
      Value<String>? tags,
      Value<DateTime>? savedAt,
      Value<int>? rowid}) {
    return DraftsCompanion(
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      url: url ?? this.url,
      tags: tags ?? this.tags,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('targetId: $targetId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('tags: $tags, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [items, drafts];
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  Value<String> ownerId,
  required String type,
  Value<String> title,
  Value<String?> content,
  Value<String?> url,
  Value<String> tags,
  Value<bool> archived,
  Value<DateTime?> remindAt,
  Value<String?> attachmentPath,
  Value<String?> attachmentName,
  Value<String?> attachmentMime,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDirty,
  Value<bool> isDeletedLocally,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> type,
  Value<String> title,
  Value<String?> content,
  Value<String?> url,
  Value<String> tags,
  Value<bool> archived,
  Value<DateTime?> remindAt,
  Value<String?> attachmentPath,
  Value<String?> attachmentName,
  Value<String?> attachmentMime,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDirty,
  Value<bool> isDeletedLocally,
  Value<int> rowid,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get remindAt => $composableBuilder(
      column: $table.remindAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachmentPath => $composableBuilder(
      column: $table.attachmentPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachmentName => $composableBuilder(
      column: $table.attachmentName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachmentMime => $composableBuilder(
      column: $table.attachmentMime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeletedLocally => $composableBuilder(
      column: $table.isDeletedLocally,
      builder: (column) => ColumnFilters(column));
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get remindAt => $composableBuilder(
      column: $table.remindAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachmentPath => $composableBuilder(
      column: $table.attachmentPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachmentName => $composableBuilder(
      column: $table.attachmentName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachmentMime => $composableBuilder(
      column: $table.attachmentMime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeletedLocally => $composableBuilder(
      column: $table.isDeletedLocally,
      builder: (column) => ColumnOrderings(column));
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<String> get attachmentPath => $composableBuilder(
      column: $table.attachmentPath, builder: (column) => column);

  GeneratedColumn<String> get attachmentName => $composableBuilder(
      column: $table.attachmentName, builder: (column) => column);

  GeneratedColumn<String> get attachmentMime => $composableBuilder(
      column: $table.attachmentMime, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeletedLocally => $composableBuilder(
      column: $table.isDeletedLocally, builder: (column) => column);
}

class $$ItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
    Item,
    PrefetchHooks Function()> {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<DateTime?> remindAt = const Value.absent(),
            Value<String?> attachmentPath = const Value.absent(),
            Value<String?> attachmentName = const Value.absent(),
            Value<String?> attachmentMime = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion(
            id: id,
            ownerId: ownerId,
            type: type,
            title: title,
            content: content,
            url: url,
            tags: tags,
            archived: archived,
            remindAt: remindAt,
            attachmentPath: attachmentPath,
            attachmentName: attachmentName,
            attachmentMime: attachmentMime,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDirty: isDirty,
            isDeletedLocally: isDeletedLocally,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> ownerId = const Value.absent(),
            required String type,
            Value<String> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<DateTime?> remindAt = const Value.absent(),
            Value<String?> attachmentPath = const Value.absent(),
            Value<String?> attachmentName = const Value.absent(),
            Value<String?> attachmentMime = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion.insert(
            id: id,
            ownerId: ownerId,
            type: type,
            title: title,
            content: content,
            url: url,
            tags: tags,
            archived: archived,
            remindAt: remindAt,
            attachmentPath: attachmentPath,
            attachmentName: attachmentName,
            attachmentMime: attachmentMime,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDirty: isDirty,
            isDeletedLocally: isDeletedLocally,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
    Item,
    PrefetchHooks Function()>;
typedef $$DraftsTableCreateCompanionBuilder = DraftsCompanion Function({
  required String targetId,
  required String type,
  Value<String?> title,
  Value<String?> content,
  Value<String?> url,
  Value<String> tags,
  required DateTime savedAt,
  Value<int> rowid,
});
typedef $$DraftsTableUpdateCompanionBuilder = DraftsCompanion Function({
  Value<String> targetId,
  Value<String> type,
  Value<String?> title,
  Value<String?> content,
  Value<String?> url,
  Value<String> tags,
  Value<DateTime> savedAt,
  Value<int> rowid,
});

class $$DraftsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnFilters(column));
}

class $$DraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnOrderings(column));
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$DraftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DraftsTable,
    Draft,
    $$DraftsTableFilterComposer,
    $$DraftsTableOrderingComposer,
    $$DraftsTableAnnotationComposer,
    $$DraftsTableCreateCompanionBuilder,
    $$DraftsTableUpdateCompanionBuilder,
    (Draft, BaseReferences<_$AppDatabase, $DraftsTable, Draft>),
    Draft,
    PrefetchHooks Function()> {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> targetId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<DateTime> savedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DraftsCompanion(
            targetId: targetId,
            type: type,
            title: title,
            content: content,
            url: url,
            tags: tags,
            savedAt: savedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String targetId,
            required String type,
            Value<String?> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String> tags = const Value.absent(),
            required DateTime savedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DraftsCompanion.insert(
            targetId: targetId,
            type: type,
            title: title,
            content: content,
            url: url,
            tags: tags,
            savedAt: savedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DraftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DraftsTable,
    Draft,
    $$DraftsTableFilterComposer,
    $$DraftsTableOrderingComposer,
    $$DraftsTableAnnotationComposer,
    $$DraftsTableCreateCompanionBuilder,
    $$DraftsTableUpdateCompanionBuilder,
    (Draft, BaseReferences<_$AppDatabase, $DraftsTable, Draft>),
    Draft,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
}
