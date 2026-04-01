import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/l10n/app_localizations.dart';
import 'package:learning_vault/providers/content_provider.dart';
import 'package:learning_vault/providers/tag_provider.dart';
import 'package:learning_vault/widgets/content_card.dart';
import 'package:learning_vault/widgets/platform_chip.dart';
import 'package:learning_vault/screens/detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedPlatform = 'all';

  final _platforms = ['all', 'youtube', 'instagram', 'facebook', 'tiktok'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contentAsync = ref.watch(contentListProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _platforms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final platform = _platforms[index];
                  return PlatformChip(
                    label: platform == 'all' ? l10n.filterAll : PlatformChip.labelForPlatform(platform),
                    selected: _selectedPlatform == platform,
                    onTap: () {
                      setState(() => _selectedPlatform = platform);
                      if (platform == 'all') {
                        ref.read(contentListProvider.notifier).loadAll();
                      } else {
                        ref.read(contentListProvider.notifier).loadByPlatform(platform);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: contentAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text(l10n.errorMessage(err.toString()))),
                data: (contents) {
                  if (contents.isEmpty) {
                    return Center(
                      child: Text(l10n.homeEmpty, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final content = contents[index];
                      final tagsAsync = ref.watch(contentTagsProvider(content.id!));
                      final tagNames = tagsAsync.when(
                        data: (tags) => tags.map((t) => t.name).toList(),
                        loading: () => <String>[],
                        error: (_, __) => <String>[],
                      );
                      return ContentCard(
                        content: content,
                        tags: tagNames,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => DetailScreen(contentId: content.id!)),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
