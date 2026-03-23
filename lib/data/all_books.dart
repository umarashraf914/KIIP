import '../models/vocabulary.dart';
import 'book1.dart';
import 'book2.dart';
import 'book3.dart';
import 'book4.dart';

final List<VocabularyBook> allBooks = _assignIds([book1, book2, book3, book4]);

List<VocabularyBook> _assignIds(List<VocabularyBook> books) {
  return List.generate(books.length, (bi) {
    final book = books[bi];
    final bookId = 'book$bi';
    final chapters = List.generate(book.chapters.length, (ci) {
      final chapter = book.chapters[ci];
      final chapterId = '${bookId}_ch$ci';
      final words = List.generate(chapter.words.length, (wi) {
        return chapter.words[wi].withId('${chapterId}_w$wi');
      });
      return chapter.withIdAndWords(chapterId, words);
    });
    return book.withIdAndChapters(bookId, chapters);
  });
}
