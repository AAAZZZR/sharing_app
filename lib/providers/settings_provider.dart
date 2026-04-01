import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/services/settings_service.dart';
import 'package:learning_vault/services/ai_service.dart';
import 'package:learning_vault/services/openai_service.dart';
import 'package:learning_vault/services/claude_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final aiProviderProvider =
    StateNotifierProvider<AiProviderNotifier, AiProvider>((ref) {
  return AiProviderNotifier(ref.read(settingsServiceProvider));
});

class AiProviderNotifier extends StateNotifier<AiProvider> {
  final SettingsService _settings;

  AiProviderNotifier(this._settings) : super(AiProvider.openai) {
    _load();
  }

  Future<void> _load() async {
    state = await _settings.getAiProvider();
  }

  Future<void> setProvider(AiProvider provider) async {
    await _settings.setAiProvider(provider);
    state = provider;
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.read(settingsServiceProvider));
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final SettingsService _settings;

  LocaleNotifier(this._settings) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _settings.getLocale();
    if (saved != null) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    await _settings.setLocale(locale.languageCode);
    state = locale;
  }
}

final aiServiceProvider = FutureProvider<AiService?>((ref) async {
  final provider = ref.watch(aiProviderProvider);
  final settings = ref.read(settingsServiceProvider);
  final apiKey = await settings.getApiKey(provider);

  if (apiKey == null || apiKey.isEmpty) return null;

  switch (provider) {
    case AiProvider.openai:
      return OpenAiService(apiKey: apiKey);
    case AiProvider.claude:
      return ClaudeService(apiKey: apiKey);
  }
});
