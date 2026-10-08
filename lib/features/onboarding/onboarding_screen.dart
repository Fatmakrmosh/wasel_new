import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_locale.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int index = 0;

  List<_OnboardingPage> get pages => [
    _OnboardingPage(
      title: AppLocale.isEnglish ? 'Easier rides' : 'رحلات أسهل',
      description: AppLocale.isEnglish ? 'Request a city ride, receive driver offers, and choose the offer that suits you.' : 'اطلب رحلتك داخل المدينة بسهولة، واستقبل عروض السائقين واختر العرض المناسب لك.',
      icon: Icons.directions_car_filled_rounded,
    ),
    _OnboardingPage(
      title: AppLocale.isEnglish ? 'Send parcels' : 'إرسال الطرود',
      description: AppLocale.isEnglish ? 'Send parcels between cities safely and track your shipment with a WASEL tracking number.' : 'أرسل طرودك بين المدن بأمان وتابع حالة شحنتك باستخدام رقم تتبع WASEL.',
      icon: Icons.inventory_2_rounded,
    ),
    _OnboardingPage(
      title: AppLocale.isEnglish ? 'Intercity travel' : 'رحلات بين المدن',
      description: AppLocale.isEnglish ? 'Book a limousine or bus between cities and enjoy an organized WASEL travel experience.' : 'احجز ليموزين أو باصًا بين المدن واستمتع بتجربة سفر منظمة مع WASEL.',
      icon: Icons.directions_bus_filled_rounded,
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _goToLanguage() {
    context.go('/language');
  }

  void _nextPage() {
    if (index == pages.length - 1) {
      _goToLanguage();
      return;
    }

    controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: TextButton(
                  onPressed: _goToLanguage,
                  child: Text(
                    AppLocale.isEnglish ? 'Skip' : 'تخطي',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (value) {
                  setState(() {
                    index = value;
                  });
                },
                itemBuilder: (_, pageIndex) {
                  final page = pages[pageIndex];

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            color: AppColors.lime.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.lime.withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.lime.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                page.icon,
                                size: 58,
                                color: AppColors.lime,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 16,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) {
                  final bool active = i == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: active ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.lime
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    index == pages.length - 1 ? (AppLocale.isEnglish ? 'Get started' : 'ابدأ الآن') : (AppLocale.isEnglish ? 'Next' : 'التالي'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}