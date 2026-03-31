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
