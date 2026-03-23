import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/all_books.dart';
import '../services/progress_service.dart';
import '../theme/book_colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stat cards row
          Row(
            children: [
              _StatCard(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                label: 'Streak',
                value: '${progress.currentStreak}',
                unit: 'days',
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.auto_stories,
                iconColor: colorScheme.primary,
                label: 'Today',
                value: '${progress.wordsStudiedToday}',
                unit: 'words',
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                label: 'Total',
                value: '${progress.totalWordsStudied}',
                unit: 'words',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly chart
          Text(
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _WeeklyChart(progress: progress),
          const SizedBox(height: 24),

          // Per-book progress
          Text(
            'Books',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(allBooks.length, (i) {
            final book = allBooks[i];
            final color = bookColors[i % bookColors.length];
            final chapters = book.chapters
                .map((ch) => ChapterInfo(id: ch.id, wordCount: ch.words.length))
                .toList();
            final completed = progress.completedChaptersForBook(book.id, chapters);
            final total = book.chapters.length;
            final fraction = total > 0 ? completed / total : 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: fraction,
                            strokeWidth: 5,
                            backgroundColor: color.withAlpha(40),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                          Text(
                            '${(fraction * 100).round()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completed / $total chapters',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withAlpha(120),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final ProgressService progress;

  const _WeeklyChart({required this.progress});

  @override
  Widget build(BuildContext context) {
    final data = progress.wordsStudiedPerDayThisWeek();
    final maxVal = data.values.fold<int>(0, (a, b) => a > b ? a : b);
    final colorScheme = Theme.of(context).colorScheme;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final today = DateTime.now();
    // Build 7 entries from 6 days ago to today
    final entries = <MapEntry<String, int>>[];
    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final label = dayLabels[day.weekday - 1];
      entries.add(MapEntry(label, data[day.weekday] ?? 0));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: entries.map((e) {
              final height = maxVal > 0 ? (e.value / maxVal) * 80 : 0.0;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (e.value > 0)
                      Text(
                        '${e.value}',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: height.clamp(4.0, 80.0),
                      decoration: BoxDecoration(
                        color: e.value > 0
                            ? colorScheme.primary
                            : colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
