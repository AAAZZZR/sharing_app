import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_vault/providers/content_provider.dart';
import 'package:learning_vault/providers/tag_provider.dart';
import 'package:learning_vault/widgets/platform_chip.dart';
import 'package:learning_vault/widgets/tag_chip.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final int contentId;

  const DetailScreen({super.key, required this.contentId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  late TextEditingController _noteController;
  final _tagInputController = TextEditingController();
  bool _noteChanged = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _saveNoteIfChanged();
    _noteController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _saveNoteIfChanged() async {
    if (!_noteChanged) return;
    final dao = await ref.read(contentDaoProvider.future);
    final content = await dao.getById(widget.contentId);
    if (content == null) return;
    final updated = content.copyWith(
      note: _noteController.text,
      updatedAt: DateTime.now(),
    );
    await ref.read(contentListProvider.notifier).updateContent(updated);
  }

  Future<void> _addTag() async {
    final name = _tagInputController.text.trim();
    if (name.isEmpty) return;

    final tagDao = await ref.read(tagDaoProvider.future);
    final tagId = await tagDao.insertOrGet(name);
    await tagDao.addTagToContent(contentId: widget.contentId, tagId: tagId);

    _tagInputController.clear();
    ref.invalidate(contentTagsProvider(widget.contentId));
    ref.invalidate(tagsWithCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentListProvider);
    final tagsAsync = ref.watch(contentTagsProvider(widget.contentId));

    return contentAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('錯誤：$err'))),
      data: (contents) {
        final content = contents.where((c) => c.id == widget.contentId).firstOrNull;
        if (content == null) {
          return const Scaffold(body: Center(child: Text('內容不存在')));
        }

        if (!_noteChanged) {
          _noteController.text = content.note ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              TextButton.icon(
                onPressed: () => launchUrl(Uri.parse(content.url)),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('開啟原文'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                if (content.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      content.thumbnailUrl!,
                      width: double.infinity, height: 180, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 12),

                // Platform + date
                Text(
                  '${PlatformChip.labelForPlatform(content.platform)} · ${content.createdAt.toLocal().toString().substring(0, 10)}',
                  style: TextStyle(fontSize: 12, color: PlatformChip.colorForPlatform(content.platform)),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  content.title ?? content.url,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),

                // Description
                if (content.description != null) ...[
                  Text(content.description!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),
                ],

                // AI Summary
                if (content.aiSummary != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI 摘要', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF7FD8BE))),
                        const SizedBox(height: 8),
                        Text(content.aiSummary!, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Note
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('我的筆記', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFF6C177))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        onChanged: (_) => _noteChanged = true,
                        maxLines: null,
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                        decoration: const InputDecoration(
                          hintText: '輸入筆記...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tags
                tagsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (tags) => Wrap(
                    spacing: 6, runSpacing: 6,
                    children: [
                      ...tags.map((tag) => TagChip(
                        label: tag.name,
                        onDelete: () async {
                          final tagDao = await ref.read(tagDaoProvider.future);
                          await tagDao.removeTagFromContent(contentId: widget.contentId, tagId: tag.id!);
                          ref.invalidate(contentTagsProvider(widget.contentId));
                          ref.invalidate(tagsWithCountProvider);
                        },
                      )),
                      GestureDetector(
                        onTap: () => _showAddTagDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('+ 新標籤', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增標籤'),
        content: TextField(
          controller: _tagInputController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '標籤名稱'),
          onSubmitted: (_) {
            _addTag();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              _addTag();
              Navigator.pop(context);
            },
            child: const Text('新增'),
          ),
        ],
      ),
    );
  }
}
