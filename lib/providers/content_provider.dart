import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/database/database_helper.dart';
import 'package:learning_vault/database/content_dao.dart';
import 'package:learning_vault/models/content.dart';

final contentDaoProvider = FutureProvider<ContentDao>((ref) async {
  final db = await DatabaseHelper.instance.database;
  return ContentDao(db);
});

final contentListProvider =
    StateNotifierProvider<ContentListNotifier, AsyncValue<List<Content>>>((ref) {
  return ContentListNotifier(ref);
});

class ContentListNotifier extends StateNotifier<AsyncValue<List<Content>>> {
  final Ref _ref;

  ContentListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final dao = await _ref.read(contentDaoProvider.future);
      final contents = await dao.getAll();
      state = AsyncValue.data(contents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadByPlatform(String platform) async {
    state = const AsyncValue.loading();
    try {
      final dao = await _ref.read(contentDaoProvider.future);
      final contents = await dao.getByPlatform(platform);
      state = AsyncValue.data(contents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> add(Content content) async {
    final dao = await _ref.read(contentDaoProvider.future);
    final id = await dao.insert(content);
    await loadAll();
    return id;
  }

  Future<void> updateContent(Content content) async {
    final dao = await _ref.read(contentDaoProvider.future);
    await dao.update(content);
    await loadAll();
  }

  Future<void> remove(int id) async {
    final dao = await _ref.read(contentDaoProvider.future);
    await dao.delete(id);
    await loadAll();
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    try {
      final dao = await _ref.read(contentDaoProvider.future);
      final contents = await dao.search(query);
      state = AsyncValue.data(contents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
