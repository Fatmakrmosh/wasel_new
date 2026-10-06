import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/wasel_auth_service.dart';
import '../../core/theme/app_theme.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  Future<void> _select(
    BuildContext context,
    String accountType,
    String route,
  ) async {
    final result =
        await WaselAuthService.instance.setRequestedAccountType(accountType);

    if (!context.mounted) {
      return;
    }

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result.message ?? 'تعذر حفظ نوع الحساب حالياً'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'راكب',
        subtitle: 'اطلب رحلات داخل المدينة وبين المدن وأرسل طرودك',
        icon: Icons.person_outline,
        type: 'passenger',
        route: '/home',
      ),
      (
        title: 'سائق',
        subtitle: 'استقبل طلبات الرحلات وحقق دخلاً مع WASEL',
        icon: Icons.drive_eta_outlined,
        type: 'driver',
        route: '/driver-register',
      ),
      (
        title: 'شركة نقل',
        subtitle: 'أدر رحلاتك ومركباتك وسائقيك عبر WASEL',
        icon: Icons.business_outlined,
        type: 'company',
        route: '/company-register',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نوع الحساب'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              Center(
                child: Image.asset(
                  'assets/images/wasel-logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'اختر نوع حسابك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'اختيارك هنا يحدد مسار التسجيل فقط، ولا يمنح صلاحيات إدارية.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AccountTypeCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    onTap: () => _select(
                      context,
                      item.type,
                      item.route,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'صلاحيات السائق والشركة والإدارة تُمنح من النظام ولا تُحدد من هذه الشاشة.',
                textAlign: TextAlign.center,
                style: TextStyle(
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

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.lime.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.lime,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_back_ios_new,
                size: 17,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
