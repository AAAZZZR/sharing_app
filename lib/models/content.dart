// lib/models/content.dart
class Content {
  final int? id;
  final String url;
  final String platform;
  final String? title;
  final String? thumbnailUrl;
  final String? description;
  final String? aiSummary;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Content({
    this.id,
    required this.url,
    required this.platform,
    this.title,
    this.thumbnailUrl,
    this.description,
    this.aiSummary,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      id: map['id'] as int?,
      url: map['url'] as String,
      platform: map['platform'] as String,
      title: map['title'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String?,
      description: map['description'] as String?,
      aiSummary: map['ai_summary'] as String?,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'url': url,
      'platform': platform,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'description': description,
      'ai_summary': aiSummary,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Content copyWith({
    int? id,
    String? url,
    String? platform,
    String? title,
    String? thumbnailUrl,
    String? description,
    String? aiSummary,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Content(
      id: id ?? this.id,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      aiSummary: aiSummary ?? this.aiSummary,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
