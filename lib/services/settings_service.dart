import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService extends ChangeNotifier {
  static const _key = 'app_settings';

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  ThemeMode get themeMode =>
      _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  double get ttsSpeed => _settings.ttsSpeed;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      _settings = AppSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
  }

  Future<void> setDarkMode(bool value) async {
    _settings = _settings.copyWith(isDarkMode: value);
    await _save();
    notifyListeners();
  }

  Future<void> setTtsSpeed(double value) async {
    _settings = _settings.copyWith(ttsSpeed: value);
    await _save();
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    await _save();
    notifyListeners();
  }

  Future<void> setAppLanguage(String value) async {
    _settings = _settings.copyWith(appLanguage: value);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_settings.toJson()));
  }
}
