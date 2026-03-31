// lib/services/openai_service.dart
import 'package:dio/dio.dart';
import 'package:learning_vault/services/ai_service.dart';

class OpenAiService implements AiService {
  final String apiKey;
  final Dio _dio;

  OpenAiService({required this.apiKey, Dio? dio}) : _dio = dio ?? Dio();

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
