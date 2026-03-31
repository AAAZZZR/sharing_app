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
