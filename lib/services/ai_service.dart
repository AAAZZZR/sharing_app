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
