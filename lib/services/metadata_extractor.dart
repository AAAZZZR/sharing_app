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
