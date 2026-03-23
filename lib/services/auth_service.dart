import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  static const String _serverClientId =
      '17690028528-pjf8l119vlceokl71qmt23vu90j1du0o.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<void> init() async {
    if (!_initialized) {
      await _googleSignIn.initialize(serverClientId: _serverClientId);
      _initialized = true;
    }

    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user_profile');
    if (json != null) {
      _currentUser = UserProfile.fromJson(jsonDecode(json));
      notifyListeners();
    }
  }

  Future<UserProfile?> signInWithGoogle() async {
    try {
      if (!_initialized) {
        await _googleSignIn.initialize(serverClientId: _serverClientId);
        _initialized = true;
      }

      final account = await _googleSignIn.authenticate();

      _currentUser = UserProfile(
        name: account.displayName ?? '',
        email: account.email,
        photoUrl: account.photoUrl,
      );

      await _saveProfile();
      notifyListeners();
      return _currentUser;
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? gender,
    DateTime? dob,
    String? language,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      gender: gender,
      dob: dob,
      language: language,
    );
    await _saveProfile();
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(_currentUser!.toJson()));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    notifyListeners();
  }
}
