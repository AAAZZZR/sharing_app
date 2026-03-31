// lib/database/content_dao.dart
import 'package:sqflite/sqflite.dart';
import 'package:learning_vault/models/content.dart';

class ContentDao {
  final Database _db;

  ContentDao(this._db);

  Future<int> insert(Content content) async {
    return _db.insert('content', content.toMap());
  }

  Future<List<Content>> getAll() async {
    final maps = await _db.query('content', orderBy: 'created_at DESC');
    return maps.map(Content.fromMap).toList();
  }

  Future<Content?> getById(int id) async {
    final maps = await _db.query('content', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Content.fromMap(maps.first);
  }

  Future<List<Content>> getByPlatform(String platform) async {
    final maps = await _db.query('content',
      where: 'platform = ?', whereArgs: [platform],
      orderBy: 'created_at DESC',
    );
    return maps.map(Content.fromMap).toList();
  }

  Future<int> update(Content content) async {
    return _db.update('content', content.toMap(),
      where: 'id = ?', whereArgs: [content.id],
    );
  }

  Future<int> delete(int id) async {
    return _db.delete('content', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Content>> search(String query) async {
    final pattern = '%$query%';
    final maps = await _db.query('content',
      where: 'title LIKE ? OR description LIKE ? OR ai_summary LIKE ? OR note LIKE ?',
      whereArgs: [pattern, pattern, pattern, pattern],
      orderBy: 'created_at DESC',
    );
    return maps.map(Content.fromMap).toList();
  }
}
