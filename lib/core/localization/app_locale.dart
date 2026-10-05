import 'package:flutter/material.dart';

class AppLocale {
  static final ValueNotifier<Locale> locale =
      ValueNotifier<Locale>(const Locale('ar'));

  static void setLanguage(String languageCode) {
    locale.value = Locale(languageCode);
  }

  static bool get isArabic => locale.value.languageCode == 'ar';

  static bool get isEnglish => locale.value.languageCode == 'en';
}