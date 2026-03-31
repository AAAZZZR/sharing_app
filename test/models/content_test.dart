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
