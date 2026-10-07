import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocale {
  static const _storageKey = 'wasel_language';
  static final ValueNotifier<Locale> locale =
      ValueNotifier<Locale>(const Locale('ar'));

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code == 'ar' || code == 'en') {
      locale.value = Locale(code!);
    }
  }

  static Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') {
      languageCode = 'ar';
    }
    locale.value = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, languageCode);
  }

  static bool get isArabic => locale.value.languageCode == 'ar';
  static bool get isEnglish => locale.value.languageCode == 'en';
}
