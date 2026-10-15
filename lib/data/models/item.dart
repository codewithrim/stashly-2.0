import 'package:uuid/uuid.dart';

enum ItemType {
  note,
  link,
  image;

  static ItemType fromString(String val) {
    return ItemType.values.firstWhere(
      (e) => e.name == val.toLowerCase(),
      orElse: () => ItemType.note,
    );
  }
}

class SavedItem {
  final String id;
  final String ownerId;
  final ItemType type;
  final String title;
  final String? content;
  final String? url;
  final List<String> tags;
  final bool archived;
  final DateTime? remindAt;
  final String? attachmentPath;
  final String? attachmentName;
  final String? attachmentMime;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Local sync flags
  final bool isDirty;
  final bool isDeletedLocally;

  const SavedItem({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    this.content,
    this.url,
    this.tags = const [],
    this.archived = false,
    this.remindAt,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentMime,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = false,
    this.isDeletedLocally = false,
  });

  factory SavedItem.create({
    String? id,
    String? ownerId,
    required ItemType type,
    required String title,
    String? content,
    String? url,
    List<String> tags = const [],
    bool archived = false,
    DateTime? remindAt,
    String? attachmentPath,
    String? attachmentName,
    String? attachmentMime,
    bool isDirty = true,
  }) {
    final now = DateTime.now().toUtc();
    return SavedItem(
      id: id ?? const Uuid().v4(),
      ownerId: ownerId ?? 'local',
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
      createdAt: now,
      updatedAt: now,
      isDirty: isDirty,
    );
  }

  SavedItem copyWith({
    String? id,
    String? ownerId,
    ItemType? type,
    String? title,
    String? content,
    String? url,
    List<String>? tags,
    bool? archived,
    DateTime? remindAt,
    String? attachmentPath,
    String? attachmentName,
    String? attachmentMime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeletedLocally,
  }) {
    return SavedItem(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'type': type.name,
      'title': title,
      'content': content,
      'url': url,
      'tags': tags,
      'archived': archived,
      'remind_at': remindAt?.toIso8601String(),
      'attachment_path': attachmentPath,
      'attachment_name': attachmentName,
      'attachment_mime': attachmentMime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? 'local',
      type: ItemType.fromString(json['type'] as String? ?? 'note'),
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      url: json['url'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              const [],
      archived: json['archived'] as bool? ?? false,
      remindAt: json['remind_at'] != null
          ? DateTime.tryParse(json['remind_at'] as String)
          : null,
      attachmentPath: json['attachment_path'] as String?,
      attachmentName: json['attachment_name'] as String?,
      attachmentMime: json['attachment_mime'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now().toUtc(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}
