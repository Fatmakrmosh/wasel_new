import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/wasel_auth_service.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_theme.dart';

class AccountModeScreen extends StatelessWidget {
  const AccountModeScreen({super.key});

  void _openPassenger(BuildContext context) {
    context.go('/home');
  }

  void _openDriver(BuildContext context) {
    context.go('/driver-home');
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = AppLocale.isEnglish;
    final requestedType = WaselAuthService.instance.requestedAccountType;

    return Directionality(
      textDirection:
          isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            isEnglish ? 'Choose your mode' : 'اختر وضع الاستخدام',
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Center(
                child: Image.asset(
                  'assets/images/wasel-logo.png',
                  width: 92,
                  height: 92,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                isEnglish
                    ? 'How do you want to use WASEL today?'
                    : 'كيف تريد استخدام WASEL اليوم؟',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isEnglish
                    ? 'You can switch between passenger and driver mode.'
                    : 'يمكنك التبديل بين وضع الراكب ووضع السائق.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              _ModeCard(
                icon: Icons.person_outline_rounded,
                title: isEnglish ? 'Passenger' : 'راكب / عميل',
                subtitle: isEnglish
                    ? 'Book rides, parcels and other WASEL services.'
                    : 'اطلب الرحلات والطرود وبقية خدمات WASEL.',
                onTap: () => _openPassenger(context),
              ),
              const SizedBox(height: 14),
              _ModeCard(
                icon: Icons.drive_eta_outlined,
                title: isEnglish ? 'Driver' : 'سائق',
                subtitle: isEnglish
                    ? 'See available ride requests and submit your fare.'
                    : 'شاهد طلبات الرحلات المتاحة وقدّم عرضك السعري.',
                highlighted: requestedType == 'driver',
                onTap: () => _openDriver(context),
              ),
              const SizedBox(height: 22),
              Text(
                isEnglish
                    ? 'Your account type is stored separately from the mode you are using now.'
                    : 'نوع الحساب محفوظ بشكل منفصل عن الوضع الذي تستخدمه الآن.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: highlighted
                  ? AppColors.lime.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.lime,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.muted,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
