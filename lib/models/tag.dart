// lib/models/tag.dart
class Tag {
  final int? id;
  final String name;

  Tag({this.id, required this.name});

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'name': name};
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
