// test/database/content_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:learning_vault/database/content_dao.dart';
import 'package:learning_vault/models/content.dart';

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
          url TEXT NOT NULL,
          platform TEXT NOT NULL,
          title TEXT,
          thumbnail_url TEXT,
          description TEXT,
          ai_summary TEXT,
          note TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    },
  );
  return db;
}

void main() {
  late Database db;
  late ContentDao dao;

  setUp(() async {
    db = await createTestDb();
    dao = ContentDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ContentDao', () {
    test('insert 應回傳新的 id', () async {
      final now = DateTime.now();
      final content = Content(
        url: 'https://youtube.com/watch?v=abc',
        platform: 'youtube',
        title: '測試',
        createdAt: now,
        updatedAt: now,
      );

      final id = await dao.insert(content);

      expect(id, greaterThan(0));
    });

    test('getAll 應按 created_at 降序回傳', () async {
      final t1 = DateTime(2026, 3, 30);
      final t2 = DateTime(2026, 3, 31);

      await dao.insert(Content(
        url: 'https://a.com', platform: 'youtube',
        createdAt: t1, updatedAt: t1,
      ));
      await dao.insert(Content(
        url: 'https://b.com', platform: 'instagram',
        createdAt: t2, updatedAt: t2,
      ));

      final results = await dao.getAll();

      expect(results.length, 2);
      expect(results[0].url, 'https://b.com');
      expect(results[1].url, 'https://a.com');
    });

    test('getByPlatform 應只回傳該平台的內容', () async {
      final now = DateTime.now();
      await dao.insert(Content(
        url: 'https://a.com', platform: 'youtube',
        createdAt: now, updatedAt: now,
      ));
      await dao.insert(Content(
        url: 'https://b.com', platform: 'instagram',
        createdAt: now, updatedAt: now,
      ));

      final results = await dao.getByPlatform('youtube');

      expect(results.length, 1);
      expect(results[0].platform, 'youtube');
    });

    test('update 應更新欄位', () async {
      final now = DateTime.now();
      final id = await dao.insert(Content(
        url: 'https://a.com', platform: 'youtube',
        title: '原始', createdAt: now, updatedAt: now,
      ));

      final content = Content(
        id: id, url: 'https://a.com', platform: 'youtube',
        title: '更新後', createdAt: now, updatedAt: DateTime.now(),
      );
      await dao.update(content);

      final result = await dao.getById(id);
      expect(result?.title, '更新後');
    });

    test('delete 應移除內容', () async {
      final now = DateTime.now();
      final id = await dao.insert(Content(
        url: 'https://a.com', platform: 'youtube',
        createdAt: now, updatedAt: now,
      ));

      await dao.delete(id);

      final result = await dao.getById(id);
      expect(result, isNull);
    });

    test('search 應搜尋標題、描述、摘要、筆記', () async {
      final now = DateTime.now();
      await dao.insert(Content(
        url: 'https://a.com', platform: 'youtube',
        title: 'Flutter 教學', createdAt: now, updatedAt: now,
      ));
      await dao.insert(Content(
        url: 'https://b.com', platform: 'instagram',
        note: '這個 Flutter 不錯', createdAt: now, updatedAt: now,
      ));
      await dao.insert(Content(
        url: 'https://c.com', platform: 'facebook',
        title: 'React 教學', createdAt: now, updatedAt: now,
      ));

      final results = await dao.search('Flutter');

      expect(results.length, 2);
    });
  });
}
