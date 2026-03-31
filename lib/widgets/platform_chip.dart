import 'package:flutter/material.dart';

class PlatformChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PlatformChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static Color colorForPlatform(String platform) {
    switch (platform) {
      case 'youtube':
        return const Color(0xFFC4A7E7);
      case 'instagram':
        return const Color(0xFFEB6F92);
      case 'facebook':
        return const Color(0xFF89B4FA);
      case 'tiktok':
        return const Color(0xFF9CCFD8);
      default:
        return Colors.grey;
    }
  }

  static String labelForPlatform(String platform) {
    switch (platform) {
      case 'youtube':
        return 'YouTube';
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'tiktok':
        return 'TikTok';
      default:
        return platform;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A2A4A) : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? const Color(0xFF7FD8BE) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
