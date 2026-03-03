import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/vocabulary.dart';

class FlashcardScreen extends StatefulWidget {
  final VocabularyChapter chapter;
  final Color bookColor;

  const FlashcardScreen({
    super.key,
    required this.chapter,
    required this.bookColor,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  late FlutterTts _flutterTts;
  int _currentIndex = 0;
  bool _showAnswer = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _slidingForward = true;
  int _cardKey = 0;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTts();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _flipCard() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _nextCard() {
    if (_currentIndex < widget.chapter.words.length - 1) {
      setState(() {
        _slidingForward = true;
        _currentIndex++;
        _cardKey++;
        _showAnswer = false;
        _flipController.reset();
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _slidingForward = false;
        _currentIndex--;
        _cardKey++;
        _showAnswer = false;
        _flipController.reset();
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.chapter.words[_currentIndex];
    final progress = (_currentIndex + 1) / widget.chapter.words.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapter.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: widget.bookColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            // Progress dots
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_currentIndex + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.bookColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: widget.bookColor.withAlpha(30),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.bookColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${widget.chapter.words.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.bookColor.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),

            // Flashcard with arrows
            SizedBox(
              height: 630,
              child: Row(
                children: [
                  // Left arrow
                  IconButton(
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                    icon: Icon(
                      Icons.chevron_left,
                      size: 36,
                      color: _currentIndex > 0
                          ? widget.bookColor
                          : Colors.grey[300],
                    ),
                  ),
                  // Card
                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < -100) {
                            _nextCard();
                          } else if (details.primaryVelocity! > 100) {
                            _previousCard();
                          }
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              final isIncoming =
                                  child.key == ValueKey(_cardKey);
                              final offset = _slidingForward
                                  ? (isIncoming
                                        ? const Offset(1.0, 0.0)
                                        : const Offset(-1.0, 0.0))
                                  : (isIncoming
                                        ? const Offset(-1.0, 0.0)
                                        : const Offset(1.0, 0.0));
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: offset,
                                  end: Offset.zero,
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                        child: KeyedSubtree(
                          key: ValueKey(_cardKey),
                          child: AnimatedBuilder(
                            animation: _flipAnimation,
                            builder: (context, child) {
                              final angle = _flipAnimation.value * pi;
                              final isFront = angle < pi / 2;

                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle),
                                child: isFront
                                    ? _buildCardFront(word)
                                    : Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..rotateY(pi),
                                        child: _buildCardBack(word),
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Right arrow
                  IconButton(
                    onPressed: _currentIndex < widget.chapter.words.length - 1
                        ? _nextCard
                        : null,
                    icon: Icon(
                      Icons.chevron_right,
                      size: 36,
                      color: _currentIndex < widget.chapter.words.length - 1
                          ? widget.bookColor
                          : Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(VocabularyWord word) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [widget.bookColor.withAlpha(20), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.translate, size: 40, color: Colors.grey),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    word.korean,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _speak(word.korean),
                  icon: Icon(
                    Icons.volume_up,
                    color: widget.bookColor,
                    size: 32,
                  ),
                  tooltip: 'Listen to pronunciation',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Tap to see meaning',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(VocabularyWord word) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              widget.bookColor.withAlpha(40),
              widget.bookColor.withAlpha(10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word.korean,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Divider(
              indent: 60,
              endIndent: 60,
              color: widget.bookColor.withAlpha(100),
              thickness: 2,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                word.english,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.bookColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap to flip back',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
