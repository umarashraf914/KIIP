class StudyRecord {
  final String wordId;
  final String chapterId;
  final String bookId;
  final DateTime timestamp;

  const StudyRecord({
    required this.wordId,
    required this.chapterId,
    required this.bookId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'wordId': wordId,
    'chapterId': chapterId,
    'bookId': bookId,
    'timestamp': timestamp.toIso8601String(),
  };

  factory StudyRecord.fromJson(Map<String, dynamic> json) => StudyRecord(
    wordId: json['wordId'] as String,
    chapterId: json['chapterId'] as String,
    bookId: json['bookId'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
