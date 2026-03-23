import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookmarkService extends ChangeNotifier {
  static const _boxName = 'bookmarks';
  late Box _box;

  final Set<String> _bookmarkedWordIds = {};

  Set<String> get bookmarkedWordIds => Set.unmodifiable(_bookmarkedWordIds);

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final saved = _box.get('word_ids') as List?;
    if (saved != null) {
      _bookmarkedWordIds.addAll(saved.cast<String>());
    }
  }

  bool isBookmarked(String wordId) => _bookmarkedWordIds.contains(wordId);

  Future<void> toggle(String wordId) async {
    if (_bookmarkedWordIds.contains(wordId)) {
      _bookmarkedWordIds.remove(wordId);
    } else {
      _bookmarkedWordIds.add(wordId);
    }
    await _save();
    notifyListeners();
  }

  Future<void> add(String wordId) async {
    if (_bookmarkedWordIds.add(wordId)) {
      await _save();
      notifyListeners();
    }
  }

  Future<void> remove(String wordId) async {
    if (_bookmarkedWordIds.remove(wordId)) {
      await _save();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    await _box.put('word_ids', _bookmarkedWordIds.toList());
  }
}
