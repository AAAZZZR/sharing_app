// test/database/tag_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:learning_vault/database/tag_dao.dart';

Future<Database> createTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final db = await openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE content (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          url TEXT NOT NULL, platform TEXT NOT NULL, title TEXT,
          thumbnail_url TEXT, description TEXT, ai_summary TEXT,
          note TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE tag (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE
        )
      ''');
      await db.execute('''
        CREATE TABLE content_tag (
          content_id INTEGER NOT NULL,
          tag_id INTEGER NOT NULL,
          PRIMARY KEY (content_id, tag_id),
          FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES tag(id) ON DELETE CASCADE
        )
      ''');
    },
  );
  return db;
}

void main() {
  late Database db;
  late TagDao dao;

  setUp(() async {
    db = await createTestDb();
    dao = TagDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TagDao', () {
    test('insertOrGet 新標籤應回傳新 id', () async {
      final id = await dao.insertOrGet('flutter');
      expect(id, greaterThan(0));
    });

    test('insertOrGet 已存在的標籤應回傳相同 id', () async {
      final id1 = await dao.insertOrGet('flutter');
      final id2 = await dao.insertOrGet('flutter');
      expect(id1, id2);
    });

    test('getAll 應回傳所有標籤', () async {
      await dao.insertOrGet('flutter');
      await dao.insertOrGet('dart');
      final tags = await dao.getAll();
      expect(tags.length, 2);
    });

    test('addTagToContent 應建立關聯', () async {
      final tagId = await dao.insertOrGet('flutter');
      await db.insert('content', {
        'url': 'https://a.com', 'platform': 'youtube',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await dao.addTagToContent(contentId: 1, tagId: tagId);

      final tags = await dao.getTagsForContent(1);
      expect(tags.length, 1);
      expect(tags[0].name, 'flutter');
    });

    test('removeTagFromContent 應移除關聯', () async {
      final tagId = await dao.insertOrGet('flutter');
      await db.insert('content', {
        'url': 'https://a.com', 'platform': 'youtube',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await dao.addTagToContent(contentId: 1, tagId: tagId);

      await dao.removeTagFromContent(contentId: 1, tagId: tagId);

      final tags = await dao.getTagsForContent(1);
      expect(tags.length, 0);
    });

    test('getContentIdsForTag 應回傳有該標籤的 content ids', () async {
      final tagId = await dao.insertOrGet('flutter');
      await db.insert('content', {
        'url': 'https://a.com', 'platform': 'youtube',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await db.insert('content', {
        'url': 'https://b.com', 'platform': 'instagram',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await dao.addTagToContent(contentId: 1, tagId: tagId);
      await dao.addTagToContent(contentId: 2, tagId: tagId);

      final ids = await dao.getContentIdsForTag(tagId);
      expect(ids.length, 2);
      expect(ids, containsAll([1, 2]));
    });

    test('getTagsWithCount 應回傳各標籤的內容數', () async {
      final flutterId = await dao.insertOrGet('flutter');
      final dartId = await dao.insertOrGet('dart');
      await db.insert('content', {
        'url': 'https://a.com', 'platform': 'youtube',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await db.insert('content', {
        'url': 'https://b.com', 'platform': 'instagram',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await dao.addTagToContent(contentId: 1, tagId: flutterId);
      await dao.addTagToContent(contentId: 2, tagId: flutterId);
      await dao.addTagToContent(contentId: 1, tagId: dartId);

      final tagsWithCount = await dao.getTagsWithCount();
      expect(tagsWithCount.length, 2);
      final flutterEntry = tagsWithCount.firstWhere((e) => e.tag.name == 'flutter');
      final dartEntry = tagsWithCount.firstWhere((e) => e.tag.name == 'dart');
      expect(flutterEntry.count, 2);
      expect(dartEntry.count, 1);
    });
  });
}
