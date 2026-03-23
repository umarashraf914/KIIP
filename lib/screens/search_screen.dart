import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/all_books.dart';
import '../models/vocabulary.dart';
import '../services/bookmark_service.dart';
import '../services/tts_service.dart';
import '../services/settings_service.dart';
import '../theme/book_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<_SearchResult> _results = [];
  late TtsService _tts;

  @override
  void initState() {
    super.initState();
    _tts = TtsService(context.read<SettingsService>());
  }

  @override
  void dispose() {
    _controller.dispose();
    _tts.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final q = query.toLowerCase();
    final results = <_SearchResult>[];
    for (var bi = 0; bi < allBooks.length; bi++) {
      final book = allBooks[bi];
      for (final chapter in book.chapters) {
        for (final word in chapter.words) {
          if (word.korean.toLowerCase().contains(q) ||
              word.english.toLowerCase().contains(q)) {
            results.add(_SearchResult(
              word: word,
              bookTitle: book.title,
              chapterTitle: chapter.title,
              bookIndex: bi,
            ));
          }
        }
      }
    }
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _controller,
              hintText: 'Search Korean or English...',
              leading: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.search),
              ),
              trailing: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _search('');
                    },
                  ),
              ],
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _controller.text.isEmpty
                              ? Icons.search
                              : Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurface.withAlpha(60),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _controller.text.isEmpty
                              ? 'Search across all vocabulary'
                              : 'No results found',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final r = _results[index];
                      final color = bookColors[r.bookIndex % bookColors.length];
                      final bookmarks = context.watch<BookmarkService>();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          title: Text(
                            r.word.korean,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.word.english),
                              const SizedBox(height: 2),
                              Text(
                                '${r.bookTitle} · ${r.chapterTitle}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up, size: 22),
                                color: color,
                                onPressed: () => _tts.speak(r.word.korean),
                              ),
                              IconButton(
                                icon: Icon(
                                  bookmarks.isBookmarked(r.word.id)
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  size: 22,
                                ),
                                color: color,
                                onPressed: () => bookmarks.toggle(r.word.id),
                              ),
                            ],
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

class _SearchResult {
  final VocabularyWord word;
  final String bookTitle;
  final String chapterTitle;
  final int bookIndex;

  const _SearchResult({
    required this.word,
    required this.bookTitle,
    required this.chapterTitle,
    required this.bookIndex,
  });
}
