class VocabularyWord {
  final String korean;
  final String english;

  const VocabularyWord({required this.korean, required this.english});
}

class VocabularyChapter {
  final String title;
  final List<VocabularyWord> words;

  const VocabularyChapter({required this.title, required this.words});
}

class VocabularyBook {
  final String title;
  final String subtitle;
  final List<VocabularyChapter> chapters;

  const VocabularyBook({
    required this.title,
    required this.subtitle,
    required this.chapters,
  });
}
