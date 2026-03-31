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
