import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary.dart';
import '../services/progress_service.dart';
import 'flashcard_screen.dart';

class ChaptersScreen extends StatelessWidget {
  final VocabularyBook book;
  final Color bookColor;

  const ChaptersScreen({
    super.key,
    required this.book,
    required this.bookColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: bookColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bookColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bookColor.withAlpha(60)),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: bookColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Select a chapter to begin',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: bookColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bookColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${book.chapters.length} chapters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: bookColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: book.chapters.length,
              itemBuilder: (context, index) {
                final chapter = book.chapters[index];
                final isCompleted = progress.isChapterCompleted(
                  chapter.id,
                  chapter.words.length,
                );
                final studiedCount =
                    progress.studiedWordIdsForChapter(chapter.id).length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withAlpha(30)
                              : bookColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.green, size: 24)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: bookColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                      title: Text(
                        chapter.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          studiedCount > 0
                              ? '$studiedCount / ${chapter.words.length} words studied'
                              : '${chapter.words.length} words',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        Icons.play_circle_fill,
                        color: bookColor,
                        size: 32,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FlashcardScreen(
                              chapter: chapter,
                              bookColor: bookColor,
                              bookId: book.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
