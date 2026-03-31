# Learning Vault 實作計劃

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立一個 Flutter 跨平台 app，讓用戶從社群平台分享連結，自動擷取 metadata + AI 摘要，存入本地學習資料庫。

**Architecture:** 全本地架構。Flutter app 直接透過 HTTP 抓取 metadata、呼叫 AI API 生成摘要、存入 SQLite。五個核心模組：Share Intent Handler、Metadata Extractor、AI Summarizer、Local DB、UI Layer。

**Tech Stack:** Flutter 3.x, Dart, sqflite, flutter_riverpod, receive_sharing_intent, dio, html (dart), flutter_secure_storage, url_launcher

---

## 檔案結構

```
lib/
├── main.dart                          # App 進入點，初始化 ProviderScope
├── app.dart                           # MaterialApp 設定，主題、路由
├── models/
│   ├── content.dart                   # Content 資料模型
│   └── tag.dart                       # Tag 資料模型
├── database/
│   ├── database_helper.dart           # SQLite 初始化、版本管理
│   ├── content_dao.dart               # Content CRUD 操作
│   └── tag_dao.dart                   # Tag + ContentTag CRUD 操作
├── services/
│   ├── platform_detector.dart         # URL → 平台辨識
│   ├── metadata_extractor.dart        # URL → og: 標籤擷取
│   ├── ai_service.dart                # AI 抽象介面
│   ├── openai_service.dart            # OpenAI 實作
│   ├── claude_service.dart            # Claude 實作
│   └── settings_service.dart          # API key 安全儲存
├── providers/
│   ├── content_provider.dart          # Content 狀態管理
│   ├── tag_provider.dart              # Tag 狀態管理
│   └── settings_provider.dart         # 設定狀態管理
├── screens/
│   ├── home_screen.dart               # 首頁時間軸
│   ├── detail_screen.dart             # 內容詳情頁
│   ├── share_receive_screen.dart      # 分享接收頁
│   ├── tags_screen.dart               # 標籤瀏覽頁
│   ├── search_screen.dart             # 搜尋頁
│   └── settings_screen.dart           # 設定頁
└── widgets/
    ├── content_card.dart              # 內容卡片元件
    ├── platform_chip.dart             # 平台篩選 chip
    └── tag_chip.dart                  # 標籤 chip

test/
├── models/
│   ├── content_test.dart
│   └── tag_test.dart
├── database/
│   ├── content_dao_test.dart
│   └── tag_dao_test.dart
├── services/
│   ├── platform_detector_test.dart
│   ├── metadata_extractor_test.dart
│   └── ai_service_test.dart
└── screens/
    ├── home_screen_test.dart
    └── share_receive_screen_test.dart
```

---

## Task 1: Flutter 專案建立與依賴設定

**Files:**
- Create: Flutter project（`flutter create`）
- Modify: `pubspec.yaml`

- [ ] **Step 1: 建立 Flutter 專案**

```bash
cd C:/Users/Owner/Desktop/flutter_practice
flutter create --org com.example --project-name learning_vault .
```

- [ ] **Step 2: 初始化 git**

```bash
cd C:/Users/Owner/Desktop/flutter_practice
git init
git add .
git commit -m "chore: 初始化 Flutter 專案"
```

- [ ] **Step 3: 加入依賴到 pubspec.yaml**

把 `pubspec.yaml` 的 `dependencies` 和 `dev_dependencies` 改成：

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.1
  path: ^1.9.0
  path_provider: ^2.1.5
  flutter_riverpod: ^2.6.1
  receive_sharing_intent: ^1.8.1
  dio: ^5.7.0
  html: ^0.15.5
  flutter_secure_storage: ^9.2.4
  url_launcher: ^6.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mockito: ^5.4.5
  build_runner: ^2.4.14
```

- [ ] **Step 4: 安裝依賴**

```bash
cd C:/Users/Owner/Desktop/flutter_practice
flutter pub get
```

Expected: 無錯誤，所有依賴安裝成功。

- [ ] **Step 5: 建立目錄結構**

```bash
cd C:/Users/Owner/Desktop/flutter_practice
mkdir -p lib/models lib/database lib/services lib/providers lib/screens lib/widgets
mkdir -p test/models test/database test/services test/screens
```

- [ ] **Step 6: 確認專案可建置**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 7: Commit**

```bash
git add .
git commit -m "chore: 加入專案依賴與目錄結構"
```

---

## Task 2: 資料模型 — Content

**Files:**
- Create: `lib/models/content.dart`
- Test: `test/models/content_test.dart`

- [ ] **Step 1: 寫測試**

```dart
// test/models/content_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_vault/models/content.dart';

