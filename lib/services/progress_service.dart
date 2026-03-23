import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/study_record.dart';

class ProgressService extends ChangeNotifier {
  static const _boxName = 'progress';
  static const _streakKey = 'streak_data';
  late Box _box;

  List<StudyRecord> _records = [];
  int _currentStreak = 0;
  DateTime? _lastStudyDate;

  int get currentStreak => _currentStreak;
  DateTime? get lastStudyDate => _lastStudyDate;
  List<StudyRecord> get records => List.unmodifiable(_records);

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _loadRecords();
    _loadStreak();
  }

  void _loadRecords() {
    final raw = _box.get('records') as List?;
    if (raw != null) {
      _records = raw
          .cast<String>()
          .map((e) => StudyRecord.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    }
  }

  void _loadStreak() {
    final streakData = _box.get(_streakKey) as Map?;
    if (streakData != null) {
      _currentStreak = streakData['streak'] as int? ?? 0;
      final lastDate = streakData['lastDate'] as String?;
      if (lastDate != null) {
        _lastStudyDate = DateTime.parse(lastDate);
      }
    }
  }

  Future<void> recordStudy({
    required String wordId,
    required String chapterId,
    required String bookId,
  }) async {
    final record = StudyRecord(
      wordId: wordId,
      chapterId: chapterId,
      bookId: bookId,
      timestamp: DateTime.now(),
    );
    _records.add(record);
    await _saveRecords();
    await _updateStreak();
    notifyListeners();
  }

  Future<void> _updateStreak() async {
    final today = _dateOnly(DateTime.now());
    if (_lastStudyDate == null) {
      _currentStreak = 1;
    } else {
      final lastDate = _dateOnly(_lastStudyDate!);
      final diff = today.difference(lastDate).inDays;
      if (diff == 0) {
        // Same day, no change
        return;
      } else if (diff == 1) {
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }
    }
    _lastStudyDate = today;
    await _box.put(_streakKey, {
      'streak': _currentStreak,
      'lastDate': _lastStudyDate!.toIso8601String(),
    });
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  int get wordsStudiedToday {
    final today = _dateOnly(DateTime.now());
    return _records
        .where((r) => _dateOnly(r.timestamp) == today)
        .map((r) => r.wordId)
        .toSet()
        .length;
  }

  int get totalWordsStudied {
    return _records.map((r) => r.wordId).toSet().length;
  }

  Set<String> studiedWordIdsForChapter(String chapterId) {
    return _records
        .where((r) => r.chapterId == chapterId)
        .map((r) => r.wordId)
        .toSet();
  }

  bool isChapterCompleted(String chapterId, int totalWords) {
    return studiedWordIdsForChapter(chapterId).length >= totalWords;
  }

  int completedChaptersForBook(String bookId, List<ChapterInfo> chapters) {
    return chapters
        .where((ch) => isChapterCompleted(ch.id, ch.wordCount))
        .length;
  }

  Map<int, int> wordsStudiedPerDayThisWeek() {
    final today = _dateOnly(DateTime.now());
    final result = <int, int>{};
    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final count = _records
          .where((r) => _dateOnly(r.timestamp) == day)
          .map((r) => r.wordId)
          .toSet()
          .length;
      result[day.weekday] = count;
    }
    return result;
  }

  Future<void> _saveRecords() async {
    final encoded = _records.map((r) => jsonEncode(r.toJson())).toList();
    await _box.put('records', encoded);
  }
}

class ChapterInfo {
  final String id;
  final int wordCount;
  const ChapterInfo({required this.id, required this.wordCount});
}
