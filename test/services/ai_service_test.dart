// test/services/ai_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_vault/services/ai_service.dart';
import 'package:learning_vault/services/openai_service.dart';
import 'package:learning_vault/services/claude_service.dart';

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
