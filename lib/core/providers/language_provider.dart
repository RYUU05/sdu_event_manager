import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_manager/core/constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode =
          prefs.getString(_languageKey) ?? AppConstants.english;
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing language: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      _locale = Locale(languageCode);
      notifyListeners();
      debugPrint('Language changed to: $languageCode');
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      changeLanguage('ru');
    } else {
      changeLanguage('en');
    }
  }
}
