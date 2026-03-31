import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/services/settings_service.dart';
import 'package:learning_vault/providers/settings_provider.dart';
import 'package:learning_vault/providers/content_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _openaiKeyController = TextEditingController();
  final _claudeKeyController = TextEditingController();
  bool _openaiHasKey = false;
  bool _claudeHasKey = false;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  @override
  void dispose() {
    _openaiKeyController.dispose();
    _claudeKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadKeys() async {
    final settings = ref.read(settingsServiceProvider);
    _openaiHasKey = await settings.hasApiKey(AiProvider.openai);
    _claudeHasKey = await settings.hasApiKey(AiProvider.claude);
    setState(() {});
  }

  Future<void> _saveKey(AiProvider provider, String key) async {
    final settings = ref.read(settingsServiceProvider);
    await settings.setApiKey(provider, key);
    await _loadKeys();
    ref.invalidate(aiServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentProvider = ref.watch(aiProviderProvider);
    final contentAsync = ref.watch(contentListProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('設定', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),

            // AI provider selection
            const Text('AI 服務', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AiProvider>(
                  value: currentProvider,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Color(0xFF7FD8BE)),
                  items: const [
                    DropdownMenuItem(value: AiProvider.openai, child: Text('OpenAI (GPT)')),
                    DropdownMenuItem(value: AiProvider.claude, child: Text('Claude')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(aiProviderProvider.notifier).setProvider(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // API Keys
            const Text('API Keys', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            _apiKeyTile(label: 'OpenAI', hasKey: _openaiHasKey, onTap: () => _showKeyDialog(AiProvider.openai, 'OpenAI API Key')),
            const SizedBox(height: 6),
            _apiKeyTile(label: 'Claude', hasKey: _claudeHasKey, onTap: () => _showKeyDialog(AiProvider.claude, 'Claude API Key')),
            const SizedBox(height: 24),

            // Stats
            const Text('資料', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('已儲存內容'),
                  Text(
                    contentAsync.when(data: (list) => '${list.length} 則', loading: () => '...', error: (_, __) => '錯誤'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _apiKeyTile({required String label, required bool hasKey, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(hasKey ? '已設定 ✓' : '未設定', style: TextStyle(color: hasKey ? const Color(0xFF7FD8BE) : Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showKeyDialog(AiProvider provider, String title) {
    final controller = provider == AiProvider.openai ? _openaiKeyController : _claudeKeyController;
    controller.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: '貼上 API Key'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              _saveKey(provider, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }
}
