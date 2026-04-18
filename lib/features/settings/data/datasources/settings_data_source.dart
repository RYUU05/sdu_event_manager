import 'package:flutter/foundation.dart';
import 'package:event_manager/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDataSource {
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('All good cleared cuhh');
    } catch (e) {
      debugPrint('We got error with clearing cuhh $e');
    }
  }

  Future<void> changeLanguage(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.langKey, code);
      debugPrint('Language saved cuhh $code');
    } catch (e) {
      debugPrint("We ain't saved language cuhh $e");
    }
  }

  Future<String> getLang() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.langKey) ?? 'en';
    } catch (e) {
      debugPrint('Error getting language cuhh $e');
      return AppConstants.english;
    }
  }
}
