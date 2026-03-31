import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/database/database_helper.dart';
import 'package:learning_vault/database/tag_dao.dart';
import 'package:learning_vault/models/tag.dart';

final tagDaoProvider = FutureProvider<TagDao>((ref) async {
  final db = await DatabaseHelper.instance.database;
  return TagDao(db);
});

final tagsWithCountProvider =
    StateNotifierProvider<TagsWithCountNotifier, AsyncValue<List<TagWithCount>>>((ref) {
  return TagsWithCountNotifier(ref);
});

class TagsWithCountNotifier
    extends StateNotifier<AsyncValue<List<TagWithCount>>> {
  final Ref _ref;

  TagsWithCountNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final dao = await _ref.read(tagDaoProvider.future);
      final tags = await dao.getTagsWithCount();
      state = AsyncValue.data(tags);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final contentTagsProvider =
    FutureProvider.family<List<Tag>, int>((ref, contentId) async {
  final dao = await ref.read(tagDaoProvider.future);
  return dao.getTagsForContent(contentId);
});
