import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English'),
  swahili('sw', 'Swahili');

  final String code;
  final String name;
  const AppLanguage(this.code, this.name);
}

class LanguageService extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;
  String get currentLanguageCode => _currentLanguage.code;
  String get currentLanguageName => _currentLanguage.name;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('app_language') ?? 'en';
      _currentLanguage = AppLanguage.values.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => AppLanguage.english,
      );
      notifyListeners();
    } catch (e) {
      // Default to English if loading fails
      _currentLanguage = AppLanguage.english;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    
    _currentLanguage = language;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', language.code);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  // Translation helper methods (basic implementation)
  String translate(String englishText, String swahiliText) {
    return _currentLanguage == AppLanguage.swahili ? swahiliText : englishText;
  }
}

