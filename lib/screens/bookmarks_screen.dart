import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/all_books.dart';
import '../models/vocabulary.dart';
import '../services/bookmark_service.dart';
import '../services/tts_service.dart';
import '../services/settings_service.dart';
import '../theme/book_colors.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late TtsService _tts;

  @override
  void initState() {
    super.initState();
    _tts = TtsService(context.read<SettingsService>());
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarkService>();
    final colorScheme = Theme.of(context).colorScheme;

    // Find all bookmarked words with their context
    final items = <_BookmarkedItem>[];
    for (var bi = 0; bi < allBooks.length; bi++) {
      final book = allBooks[bi];
      for (final chapter in book.chapters) {
        for (final word in chapter.words) {
          if (bookmarks.isBookmarked(word.id)) {
            items.add(_BookmarkedItem(
              word: word,
              bookTitle: book.title,
              chapterTitle: chapter.title,
              bookIndex: bi,
            ));
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: colorScheme.onSurface.withAlpha(60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark words while studying to review them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withAlpha(100),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final color = bookColors[item.bookIndex % bookColors.length];
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    title: Text(
                      item.word.korean,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.word.english),
                        const SizedBox(height: 2),
                        Text(
                          '${item.bookTitle} · ${item.chapterTitle}',
                          style: TextStyle(fontSize: 11, color: color),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 22),
                          color: color,
                          onPressed: () => _tts.speak(item.word.korean),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark, size: 22),
                          color: color,
                          onPressed: () => bookmarks.toggle(item.word.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _BookmarkedItem {
  final VocabularyWord word;
  final String bookTitle;
  final String chapterTitle;
  final int bookIndex;

  const _BookmarkedItem({
    required this.word,
    required this.bookTitle,
    required this.chapterTitle,
    required this.bookIndex,
  });
}
