class VocabularyWord {
  final String id;
  final String korean;
  final String english;

  const VocabularyWord({this.id = '', required this.korean, required this.english});

  VocabularyWord withId(String id) =>
      VocabularyWord(id: id, korean: korean, english: english);
}

class VocabularyChapter {
  final String id;
  final String title;
  final List<VocabularyWord> words;

  const VocabularyChapter({this.id = '', required this.title, required this.words});

  VocabularyChapter withIdAndWords(String id, List<VocabularyWord> words) =>
      VocabularyChapter(id: id, title: title, words: words);
}

class VocabularyBook {
  final String id;
  final String title;
  final String subtitle;
  final List<VocabularyChapter> chapters;

  const VocabularyBook({
    this.id = '',
    required this.title,
    required this.subtitle,
    required this.chapters,
  });

  VocabularyBook withIdAndChapters(String id, List<VocabularyChapter> chapters) =>
      VocabularyBook(id: id, title: title, subtitle: subtitle, chapters: chapters);
}
