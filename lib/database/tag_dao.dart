// lib/database/tag_dao.dart
import 'package:sqflite/sqflite.dart';
import 'package:learning_vault/models/tag.dart';

class TagWithCount {
  final Tag tag;
  final int count;

  TagWithCount({required this.tag, required this.count});
}

class TagDao {
  final Database _db;

  TagDao(this._db);

  Future<int> insertOrGet(String name) async {
    final existing = await _db.query('tag', where: 'name = ?', whereArgs: [name]);
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return _db.insert('tag', {'name': name});
  }

  Future<List<Tag>> getAll() async {
    final maps = await _db.query('tag', orderBy: 'name ASC');
    return maps.map(Tag.fromMap).toList();
  }

  Future<List<Tag>> getTagsForContent(int contentId) async {
    final maps = await _db.rawQuery('''
      SELECT t.id, t.name
      FROM tag t
      INNER JOIN content_tag ct ON ct.tag_id = t.id
      WHERE ct.content_id = ?
      ORDER BY t.name ASC
    ''', [contentId]);
    return maps.map(Tag.fromMap).toList();
  }

  Future<List<int>> getContentIdsForTag(int tagId) async {
    final maps = await _db.query('content_tag',
      columns: ['content_id'], where: 'tag_id = ?', whereArgs: [tagId],
    );
    return maps.map((m) => m['content_id'] as int).toList();
  }

  Future<void> addTagToContent({required int contentId, required int tagId}) async {
    await _db.insert('content_tag',
      {'content_id': contentId, 'tag_id': tagId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeTagFromContent({required int contentId, required int tagId}) async {
    await _db.delete('content_tag',
      where: 'content_id = ? AND tag_id = ?',
      whereArgs: [contentId, tagId],
    );
  }

  Future<List<TagWithCount>> getTagsWithCount() async {
    final maps = await _db.rawQuery('''
      SELECT t.id, t.name, COUNT(ct.content_id) as count
      FROM tag t
      INNER JOIN content_tag ct ON ct.tag_id = t.id
      GROUP BY t.id, t.name
      ORDER BY count DESC
    ''');
    return maps.map((m) => TagWithCount(
      tag: Tag.fromMap(m),
      count: m['count'] as int,
    )).toList();
  }
}
