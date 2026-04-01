import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/l10n/app_localizations.dart';
import 'package:learning_vault/models/content.dart';
import 'package:learning_vault/services/platform_detector.dart';
import 'package:learning_vault/services/metadata_extractor.dart';
import 'package:learning_vault/providers/content_provider.dart';
import 'package:learning_vault/providers/tag_provider.dart';
import 'package:learning_vault/providers/settings_provider.dart';
import 'package:dio/dio.dart';

class ShareReceiveScreen extends ConsumerStatefulWidget {
  final String sharedUrl;

  const ShareReceiveScreen({super.key, required this.sharedUrl});

  @override
  ConsumerState<ShareReceiveScreen> createState() => _ShareReceiveScreenState();
}

class _ShareReceiveScreenState extends ConsumerState<ShareReceiveScreen> {
  final _noteController = TextEditingController();
  final _tagInputController = TextEditingController();
  final _tags = <String>[];

  String _platform = '';
  Metadata? _metadata;
  String? _aiSummary;
  bool _loadingMetadata = true;
  bool _loadingAi = false;
  // null = no error, empty string = no API key, non-empty = actual error message
  String? _aiRawError;
  bool _noApiKey = false;

  @override
  void initState() {
    super.initState();
    _process();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    // 1. 平台辨識
    setState(() {
      _platform = PlatformDetector.detect(widget.sharedUrl);
    });

    // 2. Metadata 擷取
    final extractor = MetadataExtractor(Dio());
    final metadata = await extractor.extract(widget.sharedUrl);
    setState(() {
      _metadata = metadata;
      _loadingMetadata = false;
    });

    // 3. AI 摘要
    setState(() => _loadingAi = true);
    try {
      final aiService = await ref.read(aiServiceProvider.future);
      if (aiService != null) {
        final summary = await aiService.summarize(
          title: metadata.title ?? '',
          description: metadata.description ?? '',
          url: widget.sharedUrl,
        );
        setState(() {
          _aiSummary = summary;
          _loadingAi = false;
        });
      } else {
        setState(() {
          _noApiKey = true;
          _loadingAi = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiRawError = e.toString();
        _loadingAi = false;
      });
    }
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final content = Content(
      url: widget.sharedUrl,
      platform: _platform,
      title: _metadata?.title,
      thumbnailUrl: _metadata?.thumbnailUrl,
      description: _metadata?.description,
      aiSummary: _aiSummary,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: now,
      updatedAt: now,
    );

    final contentId =
        await ref.read(contentListProvider.notifier).add(content);

    if (_tags.isNotEmpty) {
      final tagDao = await ref.read(tagDaoProvider.future);
      for (final tagName in _tags) {
        final tagId = await tagDao.insertOrGet(tagName);
        await tagDao.addTagToContent(contentId: contentId, tagId: tagId);
      }
      ref.invalidate(tagsWithCountProvider);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Resolve AI status text from state
    final String aiStatusText;
    if (_loadingAi) {
      aiStatusText = l10n.aiSummaryLoading;
    } else if (_noApiKey) {
      aiStatusText = l10n.noApiKey;
    } else if (_aiRawError != null) {
      aiStatusText = l10n.aiSummaryError(_aiRawError!);
    } else {
      aiStatusText = l10n.aiSummaryDone;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.saveToVault)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // URL 顯示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.link,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.sharedUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7FD8BE),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 處理進度
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusRow(
                    _platform.isNotEmpty
                        ? l10n.platformDetected(_platform.toUpperCase())
                        : l10n.detecting,
                    _platform.isNotEmpty,
                  ),
                  const SizedBox(height: 6),
                  _statusRow(
                    _loadingMetadata ? l10n.metadataLoading : l10n.metadataDone,
                    !_loadingMetadata,
                  ),
                  const SizedBox(height: 6),
                  _statusRow(
                    aiStatusText,
                    _aiSummary != null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // AI 摘要預覽
            if (_aiSummary != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiSummary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7FD8BE),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _aiSummary!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 快速筆記
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickNote,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.noteHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 標籤
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ..._tags.map(
                  (tag) => Chip(
                    label: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF6C177),
                      ),
                    ),
                    deleteIconColor: Colors.grey,
                    backgroundColor: const Color(0xFF2A2A4A),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                  ),
                ),
                ActionChip(
                  label: Text(
                    l10n.addNewTag,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF1A1A2E),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.addTagTitle),
                        content: TextField(
                          controller: _tagInputController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: l10n.tagNameHint,
                          ),
                          onSubmitted: (_) {
                            final name = _tagInputController.text.trim();
                            if (name.isNotEmpty && !_tags.contains(name)) {
                              setState(() => _tags.add(name));
                            }
                            _tagInputController.clear();
                            Navigator.pop(ctx);
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              final name = _tagInputController.text.trim();
                              if (name.isNotEmpty && !_tags.contains(name)) {
                                setState(() => _tags.add(name));
                              }
                              _tagInputController.clear();
                              Navigator.pop(ctx);
                            },
                            child: Text(l10n.add),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 儲存按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7FD8BE),
                  foregroundColor: const Color(0xFF0F0F1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String text, bool done) {
    return Row(
      children: [
        if (done)
          const Text('✅ ', style: TextStyle(fontSize: 12))
        else
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: done ? Colors.white70 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
