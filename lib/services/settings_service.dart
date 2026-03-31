// lib/services/settings_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AiProvider { openai, claude }

class SettingsService {
  final FlutterSecureStorage _storage;

  SettingsService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<AiProvider> getAiProvider() async {
    final value = await _storage.read(key: 'ai_provider');
    if (value == 'claude') return AiProvider.claude;
    return AiProvider.openai;
  }

  Future<void> setAiProvider(AiProvider provider) async {
    await _storage.write(key: 'ai_provider', value: provider.name);
  }

  Future<String?> getApiKey(AiProvider provider) async {
    return _storage.read(key: '${provider.name}_api_key');
  }

  Future<void> setApiKey(AiProvider provider, String key) async {
    await _storage.write(key: '${provider.name}_api_key', value: key);
  }

  Future<bool> hasApiKey(AiProvider provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }
}
