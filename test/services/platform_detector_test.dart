// test/services/platform_detector_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_vault/services/platform_detector.dart';

void main() {
  group('PlatformDetector', () {
    test('辨識 youtube.com', () {
      expect(PlatformDetector.detect('https://www.youtube.com/watch?v=abc'), 'youtube');
    });

    test('辨識 youtu.be 短連結', () {
      expect(PlatformDetector.detect('https://youtu.be/abc123'), 'youtube');
    });

    test('辨識 instagram.com', () {
      expect(PlatformDetector.detect('https://www.instagram.com/p/abc123/'), 'instagram');
    });

    test('辨識 facebook.com', () {
      expect(PlatformDetector.detect('https://www.facebook.com/post/123'), 'facebook');
    });

    test('辨識 fb.watch', () {
      expect(PlatformDetector.detect('https://fb.watch/abc123/'), 'facebook');
    });

    test('辨識 tiktok.com', () {
      expect(PlatformDetector.detect('https://www.tiktok.com/@user/video/123'), 'tiktok');
    });

    test('辨識 douyin.com', () {
      expect(PlatformDetector.detect('https://www.douyin.com/video/123'), 'tiktok');
    });

    test('未知 domain 回傳 other', () {
      expect(PlatformDetector.detect('https://example.com/page'), 'other');
    });

    test('無效 URL 回傳 other', () {
      expect(PlatformDetector.detect('not a url'), 'other');
    });
  });
}
