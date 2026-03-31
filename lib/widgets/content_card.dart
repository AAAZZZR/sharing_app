import 'package:flutter/material.dart';
import 'package:learning_vault/models/content.dart';
import 'package:learning_vault/widgets/platform_chip.dart';

class ContentCard extends StatelessWidget {
  final Content content;
  final List<String> tags;
  final VoidCallback onTap;

  const ContentCard({
    super.key,
    required this.content,
    this.tags = const [],
    required this.onTap,
  });

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays} 天前';
    if (diff.inHours > 0) return '${diff.inHours} 小時前';
    if (diff.inMinutes > 0) return '${diff.inMinutes} 分鐘前';
    return '剛剛';
  }

  @override
  Widget build(BuildContext context) {
    final platformColor = PlatformChip.colorForPlatform(content.platform);
    final platformLabel = PlatformChip.labelForPlatform(content.platform);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: content.thumbnailUrl != null
                      ? Image.network(
                          content.thumbnailUrl!,
                          width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderThumb(),
                        )
                      : _placeholderThumb(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$platformLabel · ${_timeAgo(content.createdAt)}',
                        style: TextStyle(fontSize: 11, color: platformColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        content.title ?? content.url,
                        style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      if (content.aiSummary != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          content.aiSummary!,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A4A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('#$tag', style: const TextStyle(fontSize: 10, color: Color(0xFFF6C177))),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(color: const Color(0xFF2A2A4A), borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.link, color: Colors.grey),
    );
  }
}
