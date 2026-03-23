import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LanguageOption {
  final String flag;
  final String name;
  final String nativeName;
  final String wordForLanguage;
  final Color color;

  const LanguageOption({
    required this.flag,
    required this.name,
    required this.nativeName,
    required this.wordForLanguage,
    required this.color,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  static const List<LanguageOption> _languages = [
    LanguageOption(
      flag: '🇺🇸', name: 'English', nativeName: 'English',
      wordForLanguage: 'Language', color: Color(0xFF3C3B6E),
    ),
    LanguageOption(
      flag: '🇮🇳', name: 'Hindi', nativeName: 'हिन्दी',
      wordForLanguage: 'भाषा', color: Color(0xFFFF9933),
    ),
    LanguageOption(
      flag: '🇻🇳', name: 'Vietnamese', nativeName: 'Tiếng Việt',
      wordForLanguage: 'Ngôn ngữ', color: Color(0xFFDA251D),
    ),
    LanguageOption(
      flag: '🇨🇳', name: 'Chinese', nativeName: '中文',
      wordForLanguage: '语言', color: Color(0xFFDE2910),
    ),
    LanguageOption(
      flag: '🇵🇭', name: 'Filipino', nativeName: 'Filipino',
      wordForLanguage: 'Wika', color: Color(0xFF0038A8),
    ),
    LanguageOption(
      flag: '🇧🇩', name: 'Bengali', nativeName: 'বাংলা',
      wordForLanguage: 'ভাষা', color: Color(0xFF006A4E),
    ),
    LanguageOption(
      flag: '🇹🇭', name: 'Thai', nativeName: 'ภาษาไทย',
      wordForLanguage: 'ภาษา', color: Color(0xFF241D4F),
    ),
    LanguageOption(
      flag: '🇰🇿', name: 'Kazakh', nativeName: 'Қазақша',
      wordForLanguage: 'Тіл', color: Color(0xFF00AFCA),
    ),
    LanguageOption(
      flag: '🇮🇩', name: 'Indonesian', nativeName: 'Bahasa Indonesia',
      wordForLanguage: 'Bahasa', color: Color(0xFFCE1126),
    ),
    LanguageOption(
      flag: '🇵🇰', name: 'Urdu', nativeName: 'اردو',
      wordForLanguage: 'زبان', color: Color(0xFF01411C),
    ),
    LanguageOption(
      flag: '🇺🇿', name: 'Uzbek', nativeName: 'Oʻzbekcha',
      wordForLanguage: 'Til', color: Color(0xFF1EB53A),
    ),
    LanguageOption(
      flag: '🇲🇳', name: 'Mongolian', nativeName: 'Монгол',
      wordForLanguage: 'Хэл', color: Color(0xFF0066B3),
    ),
    LanguageOption(
      flag: '🇰🇭', name: 'Khmer', nativeName: 'ភាសាខ្មែរ',
      wordForLanguage: 'ភាសា', color: Color(0xFF032EA1),
    ),
  ];

  int _currentIndex = 0;
  late Timer _timer;
  late AnimationController _fadeSlideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _colorController;
  late Animation<double> _colorAnimation;
  late AnimationController _orbitController;

  Color _currentColor = _languages[0].color;
  Color _nextColor = _languages[0].color;

  @override
  void initState() {
    super.initState();

    _fadeSlideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeSlideController, curve: Curves.easeOutBack),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeSlideController, curve: Curves.easeOutBack),
    );
    _fadeSlideController.forward();

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _colorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );

    _orbitController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fadeSlideController.reverse().then((_) {
        final prevIndex = _currentIndex;
        setState(() {
          _currentIndex = (_currentIndex + 1) % _languages.length;
          _currentColor = _languages[prevIndex].color;
          _nextColor = _languages[_currentIndex].color;
        });
        _colorController.forward(from: 0.0);
        _fadeSlideController.forward();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _fadeSlideController.dispose();
    _colorController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  void _selectLanguage(LanguageOption language) async {
    await context.read<AuthService>().updateProfile(language: language.name);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = _languages[_currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top section with shadowy box
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                final accentColor = Color.lerp(
                  _currentColor,
                  _nextColor,
                  _colorAnimation.value,
                )!;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.only(top: 18, bottom: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withAlpha(15),
                        accentColor.withAlpha(30),
                        accentColor.withAlpha(10),
                      ],
                    ),
                    border: Border.all(
                      color: accentColor.withAlpha(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(30),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: accentColor.withAlpha(15),
                        blurRadius: 40,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // "Select Your" in a highlighted pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: accentColor.withAlpha(50),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withAlpha(20),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Select Your',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Animated language word with orbiting butterfly flags
                      SizedBox(
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _buildOrbitingFlags(currentLang.flag),
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  currentLang.wordForLanguage,
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                    shadows: [
                                      Shadow(
                                        color: accentColor.withAlpha(100),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                      Shadow(
                                        color: accentColor.withAlpha(50),
                                        blurRadius: 32,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Flag grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    return _buildFlagCard(lang);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitingFlags(String flag) {
    const int count = 5;
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(count, (i) {
            final phase = (i / count) * 2 * pi;
            final t = _orbitController.value * 2 * pi + phase;

            final radiusX = 90.0 + 15 * sin(t * 2 + i);
            final radiusY = 30.0 + 8 * cos(t * 3 + i);
            final x = radiusX * cos(t);
            final y = radiusY * sin(t);

            final depthFactor = 0.5 + 0.5 * ((sin(t) + 1) / 2);
            final size = 14.0 + 8.0 * depthFactor;
            final opacity = 0.3 + 0.7 * depthFactor;

            final flutter = sin(t * 6 + i * 1.5) * 0.3;

            return Transform.translate(
              offset: Offset(x, y),
              child: Transform.rotate(
                angle: flutter,
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    flag,
                    style: TextStyle(fontSize: size),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFlagCard(LanguageOption lang) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _selectLanguage(lang),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lang.flag,
                style: const TextStyle(fontSize: 44),
              ),
              const SizedBox(height: 6),
              Text(
                lang.nativeName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                lang.name,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
