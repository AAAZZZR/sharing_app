import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/database/database_helper.dart';
import 'package:learning_vault/database/content_dao.dart';
import 'package:learning_vault/l10n/app_localizations.dart';
import 'package:learning_vault/models/content.dart';
import 'package:learning_vault/widgets/content_card.dart';
import 'package:learning_vault/screens/detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<Content>? _results;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }

    setState(() => _loading = true);
    final db = await DatabaseHelper.instance.database;
    final dao = ContentDao(db);
    final results = await dao.search(query.trim());
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.searchTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results == null
                      ? Center(child: Text(l10n.searchEmpty, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)))
                      : _results!.isEmpty
                          ? Center(child: Text(l10n.searchNoResults, style: const TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _results!.length,
                              itemBuilder: (context, index) {
                                final content = _results![index];
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
            ),
          ],
        ),
      ),
    );
  }
}
