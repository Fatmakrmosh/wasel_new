import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_locale.dart';
import '../../core/theme/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = AppLocale.locale.value.languageCode;

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });

    AppLocale.setLanguage(language);

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = _selectedLanguage == 'en';

    return Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),

                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.lime.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    size: 58,
                    color: AppColors.lime,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  isEnglish ? 'Choose Language' : 'اختر اللغة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  isEnglish
                      ? 'Choose your preferred language'
                      : 'Choose your preferred language',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                _languageButton(
                  languageCode: 'ar',
                  title: 'العربية',
                  subtitle: 'اللغة العربية',
                  direction: TextDirection.rtl,
                ),

                const SizedBox(height: 14),

                _languageButton(
                  languageCode: 'en',
                  title: 'English',
                  subtitle: 'English language',
                  direction: TextDirection.ltr,
                ),

                const Spacer(),

                const Text(
                  'WASEL',
                  style: TextStyle(
                    color: AppColors.lime,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isEnglish ? 'We connect you with ease' : 'نوصلك بكل سهولة',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageButton({
    required String languageCode,
    required String title,
    required String subtitle,
    required TextDirection direction,
  }) {
    final bool selected = _selectedLanguage == languageCode;

    return SizedBox(
      width: double.infinity,
      height: 76,
      child: OutlinedButton(
        onPressed: () => _selectLanguage(languageCode),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: selected
              ? AppColors.lime.withValues(alpha: 0.08)
              : AppColors.surface,
          side: BorderSide(
            color: selected
                ? AppColors.lime
                : Colors.white.withValues(alpha: 0.12),
            width: selected ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Directionality(
          textDirection: direction,
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.lime : Colors.white38,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white38,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}