import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/l10n/app_localizations.dart';
import 'package:learning_vault/models/content.dart';
import 'package:learning_vault/providers/content_provider.dart';
import 'package:learning_vault/providers/tag_provider.dart';
import 'package:learning_vault/widgets/content_card.dart';
import 'package:learning_vault/screens/detail_screen.dart';

/// Provider: get all Content items for a given tag ID
final contentsByTagProvider =
    FutureProvider.family<List<Content>, int>((ref, tagId) async {
  final tagDao = await ref.read(tagDaoProvider.future);
  final contentDao = await ref.read(contentDaoProvider.future);
  final contentIds = await tagDao.getContentIdsForTag(tagId);
  final contents = <Content>[];
  for (final id in contentIds) {
    final content = await contentDao.getById(id);
    if (content != null) contents.add(content);
  }
  return contents;
});

class TagsScreen extends ConsumerStatefulWidget {
  const TagsScreen({super.key});

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  int? _selectedTagId;
  String? _selectedTagName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tagsAsync = ref.watch(tagsWithCountProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tagsTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),

            // Tag cloud
            tagsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text(l10n.errorMessage(err.toString())),
              data: (tagsWithCount) {
                if (tagsWithCount.isEmpty) {
                  return Text(l10n.noTags, style: const TextStyle(color: Colors.grey));
                }
                return Wrap(
                  spacing: 8, runSpacing: 8,
                  children: tagsWithCount.map((tc) {
                    final isSelected = _selectedTagId == tc.tag.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTagId = null;
                            _selectedTagName = null;
                          } else {
                            _selectedTagId = tc.tag.id;
                            _selectedTagName = tc.tag.name;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3A3A5A) : const Color(0xFF2A2A4A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#${tc.tag.name}  ${tc.count}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFFF6C177)),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),

            // Content list for selected tag
            if (_selectedTagId != null) ...[
              Text('#$_selectedTagName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFF6C177))),
              const SizedBox(height: 8),
              Expanded(child: _TagContentList(tagId: _selectedTagId!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _TagContentList extends ConsumerWidget {
  final int tagId;

  const _TagContentList({required this.tagId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contentsAsync = ref.watch(contentsByTagProvider(tagId));

    return contentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(l10n.errorMessage(err.toString()))),
      data: (contents) => ListView.builder(
        itemCount: contents.length,
        itemBuilder: (context, index) {
          final content = contents[index];
          return ContentCard(
            content: content,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DetailScreen(contentId: content.id!)),
              );
            },
          );
        },
      ),
    );
  }
}