void main() {
  group('Content', () {
    test('fromMap 應正確從 Map 建立 Content', () {
      final map = {
        'id': 1,
        'url': 'https://youtube.com/watch?v=abc',
        'platform': 'youtube',
        'title': '測試標題',
        'thumbnail_url': 'https://img.youtube.com/vi/abc/0.jpg',
        'description': '測試描述',
        'ai_summary': 'AI 摘要',
        'note': '我的筆記',
        'created_at': '2026-03-31T12:00:00.000',
        'updated_at': '2026-03-31T12:00:00.000',
      };

      final content = Content.fromMap(map);

      expect(content.id, 1);
      expect(content.url, 'https://youtube.com/watch?v=abc');
      expect(content.platform, 'youtube');
      expect(content.title, '測試標題');
      expect(content.thumbnailUrl, 'https://img.youtube.com/vi/abc/0.jpg');
      expect(content.description, '測試描述');
      expect(content.aiSummary, 'AI 摘要');
      expect(content.note, '我的筆記');
    });

    test('toMap 應正確轉換為 Map', () {
      final now = DateTime(2026, 3, 31, 12, 0, 0);
      final content = Content(
        url: 'https://youtube.com/watch?v=abc',
        platform: 'youtube',
        title: '測試標題',
        createdAt: now,
        updatedAt: now,
      );

      final map = content.toMap();

      expect(map['url'], 'https://youtube.com/watch?v=abc');
      expect(map['platform'], 'youtube');
      expect(map['title'], '測試標題');
      expect(map.containsKey('id'), false);
    });

    test('toMap 帶 id 時應包含 id', () {
      final now = DateTime(2026, 3, 31, 12, 0, 0);
      final content = Content(
        id: 5,
        url: 'https://youtube.com/watch?v=abc',
        platform: 'youtube',
        createdAt: now,
        updatedAt: now,
      );

      final map = content.toMap();

      expect(map['id'], 5);
    });

    test('copyWith 應正確複製並覆蓋欄位', () {
      final now = DateTime(2026, 3, 31, 12, 0, 0);
      final content = Content(
        id: 1,
        url: 'https://youtube.com/watch?v=abc',
        platform: 'youtube',
        title: '原始標題',
        createdAt: now,
        updatedAt: now,
      );

      final updated = content.copyWith(title: '新標題', note: '新筆記');

      expect(updated.id, 1);
      expect(updated.title, '新標題');
      expect(updated.note, '新筆記');
      expect(updated.url, 'https://youtube.com/watch?v=abc');
    });

    test('nullable 欄位預設為 null', () {
      final content = Content(
        url: 'https://example.com',
        platform: 'other',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(content.id, isNull);
      expect(content.title, isNull);
      expect(content.thumbnailUrl, isNull);
      expect(content.description, isNull);
      expect(content.aiSummary, isNull);
      expect(content.note, isNull);
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

```bash
flutter test test/models/content_test.dart
```

Expected: FAIL — `package:learning_vault/models/content.dart` not found.

- [ ] **Step 3: 實作 Content model**

```dart
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
```

- [ ] **Step 4: 執行測試確認通過**

```bash
flutter test test/models/content_test.dart
```

Expected: All tests passed.

- [ ] **Step 5: Commit**

```bash
git add lib/models/content.dart test/models/content_test.dart
git commit -m "feat: 新增 Content 資料模型"
```

---

## Task 3: 資料模型 — Tag

**Files:**
- Create: `lib/models/tag.dart`
- Test: `test/models/tag_test.dart`

- [ ] **Step 1: 寫測試**

```dart
// test/models/tag_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_vault/models/tag.dart';

void main() {
  group('Tag', () {
    test('fromMap 應正確從 Map 建立 Tag', () {
      final map = {'id': 1, 'name': 'flutter'};
      final tag = Tag.fromMap(map);

      expect(tag.id, 1);
      expect(tag.name, 'flutter');
    });

    test('toMap 不帶 id', () {
      final tag = Tag(name: 'flutter');
      final map = tag.toMap();

      expect(map['name'], 'flutter');
      expect(map.containsKey('id'), false);
    });

    test('toMap 帶 id', () {
      final tag = Tag(id: 3, name: 'dart');
      final map = tag.toMap();

      expect(map['id'], 3);
      expect(map['name'], 'dart');
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

```bash
flutter test test/models/tag_test.dart
```

Expected: FAIL.

- [ ] **Step 3: 實作 Tag model**

```dart
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
```

- [ ] **Step 4: 執行測試確認通過**

```bash
flutter test test/models/tag_test.dart
```

Expected: All tests passed.

- [ ] **Step 5: Commit**

```bash
git add lib/models/tag.dart test/models/tag_test.dart
git commit -m "feat: 新增 Tag 資料模型"
```

---

## Task 4: 資料庫層 — DatabaseHelper

**Files:**
- Create: `lib/database/database_helper.dart`

注意：sqflite 在 Flutter 測試中需要真實環境（不能在純 unit test 中跑），所以 DatabaseHelper 本身不寫 unit test。DAO 層會在 Task 5/6 中透過整合測試驗證。

- [ ] **Step 1: 實作 DatabaseHelper**

```dart
// lib/database/database_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'learning_vault.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }

  /// 僅用於測試，重置 singleton
  static void resetForTest() {
    _database = null;
  }
}
```

- [ ] **Step 2: 確認編譯無誤**

```bash
flutter analyze lib/database/database_helper.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/database/database_helper.dart
git commit -m "feat: 新增 DatabaseHelper，建立 SQLite schema"
```

---

## Task 5: 資料庫層 — ContentDao

**Files:**
- Create: `lib/database/content_dao.dart`
- Test: `test/database/content_dao_test.dart`

注意：sqflite 的 unit test 需要用 `sqflite_common_ffi` 在桌面環境跑。為了讓測試可以跑，我們建立一個可注入 Database 的 DAO。

- [ ] **Step 1: 加入測試依賴**

在 `pubspec.yaml` 的 `dev_dependencies` 加入：

```yaml
  sqflite_common_ffi: ^2.3.4+4
```

然後執行：

```bash
flutter pub get
```

- [ ] **Step 2: 寫測試**

```dart
// test/database/content_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
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
        url: 'https://a.com',
        platform: 'youtube',
        createdAt: t1,
        updatedAt: t1,
      ));
      await dao.insert(Content(
        url: 'https://b.com',
        platform: 'instagram',
        createdAt: t2,
        updatedAt: t2,
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
```

- [ ] **Step 3: 執行測試確認失敗**

```bash
flutter test test/database/content_dao_test.dart
```

Expected: FAIL — `content_dao.dart` not found.

- [ ] **Step 4: 實作 ContentDao**

```dart
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
    final maps = await _db.query(
      'content',
      orderBy: 'created_at DESC',
    );
    return maps.map(Content.fromMap).toList();
  }

  Future<Content?> getById(int id) async {
    final maps = await _db.query(
      'content',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Content.fromMap(maps.first);
  }

  Future<List<Content>> getByPlatform(String platform) async {
    final maps = await _db.query(
      'content',
      where: 'platform = ?',
      whereArgs: [platform],
      orderBy: 'created_at DESC',
    );
    return maps.map(Content.fromMap).toList();
  }

  Future<int> update(Content content) async {
    return _db.update(
      'content',
      content.toMap(),
      where: 'id = ?',
      whereArgs: [content.id],
    );
  }

  Future<int> delete(int id) async {
    return _db.delete(
      'content',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Content>> search(String query) async {
    final pattern = '%$query%';
    final maps = await _db.query(
      'content',
      where: 'title LIKE ? OR description LIKE ? OR ai_summary LIKE ? OR note LIKE ?',
      whereArgs: [pattern, pattern, pattern, pattern],
      orderBy: 'created_at DESC',
    );
    return maps.map(Content.fromMap).toList();
  }
}
```

- [ ] **Step 5: 執行測試確認通過**

```bash
flutter test test/database/content_dao_test.dart
```

Expected: All tests passed.

- [ ] **Step 6: Commit**

```bash
git add lib/database/content_dao.dart test/database/content_dao_test.dart pubspec.yaml pubspec.lock
git commit -m "feat: 新增 ContentDao，支援 CRUD 與搜尋"
```

---

## Task 6: 資料庫層 — TagDao

**Files:**
- Create: `lib/database/tag_dao.dart`
- Test: `test/database/tag_dao_test.dart`

- [ ] **Step 1: 寫測試**

```dart
// test/database/tag_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:learning_vault/database/tag_dao.dart';
import 'package:learning_vault/models/tag.dart';

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
      // 手動插入一個 content
      await db.insert('content', {
        'url': 'https://a.com',
        'platform': 'youtube',
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
        'url': 'https://a.com',
        'platform': 'youtube',
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
```

- [ ] **Step 2: 執行測試確認失敗**

```bash
flutter test test/database/tag_dao_test.dart
```

Expected: FAIL.

- [ ] **Step 3: 實作 TagDao**

```dart
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
    final existing = await _db.query(
      'tag',
      where: 'name = ?',
      whereArgs: [name],
    );
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
    final maps = await _db.query(
      'content_tag',
      columns: ['content_id'],
      where: 'tag_id = ?',
      whereArgs: [tagId],
    );
    return maps.map((m) => m['content_id'] as int).toList();
  }

  Future<void> addTagToContent({
    required int contentId,
    required int tagId,
  }) async {
    await _db.insert(
      'content_tag',
      {'content_id': contentId, 'tag_id': tagId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeTagFromContent({
    required int contentId,
    required int tagId,
  }) async {
    await _db.delete(
      'content_tag',
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
```

- [ ] **Step 4: 執行測試確認通過**

```bash
flutter test test/database/tag_dao_test.dart
```

Expected: All tests passed.

- [ ] **Step 5: Commit**

```bash
git add lib/database/tag_dao.dart test/database/tag_dao_test.dart
git commit -m "feat: 新增 TagDao，支援標籤 CRUD 與 content-tag 關聯"
```

---

## Task 7: 平台辨識服務

**Files:**
- Create: `lib/services/platform_detector.dart`
- Test: `test/services/platform_detector_test.dart`

- [ ] **Step 1: 寫測試**

```dart
// test/services/platform_detector_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_vault/services/platform_detector.dart';

void main() {
  group('PlatformDetector', () {
    test('辨識 youtube.com', () {
      expect(
        PlatformDetector.detect('https://www.youtube.com/watch?v=abc'),
        'youtube',
      );
    });

    test('辨識 youtu.be 短連結', () {
      expect(
        PlatformDetector.detect('https://youtu.be/abc123'),
        'youtube',
      );
    });

    test('辨識 instagram.com', () {
      expect(
        PlatformDetector.detect('https://www.instagram.com/p/abc123/'),
        'instagram',
      );
    });

    test('辨識 facebook.com', () {
      expect(
        PlatformDetector.detect('https://www.facebook.com/post/123'),
        'facebook',
      );
    });

    test('辨識 fb.watch', () {
      expect(
        PlatformDetector.detect('https://fb.watch/abc123/'),
        'facebook',
      );
    });

    test('辨識 tiktok.com', () {
      expect(
        PlatformDetector.detect('https://www.tiktok.com/@user/video/123'),
        'tiktok',
      );
    });

    test('辨識 douyin.com', () {
      expect(
        PlatformDetector.detect('https://www.douyin.com/video/123'),
        'tiktok',
      );
    });

    test('未知 domain 回傳 other', () {
      expect(
        PlatformDetector.detect('https://example.com/page'),
        'other',
      );
    });

    test('無效 URL 回傳 other', () {
      expect(
        PlatformDetector.detect('not a url'),
        'other',
      );
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

```bash
flutter test test/services/platform_detector_test.dart
```

Expected: FAIL.

- [ ] **Step 3: 實作 PlatformDetector**

```dart
// lib/services/platform_detector.dart
class PlatformDetector {
  static const _platformRules = <String, List<String>>{
    'youtube': ['youtube.com', 'youtu.be'],
    'instagram': ['instagram.com'],
    'facebook': ['facebook.com', 'fb.com', 'fb.watch'],
    'tiktok': ['tiktok.com', 'douyin.com'],
  };

  static String detect(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return 'other';

    final host = uri.host.toLowerCase().replaceFirst('www.', '');

    for (final entry in _platformRules.entries) {
      for (final domain in entry.value) {
        if (host == domain || host.endsWith('.$domain')) {
          return entry.key;
        }
      }
    }

    return 'other';
  }
}
```

- [ ] **Step 4: 執行測試確認通過**

```bash
flutter test test/services/platform_detector_test.dart
```

Expected: All tests passed.

- [ ] **Step 5: Commit**

```bash
git add lib/services/platform_detector.dart test/services/platform_detector_test.dart
git commit -m "feat: 新增 PlatformDetector，辨識社群平台 URL"
```

---

## Task 8: Metadata 擷取服務

**Files:**
- Create: `lib/services/metadata_extractor.dart`
- Test: `test/services/metadata_extractor_test.dart`

- [ ] **Step 1: 寫測試**

```dart
// test/services/metadata_extractor_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_vault/services/metadata_extractor.dart';

void main() {
  group('MetadataExtractor', () {
    group('parseHtml', () {
      test('應擷取 og:title, og:image, og:description', () {
        const html = '''
        <html><head>
          <meta property="og:title" content="測試標題" />
          <meta property="og:image" content="https://img.com/thumb.jpg" />
          <meta property="og:description" content="測試描述" />
        </head><body></body></html>
        ''';

        final result = MetadataExtractor.parseHtml(html);

        expect(result.title, '測試標題');
        expect(result.thumbnailUrl, 'https://img.com/thumb.jpg');
        expect(result.description, '測試描述');
      });

      test('og 標籤缺失時應 fallback 到 title 和 meta description', () {
        const html = '''
        <html><head>
          <title>Fallback 標題</title>
          <meta name="description" content="Fallback 描述" />
        </head><body></body></html>
        ''';

        final result = MetadataExtractor.parseHtml(html);

        expect(result.title, 'Fallback 標題');
        expect(result.description, 'Fallback 描述');
        expect(result.thumbnailUrl, isNull);
      });

      test('完全沒有 metadata 時應回傳全 null', () {
        const html = '<html><head></head><body>Hello</body></html>';

        final result = MetadataExtractor.parseHtml(html);

        expect(result.title, isNull);
        expect(result.description, isNull);
        expect(result.thumbnailUrl, isNull);
      });
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

```bash
flutter test test/services/metadata_extractor_test.dart
```

Expected: FAIL.

- [ ] **Step 3: 實作 MetadataExtractor**

```dart
// lib/services/metadata_extractor.dart
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

class Metadata {
  final String? title;
  final String? thumbnailUrl;
  final String? description;

  Metadata({this.title, this.thumbnailUrl, this.description});
}

class MetadataExtractor {
  final Dio _dio;

  MetadataExtractor(this._dio);

  /// 對 URL 發 HTTP GET，解析 HTML 擷取 metadata。
  Future<Metadata> extract(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (compatible; LearningVault/1.0)',
          },
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return parseHtml(response.data as String);
    } catch (_) {
      return Metadata();
    }
  }

  /// 純粹解析 HTML 字串，不發 HTTP 請求。方便測試。
  static Metadata parseHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    final metas = document.querySelectorAll('meta');

    String? ogTitle;
    String? ogImage;
    String? ogDescription;
    String? metaDescription;

    for (final meta in metas) {
      final property = meta.attributes['property'] ?? '';
      final name = meta.attributes['name'] ?? '';
      final content = meta.attributes['content'] ?? '';

      if (property == 'og:title') ogTitle = content;
      if (property == 'og:image') ogImage = content;
      if (property == 'og:description') ogDescription = content;
      if (name == 'description') metaDescription = content;
    }

    final titleElement = document.querySelector('title');
    final fallbackTitle = titleElement?.text;

    return Metadata(
      title: ogTitle ?? fallbackTitle,
      thumbnailUrl: ogImage,
      description: ogDescription ?? metaDescription,
    );
  }
}
```

- [ ] **Step 4: 執行測試確認通過**

```bash
flutter test test/services/metadata_extractor_test.dart
```

Expected: All tests passed.

- [ ] **Step 5: Commit**

```bash
git add lib/services/metadata_extractor.dart test/services/metadata_extractor_test.dart
git commit -m "feat: 新增 MetadataExtractor，擷取 og: 標籤與 fallback"
```

---

## Task 9: AI 摘要服務

**Files:**
- Create: `lib/services/ai_service.dart`
- Create: `lib/services/openai_service.dart`
- Create: `lib/services/claude_service.dart`
- Test: `test/services/ai_service_test.dart`

- [ ] **Step 1: 寫測試**

```dart
// test/services/ai_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_vault/services/ai_service.dart';
import 'package:learning_vault/services/openai_service.dart';
import 'package:learning_vault/services/claude_service.dart';

/// 假的 HTTP client，回傳固定的 AI 回應
class FakeAiService implements AiService {
  @override
  Future<String> summarize({
    required String title,
    required String description,
    required String url,
  }) async {
    return '這是一個關於 $title 的摘要';
  }
}

void main() {
  group('AiService', () {
    test('FakeAiService 應回傳摘要', () async {
      final service = FakeAiService();

      final result = await service.summarize(
        title: 'Flutter 教學',
        description: '學習 Flutter 的基礎',
        url: 'https://youtube.com/watch?v=abc',
      );

      expect(result, contains('Flutter 教學'));
    });

    test('OpenAiService 應實作 AiService', () {
      // 只驗證型別，不發真實 API 請求
      final service = OpenAiService(apiKey: 'test-key');
      expect(service, isA<AiService>());
    });

    test('ClaudeService 應實作 AiService', () {
      final service = ClaudeService(apiKey: 'test-key');
      expect(service, isA<AiService>());
    });
  });

  group('buildPrompt', () {
    test('應包含標題和描述', () {
      final prompt = AiService.buildPrompt(
        title: '測試標題',
        description: '測試描述',
        url: 'https://example.com',
      );

      expect(prompt, contains('測試標題'));
      expect(prompt, contains('測試描述'));
      expect(prompt, contains('https://example.com'));
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

```bash
flutter test test/services/ai_service_test.dart
```

Expected: FAIL.

- [ ] **Step 3: 實作 AiService 抽象類別**

```dart
// lib/services/ai_service.dart
abstract class AiService {
  Future<String> summarize({
    required String title,
    required String description,
    required String url,
  });

  static String buildPrompt({
    required String title,
    required String description,
    required String url,
  }) {
    return '''請為以下內容生成重點摘要，用繁體中文，以條列式呈現 3-5 個重點：

標題：$title
描述：$description
來源：$url

請直接回傳摘要，不需要額外的前綴或說明。''';
  }
}
```

- [ ] **Step 4: 實作 OpenAiService**

```dart
// lib/services/openai_service.dart
import 'package:dio/dio.dart';
import 'package:learning_vault/services/ai_service.dart';

class OpenAiService implements AiService {
  final String apiKey;
  final Dio _dio;

  OpenAiService({required this.apiKey, Dio? dio})
      : _dio = dio ?? Dio();

  @override
  Future<String> summarize({
    required String title,
    required String description,
    required String url,
  }) async {
    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'user',
            'content': AiService.buildPrompt(
              title: title,
              description: description,
              url: url,
            ),
          },
        ],
        'max_tokens': 500,
      },
    );

    final choices = response.data['choices'] as List;
    return choices[0]['message']['content'] as String;
  }
}
```

- [ ] **Step 5: 實作 ClaudeService**

```dart
// lib/services/claude_service.dart
import 'package:dio/dio.dart';
import 'package:learning_vault/services/ai_service.dart';

class ClaudeService implements AiService {
  final String apiKey;
  final Dio _dio;

  ClaudeService({required this.apiKey, Dio? dio})
      : _dio = dio ?? Dio();

  @override
  Future<String> summarize({
    required String title,
    required String description,
    required String url,
  }) async {
    final response = await _dio.post(
      'https://api.anthropic.com/v1/messages',
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'claude-haiku-4-5-20251001',
        'max_tokens': 500,
        'messages': [
          {
            'role': 'user',
            'content': AiService.buildPrompt(
              title: title,
              description: description,
              url: url,
            ),
          },
        ],
      },
    );

    final content = response.data['content'] as List;
    return content[0]['text'] as String;
  }
}
```

- [ ] **Step 6: 執行測試確認通過**

```bash
flutter test test/services/ai_service_test.dart
```

Expected: All tests passed.

- [ ] **Step 7: Commit**

```bash
git add lib/services/ai_service.dart lib/services/openai_service.dart lib/services/claude_service.dart test/services/ai_service_test.dart
git commit -m "feat: 新增 AI 摘要服務，支援 OpenAI 與 Claude"
```

---

## Task 10: 設定服務（API Key 安全儲存）

**Files:**
- Create: `lib/services/settings_service.dart`

注意：flutter_secure_storage 需要原生平台，無法在純 unit test 中測試。在 UI 整合時驗證。

- [ ] **Step 1: 實作 SettingsService**

```dart
// lib/services/settings_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AiProvider { openai, claude }

class SettingsService {
  final FlutterSecureStorage _storage;

  SettingsService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // AI Provider 選擇
  Future<AiProvider> getAiProvider() async {
    final value = await _storage.read(key: 'ai_provider');
    if (value == 'claude') return AiProvider.claude;
    return AiProvider.openai;
  }

  Future<void> setAiProvider(AiProvider provider) async {
    await _storage.write(key: 'ai_provider', value: provider.name);
  }

  // API Keys
  Future<String?> getApiKey(AiProvider provider) async {
    return _storage.read(key: '${provider.name}_api_key');
  }

  Future<void> setApiKey(AiProvider provider, String key) async {
    await _storage.write(key: '${provider.name}_api_key', value: key);
  }

  Future<bool> hasApiKey(AiProvider provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }
}
```

- [ ] **Step 2: 確認編譯無誤**

```bash
flutter analyze lib/services/settings_service.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/services/settings_service.dart
git commit -m "feat: 新增 SettingsService，安全儲存 API key"
```

---

## Task 11: Riverpod Providers

**Files:**
- Create: `lib/providers/content_provider.dart`
- Create: `lib/providers/tag_provider.dart`
- Create: `lib/providers/settings_provider.dart`

- [ ] **Step 1: 實作 SettingsProvider**

```dart
// lib/providers/settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/services/settings_service.dart';
import 'package:learning_vault/services/ai_service.dart';
import 'package:learning_vault/services/openai_service.dart';
import 'package:learning_vault/services/claude_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final aiProviderProvider =
    StateNotifierProvider<AiProviderNotifier, AiProvider>((ref) {
  return AiProviderNotifier(ref.read(settingsServiceProvider));
});

class AiProviderNotifier extends StateNotifier<AiProvider> {
  final SettingsService _settings;

  AiProviderNotifier(this._settings) : super(AiProvider.openai) {
    _load();
  }

  Future<void> _load() async {
    state = await _settings.getAiProvider();
  }

  Future<void> setProvider(AiProvider provider) async {
    await _settings.setAiProvider(provider);
    state = provider;
  }
}

final aiServiceProvider = FutureProvider<AiService?>((ref) async {
  final provider = ref.watch(aiProviderProvider);
  final settings = ref.read(settingsServiceProvider);
  final apiKey = await settings.getApiKey(provider);

  if (apiKey == null || apiKey.isEmpty) return null;

  switch (provider) {
    case AiProvider.openai:
      return OpenAiService(apiKey: apiKey);
    case AiProvider.claude:
      return ClaudeService(apiKey: apiKey);
  }
});
```

- [ ] **Step 2: 實作 ContentProvider**

```dart
// lib/providers/content_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/database/database_helper.dart';
import 'package:learning_vault/database/content_dao.dart';
import 'package:learning_vault/models/content.dart';

final contentDaoProvider = FutureProvider<ContentDao>((ref) async {
  final db = await DatabaseHelper.instance.database;
  return ContentDao(db);
});

final contentListProvider =
    StateNotifierProvider<ContentListNotifier, AsyncValue<List<Content>>>((ref) {
  return ContentListNotifier(ref);
});

class ContentListNotifier extends StateNotifier<AsyncValue<List<Content>>> {
  final Ref _ref;

  ContentListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final dao = await _ref.read(contentDaoProvider.future);
      final contents = await dao.getAll();
      state = AsyncValue.data(contents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadByPlatform(String platform) async {
    state = const AsyncValue.loading();
    try {
      final dao = await _ref.read(contentDaoProvider.future);
      final contents = await dao.getByPlatform(platform);
      state = AsyncValue.data(contents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> add(Content content) async {
    final dao = await _ref.read(contentDaoProvider.future);
    final id = await dao.insert(content);
    await loadAll();
    return id;
  }

  Future<void> updateContent(Content content) async {
    final dao = await _ref.read(contentDaoProvider.future);
    await dao.update(content);
    await loadAll();
  }

  Future<void> remove(int id) async {
    final dao = await _ref.read(contentDaoProvider.future);
    await dao.delete(id);
    await loadAll();
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    try {
      final dao = await _ref.read(contentDaoProvider.future);
      final contents = await dao.search(query);
      state = AsyncValue.data(contents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

- [ ] **Step 3: 實作 TagProvider**

```dart
// lib/providers/tag_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/database/database_helper.dart';
import 'package:learning_vault/database/tag_dao.dart';
import 'package:learning_vault/models/tag.dart';

final tagDaoProvider = FutureProvider<TagDao>((ref) async {
  final db = await DatabaseHelper.instance.database;
  return TagDao(db);
});

final tagsWithCountProvider =
    StateNotifierProvider<TagsWithCountNotifier, AsyncValue<List<TagWithCount>>>((ref) {
  return TagsWithCountNotifier(ref);
});

class TagsWithCountNotifier
    extends StateNotifier<AsyncValue<List<TagWithCount>>> {
  final Ref _ref;

  TagsWithCountNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final dao = await _ref.read(tagDaoProvider.future);
      final tags = await dao.getTagsWithCount();
      state = AsyncValue.data(tags);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final contentTagsProvider =
    FutureProvider.family<List<Tag>, int>((ref, contentId) async {
  final dao = await ref.read(tagDaoProvider.future);
  return dao.getTagsForContent(contentId);
});
```

- [ ] **Step 4: 確認編譯無誤**

```bash
flutter analyze lib/providers/
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/providers/content_provider.dart lib/providers/tag_provider.dart lib/providers/settings_provider.dart
git commit -m "feat: 新增 Riverpod providers（content, tag, settings）"
```

---

## Task 12: App Shell — 主題、導航、路由

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`

- [ ] **Step 1: 實作 main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LearningVaultApp()));
}
```

- [ ] **Step 2: 實作 app.dart（含底部導航）**

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:learning_vault/screens/home_screen.dart';
import 'package:learning_vault/screens/tags_screen.dart';
import 'package:learning_vault/screens/search_screen.dart';
import 'package:learning_vault/screens/settings_screen.dart';

class LearningVaultApp extends StatelessWidget {
  const LearningVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '學習庫',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7FD8BE),
          secondary: const Color(0xFFF6C177),
          surface: const Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        cardColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          elevation: 0,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    TagsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: const Color(0xFF7FD8BE),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.label), label: '標籤'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜尋'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 建立空的 screen 佔位（讓 app 能編譯）**

每個 screen 先放最小的 Scaffold，後續 task 再填入內容：

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('首頁')),
    );
  }
}
```

```dart
// lib/screens/tags_screen.dart
import 'package:flutter/material.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('標籤')),
    );
  }
}
```

```dart
// lib/screens/search_screen.dart
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('搜尋')),
    );
  }
}
```

```dart
// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('設定')),
    );
  }
}
```

- [ ] **Step 4: 確認 app 可編譯**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/app.dart lib/screens/
git commit -m "feat: 新增 App Shell，含暗色主題與底部導航"
```

---

## Task 13: 首頁畫面 — 時間軸 + 平台篩選

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Create: `lib/widgets/content_card.dart`
- Create: `lib/widgets/platform_chip.dart`

- [ ] **Step 1: 實作 PlatformChip widget**

```dart
// lib/widgets/platform_chip.dart
import 'package:flutter/material.dart';

class PlatformChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PlatformChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static Color colorForPlatform(String platform) {
    switch (platform) {
      case 'youtube':
        return const Color(0xFFC4A7E7);
      case 'instagram':
        return const Color(0xFFEB6F92);
      case 'facebook':
        return const Color(0xFF89B4FA);
      case 'tiktok':
        return const Color(0xFF9CCFD8);
      default:
        return Colors.grey;
    }
  }

  static String labelForPlatform(String platform) {
    switch (platform) {
      case 'youtube':
        return 'YouTube';
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'tiktok':
        return 'TikTok';
      default:
        return platform;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2A2A4A)
              : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected
                ? const Color(0xFF7FD8BE)
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 實作 ContentCard widget**

```dart
// lib/widgets/content_card.dart
import 'package:flutter/material.dart';
import 'package:learning_vault/models/content.dart';
import 'package:learning_vault/widgets/platform_chip.dart';

class ContentCard extends StatelessWidget {
  final Content content;
  final List<String> tags;
  final VoidCallback onTap;

  const ContentCard({
    super.key,
    required this.content,
    this.tags = const [],
    required this.onTap,
  });

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays} 天前';
    if (diff.inHours > 0) return '${diff.inHours} 小時前';
    if (diff.inMinutes > 0) return '${diff.inMinutes} 分鐘前';
    return '剛剛';
  }

  @override
  Widget build(BuildContext context) {
    final platformColor = PlatformChip.colorForPlatform(content.platform);
    final platformLabel = PlatformChip.labelForPlatform(content.platform);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 縮圖
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: content.thumbnailUrl != null
                      ? Image.network(
                          content.thumbnailUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderThumb(),
                        )
                      : _placeholderThumb(),
                ),
                const SizedBox(width: 10),
                // 標題與描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$platformLabel · ${_timeAgo(content.createdAt)}',
                        style: TextStyle(fontSize: 11, color: platformColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        content.title ?? content.url,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (content.aiSummary != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          content.aiSummary!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // 標籤
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A4A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFF6C177),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.link, color: Colors.grey),
    );
  }
}
```

- [ ] **Step 3: 實作 HomeScreen**

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/providers/content_provider.dart';
import 'package:learning_vault/providers/tag_provider.dart';
import 'package:learning_vault/widgets/content_card.dart';
import 'package:learning_vault/widgets/platform_chip.dart';
import 'package:learning_vault/screens/detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedPlatform = 'all';

  final _platforms = ['all', 'youtube', 'instagram', 'facebook', 'tiktok'];

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentListProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '學習庫',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // 平台篩選 chips
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _platforms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final platform = _platforms[index];
                  return PlatformChip(
                    label: platform == 'all'
                        ? '全部'
                        : PlatformChip.labelForPlatform(platform),
                    selected: _selectedPlatform == platform,
                    onTap: () {
                      setState(() => _selectedPlatform = platform);
                      if (platform == 'all') {
                        ref.read(contentListProvider.notifier).loadAll();
                      } else {
                        ref.read(contentListProvider.notifier).loadByPlatform(platform);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // 內容列表
            Expanded(
              child: contentAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('錯誤：$err')),
                data: (contents) {
                  if (contents.isEmpty) {
                    return const Center(
                      child: Text(
                        '還沒有內容\n從其他 app 分享連結到這裡',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final content = contents[index];
                      final tagsAsync = ref.watch(
                        contentTagsProvider(content.id!),
                      );
                      final tagNames = tagsAsync.when(
                        data: (tags) => tags.map((t) => t.name).toList(),
                        loading: () => <String>[],
                        error: (_, __) => <String>[],
                      );
                      return ContentCard(
                        content: content,
                        tags: tagNames,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(contentId: content.id!),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 建立空的 DetailScreen 佔位**

```dart
// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final int contentId;

  const DetailScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('詳情')),
      body: Center(child: Text('Content #$contentId')),
    );
  }
}
```

- [ ] **Step 5: 確認編譯無誤**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/home_screen.dart lib/screens/detail_screen.dart lib/widgets/content_card.dart lib/widgets/platform_chip.dart
git commit -m "feat: 新增首頁時間軸，含平台篩選與內容卡片"
```

---

## Task 14: 內容詳情頁

**Files:**
- Modify: `lib/screens/detail_screen.dart`
- Create: `lib/widgets/tag_chip.dart`

- [ ] **Step 1: 實作 TagChip widget**

```dart
// lib/widgets/tag_chip.dart
import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;

  const TagChip({
    super.key,
    required this.label,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$label',
            style: const TextStyle(fontSize: 12, color: Color(0xFFF6C177)),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close, size: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 實作 DetailScreen**

```dart
// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_vault/providers/content_provider.dart';
import 'package:learning_vault/providers/tag_provider.dart';
import 'package:learning_vault/widgets/platform_chip.dart';
import 'package:learning_vault/widgets/tag_chip.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final int contentId;

  const DetailScreen({super.key, required this.contentId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  late TextEditingController _noteController;
  final _tagInputController = TextEditingController();
  bool _noteChanged = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _saveNoteIfChanged();
    _noteController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _saveNoteIfChanged() async {
    if (!_noteChanged) return;
    final dao = await ref.read(contentDaoProvider.future);
    final content = await dao.getById(widget.contentId);
    if (content == null) return;
    final updated = content.copyWith(
      note: _noteController.text,
      updatedAt: DateTime.now(),
    );
    await ref.read(contentListProvider.notifier).updateContent(updated);
  }

  Future<void> _addTag() async {
    final name = _tagInputController.text.trim();
    if (name.isEmpty) return;

    final tagDao = await ref.read(tagDaoProvider.future);
    final tagId = await tagDao.insertOrGet(name);
    await tagDao.addTagToContent(contentId: widget.contentId, tagId: tagId);

    _tagInputController.clear();
    ref.invalidate(contentTagsProvider(widget.contentId));
    ref.invalidate(tagsWithCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentListProvider);
    final tagsAsync = ref.watch(contentTagsProvider(widget.contentId));

    return contentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('錯誤：$err')),
      ),
      data: (contents) {
        final content = contents.where((c) => c.id == widget.contentId).firstOrNull;
        if (content == null) {
          return const Scaffold(body: Center(child: Text('內容不存在')));
        }

        // 初始化筆記控制器
        if (!_noteChanged) {
          _noteController.text = content.note ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              TextButton.icon(
                onPressed: () => launchUrl(Uri.parse(content.url)),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('開啟原文'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 縮圖
                if (content.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      content.thumbnailUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 12),

                // 平台 + 日期
                Text(
                  '${PlatformChip.labelForPlatform(content.platform)} · '
                  '${content.createdAt.toLocal().toString().substring(0, 10)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: PlatformChip.colorForPlatform(content.platform),
                  ),
                ),
                const SizedBox(height: 8),

                // 標題
                Text(
                  content.title ?? content.url,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // 原始描述
                if (content.description != null) ...[
                  Text(
                    content.description!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                ],

                // AI 摘要
                if (content.aiSummary != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI 摘要',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7FD8BE),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.aiSummary!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 筆記
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '我的筆記',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF6C177),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        onChanged: (_) => _noteChanged = true,
                        maxLines: null,
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                        decoration: const InputDecoration(
                          hintText: '輸入筆記...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 標籤
                tagsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (tags) => Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...tags.map((tag) => TagChip(
                        label: tag.name,
                        onDelete: () async {
                          final tagDao = await ref.read(tagDaoProvider.future);
                          await tagDao.removeTagFromContent(
                            contentId: widget.contentId,
                            tagId: tag.id!,
                          );
                          ref.invalidate(contentTagsProvider(widget.contentId));
                          ref.invalidate(tagsWithCountProvider);
                        },
                      )),
                      // 新增標籤按鈕
                      GestureDetector(
                        onTap: () => _showAddTagDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '+ 新標籤',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增標籤'),
        content: TextField(
          controller: _tagInputController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '標籤名稱'),
          onSubmitted: (_) {
            _addTag();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _addTag();
              Navigator.pop(context);
            },
            child: const Text('新增'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 確認編譯無誤**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/detail_screen.dart lib/widgets/tag_chip.dart
git commit -m "feat: 新增內容詳情頁，含 AI 摘要、筆記編輯、標籤管理"
```

---

## Task 15: 分享接收頁 + Share Intent Handler

**Files:**
- Create: `lib/screens/share_receive_screen.dart`
- Modify: `lib/app.dart`（加入 share intent 監聽）

- [ ] **Step 1: 實作 ShareReceiveScreen**

```dart
// lib/screens/share_receive_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/models/content.dart';
import 'package:learning_vault/services/platform_detector.dart';
import 'package:learning_vault/services/metadata_extractor.dart';
import 'package:learning_vault/providers/content_provider.dart';
import 'package:learning_vault/providers/tag_provider.dart';
import 'package:learning_vault/providers/settings_provider.dart';
import 'package:dio/dio.dart';

class ShareReceiveScreen extends ConsumerStatefulWidget {
  final String sharedUrl;

  const ShareReceiveScreen({super.key, required this.sharedUrl});

  @override
  ConsumerState<ShareReceiveScreen> createState() => _ShareReceiveScreenState();
}

class _ShareReceiveScreenState extends ConsumerState<ShareReceiveScreen> {
  final _noteController = TextEditingController();
  final _tagInputController = TextEditingController();
  final _tags = <String>[];

  String _platform = '';
  Metadata? _metadata;
  String? _aiSummary;
  bool _loadingMetadata = true;
  bool _loadingAi = false;
  String? _aiError;

  @override
  void initState() {
    super.initState();
    _process();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    // 1. 辨識平台
    setState(() {
      _platform = PlatformDetector.detect(widget.sharedUrl);
    });

    // 2. 擷取 metadata
    final extractor = MetadataExtractor(Dio());
    final metadata = await extractor.extract(widget.sharedUrl);
    setState(() {
      _metadata = metadata;
      _loadingMetadata = false;
    });

    // 3. AI 摘要
    setState(() => _loadingAi = true);
    try {
      final aiService = await ref.read(aiServiceProvider.future);
      if (aiService != null) {
        final summary = await aiService.summarize(
          title: metadata.title ?? '',
          description: metadata.description ?? '',
          url: widget.sharedUrl,
        );
        setState(() {
          _aiSummary = summary;
          _loadingAi = false;
        });
      } else {
        setState(() {
          _aiError = '未設定 API Key，請到設定頁設定';
          _loadingAi = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiError = 'AI 摘要失敗：$e';
        _loadingAi = false;
      });
    }
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final content = Content(
      url: widget.sharedUrl,
      platform: _platform,
      title: _metadata?.title,
      thumbnailUrl: _metadata?.thumbnailUrl,
      description: _metadata?.description,
      aiSummary: _aiSummary,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: now,
      updatedAt: now,
    );

    final contentId = await ref.read(contentListProvider.notifier).add(content);

    // 儲存標籤
    if (_tags.isNotEmpty) {
      final tagDao = await ref.read(tagDaoProvider.future);
      for (final tagName in _tags) {
        final tagId = await tagDao.insertOrGet(tagName);
        await tagDao.addTagToContent(contentId: contentId, tagId: tagId);
      }
      ref.invalidate(tagsWithCountProvider);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('儲存到學習庫'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 連結
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('連結', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    widget.sharedUrl,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7FD8BE)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 處理進度
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusRow(
                    '平台辨識：${PlatformDetector.detect(widget.sharedUrl) != 'other' ? PlatformDetector.detect(widget.sharedUrl).toUpperCase() : '未知'}',
                    true,
                  ),
                  const SizedBox(height: 6),
                  _statusRow(
                    _loadingMetadata ? 'Metadata 擷取中...' : 'Metadata 擷取完成',
                    !_loadingMetadata,
                  ),
                  const SizedBox(height: 6),
                  _statusRow(
                    _loadingAi
                        ? 'AI 摘要生成中...'
                        : _aiError ?? 'AI 摘要完成',
                    _aiSummary != null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // AI 摘要預覽
            if (_aiSummary != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 摘要',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7FD8BE)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _aiSummary!,
                      style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 快速筆記
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '快速筆記（選填）',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                    decoration: const InputDecoration(
                      hintText: '輸入筆記...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 標籤
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ..._tags.map((tag) => Chip(
                  label: Text('#$tag', style: const TextStyle(fontSize: 12, color: Color(0xFFF6C177))),
                  deleteIconColor: Colors.grey,
                  backgroundColor: const Color(0xFF2A2A4A),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                )),
                ActionChip(
                  label: const Text('+ 新增標籤', style: TextStyle(fontSize: 12)),
                  backgroundColor: const Color(0xFF1A1A2E),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('新增標籤'),
                        content: TextField(
                          controller: _tagInputController,
                          autofocus: true,
                          decoration: const InputDecoration(hintText: '標籤名稱'),
                          onSubmitted: (_) {
                            final name = _tagInputController.text.trim();
                            if (name.isNotEmpty && !_tags.contains(name)) {
                              setState(() => _tags.add(name));
                            }
                            _tagInputController.clear();
                            Navigator.pop(ctx);
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              final name = _tagInputController.text.trim();
                              if (name.isNotEmpty && !_tags.contains(name)) {
                                setState(() => _tags.add(name));
                              }
                              _tagInputController.clear();
                              Navigator.pop(ctx);
                            },
                            child: const Text('新增'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 儲存按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7FD8BE),
                  foregroundColor: const Color(0xFF0F0F1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '儲存',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String text, bool done) {
    return Row(
      children: [
        if (done)
          const Text('✅ ', style: TextStyle(fontSize: 12))
        else
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: done ? Colors.white70 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 在 app.dart 加入 share intent 監聽**

```dart
// lib/app.dart — 完整替換
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:learning_vault/screens/home_screen.dart';
import 'package:learning_vault/screens/tags_screen.dart';
import 'package:learning_vault/screens/search_screen.dart';
import 'package:learning_vault/screens/settings_screen.dart';
import 'package:learning_vault/screens/share_receive_screen.dart';

class LearningVaultApp extends StatelessWidget {
  const LearningVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '學習庫',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7FD8BE),
          secondary: const Color(0xFFF6C177),
          surface: const Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        cardColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          elevation: 0,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    TagsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _setupShareIntent();
  }

  void _setupShareIntent() {
    // App 從分享啟動時
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      final url = _extractUrl(value);
      if (url != null) _openShareReceive(url);
    });

    // App 已在前景，收到分享
    ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
      final url = _extractUrl(value);
      if (url != null) _openShareReceive(url);
    });
  }

  String? _extractUrl(List<SharedMediaFile> files) {
    if (files.isEmpty) return null;
    // 分享的文字可能包含 URL，直接取用
    final text = files.first.path;
    // 嘗試從文字中擷取 URL
    final urlPattern = RegExp(r'https?://\S+');
    final match = urlPattern.firstMatch(text);
    return match?.group(0) ?? text;
  }

  void _openShareReceive(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareReceiveScreen(sharedUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: const Color(0xFF7FD8BE),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.label), label: '標籤'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜尋'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 確認編譯無誤**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/share_receive_screen.dart lib/app.dart
git commit -m "feat: 新增分享接收頁與 Share Intent 監聽"
```

---

## Task 16: 標籤瀏覽頁

**Files:**
- Modify: `lib/screens/tags_screen.dart`

- [ ] **Step 1: 實作 TagsScreen**

```dart
// lib/screens/tags_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/models/content.dart';
import 'package:learning_vault/providers/content_provider.dart';
import 'package:learning_vault/providers/tag_provider.dart';
import 'package:learning_vault/widgets/content_card.dart';
import 'package:learning_vault/screens/detail_screen.dart';

class TagsScreen extends ConsumerStatefulWidget {
  const TagsScreen({super.key});

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  int? _selectedTagId;
  String? _selectedTagName;

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsWithCountProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '標籤',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Tag cloud
            tagsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('錯誤：$err'),
              data: (tagsWithCount) {
                if (tagsWithCount.isEmpty) {
                  return const Text(
                    '還沒有標籤',
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tagsWithCount.map((tc) {
                    final isSelected = _selectedTagId == tc.tag.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTagId = null;
                            _selectedTagName = null;
                          } else {
                            _selectedTagId = tc.tag.id;
                            _selectedTagName = tc.tag.name;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3A3A5A)
                              : const Color(0xFF2A2A4A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#${tc.tag.name}  ${tc.count}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFF6C177),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),

            // 選中標籤的內容列表
            if (_selectedTagId != null) ...[
              Text(
                '#$_selectedTagName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF6C177),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _TagContentList(
                  tagId: _selectedTagId!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Provider 根據 tagId 取得該標籤下的所有 Content
final contentsByTagProvider =
    FutureProvider.family<List<Content>, int>((ref, tagId) async {
  final tagDao = await ref.read(tagDaoProvider.future);
  final contentDao = await ref.read(contentDaoProvider.future);
  final contentIds = await tagDao.getContentIdsForTag(tagId);
  final contents = <Content>[];
  for (final id in contentIds) {
    final content = await contentDao.getById(id);
    if (content != null) contents.add(content);
  }
  return contents;
});

class _TagContentList extends ConsumerWidget {
  final int tagId;

  const _TagContentList({required this.tagId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(contentsByTagProvider(tagId));

    return contentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('錯誤：$err')),
      data: (contents) => ListView.builder(
        itemCount: contents.length,
        itemBuilder: (context, index) {
          final content = contents[index];
          return ContentCard(
            content: content,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DetailScreen(contentId: content.id!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: 確認編譯無誤**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/tags_screen.dart
git commit -m "feat: 新增標籤瀏覽頁，含 tag cloud 與篩選列表"
```

---

## Task 17: 搜尋頁

**Files:**
- Modify: `lib/screens/search_screen.dart`

- [ ] **Step 1: 實作 SearchScreen**

```dart
// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/database/database_helper.dart';
import 'package:learning_vault/database/content_dao.dart';
import 'package:learning_vault/models/content.dart';
import 'package:learning_vault/widgets/content_card.dart';
import 'package:learning_vault/screens/detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<Content>? _results;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }

    setState(() => _loading = true);
    final db = await DatabaseHelper.instance.database;
    final dao = ContentDao(db);
    final results = await dao.search(query.trim());
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '搜尋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 搜尋框
            TextField(
              controller: _controller,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '搜尋標題、摘要、筆記...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 搜尋結果
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results == null
                      ? const Center(
                          child: Text(
                            '輸入關鍵字搜尋\n搜尋範圍：標題、AI 摘要、筆記',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : _results!.isEmpty
                          ? const Center(
                              child: Text(
                                '找不到相關內容',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _results!.length,
                              itemBuilder: (context, index) {
                                final content = _results![index];
                                return ContentCard(
                                  content: content,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => DetailScreen(
                                          contentId: content.id!,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 確認編譯無誤**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/search_screen.dart
git commit -m "feat: 新增搜尋頁，支援全文搜尋標題、摘要、筆記"
```

---

## Task 18: 設定頁

**Files:**
- Modify: `lib/screens/settings_screen.dart`

- [ ] **Step 1: 實作 SettingsScreen**

```dart
// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/services/settings_service.dart';
import 'package:learning_vault/providers/settings_provider.dart';
import 'package:learning_vault/providers/content_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _openaiKeyController = TextEditingController();
  final _claudeKeyController = TextEditingController();
  bool _openaiHasKey = false;
  bool _claudeHasKey = false;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  @override
  void dispose() {
    _openaiKeyController.dispose();
    _claudeKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadKeys() async {
    final settings = ref.read(settingsServiceProvider);
    _openaiHasKey = await settings.hasApiKey(AiProvider.openai);
    _claudeHasKey = await settings.hasApiKey(AiProvider.claude);
    setState(() {});
  }

  Future<void> _saveKey(AiProvider provider, String key) async {
    final settings = ref.read(settingsServiceProvider);
    await settings.setApiKey(provider, key);
    await _loadKeys();
    ref.invalidate(aiServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentProvider = ref.watch(aiProviderProvider);
    final contentAsync = ref.watch(contentListProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '設定',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // AI 服務選擇
            const Text('AI 服務', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AiProvider>(
                  value: currentProvider,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Color(0xFF7FD8BE)),
                  items: const [
                    DropdownMenuItem(
                      value: AiProvider.openai,
                      child: Text('OpenAI (GPT)'),
                    ),
                    DropdownMenuItem(
                      value: AiProvider.claude,
                      child: Text('Claude'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(aiProviderProvider.notifier).setProvider(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // API Keys
            const Text('API Keys', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            _apiKeyTile(
              label: 'OpenAI',
              hasKey: _openaiHasKey,
              onTap: () => _showKeyDialog(AiProvider.openai, 'OpenAI API Key'),
            ),
            const SizedBox(height: 6),
            _apiKeyTile(
              label: 'Claude',
              hasKey: _claudeHasKey,
              onTap: () => _showKeyDialog(AiProvider.claude, 'Claude API Key'),
            ),
            const SizedBox(height: 24),

            // 資料統計
            const Text('資料', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('已儲存內容'),
                  Text(
                    contentAsync.when(
                      data: (list) => '${list.length} 則',
                      loading: () => '...',
                      error: (_, __) => '錯誤',
                    ),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _apiKeyTile({
    required String label,
    required bool hasKey,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              hasKey ? '已設定 ✓' : '未設定',
              style: TextStyle(
                color: hasKey ? const Color(0xFF7FD8BE) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKeyDialog(AiProvider provider, String title) {
    final controller = provider == AiProvider.openai
        ? _openaiKeyController
        : _claudeKeyController;
    controller.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '貼上 API Key',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _saveKey(provider, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 確認編譯無誤**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat: 新增設定頁，含 AI provider 選擇與 API key 管理"
```

---

## Task 19: 端到端驗證

- [ ] **Step 1: 執行所有測試**

```bash
flutter test
```

Expected: All tests passed.

- [ ] **Step 2: 靜態分析**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: 在模擬器上跑一次確認 app 啟動正常**

```bash
flutter run
```

Expected: App 正常啟動，顯示首頁（空白狀態），底部導航正常切換。

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "chore: Learning Vault v1.0 — 完成所有核心功能"
```
