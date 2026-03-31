// lib/services/claude_service.dart
import 'package:dio/dio.dart';
import 'package:learning_vault/services/ai_service.dart';

class ClaudeService implements AiService {
  final String apiKey;
  final Dio _dio;

  ClaudeService({required this.apiKey, Dio? dio}) : _dio = dio ?? Dio();

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
