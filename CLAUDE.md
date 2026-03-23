# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KIIP Vocabulary Flashcard app — a Flutter app for studying Korean vocabulary from the KIIP (Korea Immigration & Integration Program) textbook series. Users select a book, then a chapter, then study Korean-English flashcards with flip animations and TTS pronunciation.

## Commands

- **Run**: `flutter run` (add `-d windows`, `-d chrome`, etc. for specific platforms)
- **Analyze**: `flutter analyze`
- **Test**: `flutter test` (single test: `flutter test test/widget_test.dart`)
- **Get dependencies**: `flutter pub get`

## Architecture

Three-screen navigation flow using Flutter's `Navigator.push`:

1. **HomeScreen** — lists all 4 KIIP books with cover images
2. **ChaptersScreen** — lists chapters for a selected book
3. **FlashcardScreen** — swipeable/tappable flashcard with flip animation and Korean TTS (`flutter_tts`, language `ko-KR`)

### Data Layer

- `lib/models/vocabulary.dart` — three model classes: `VocabularyBook` → `VocabularyChapter` → `VocabularyWord` (korean/english pair)
- `lib/data/book1.dart` through `book4.dart` — hardcoded vocabulary data, each exports a single `VocabularyBook` constant
- `lib/data/all_books.dart` — aggregates all books into `allBooks` list

### Key Dependencies

- `flutter_tts` — text-to-speech for Korean pronunciation
- Lint rules from `package:flutter_lints/flutter.yaml`

### Assets

Book cover images at `lib/assets/images/Book{1-4}.jpg`, declared in `pubspec.yaml`.
