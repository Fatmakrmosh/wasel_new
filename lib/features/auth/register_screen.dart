import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/wasel_auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/wasel_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('يرجى تعبئة جميع البيانات');
      return;
    }

    if (password.length < 6) {
      _showMessage('كلمة المرور يجب أن تكون 6 أحرف أو أكثر');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('كلمتا المرور غير متطابقتين');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await WaselAuthService.instance.signUp(
      name: nameController.text,
      phone: phoneController.text,
      password: password,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (!result.success) {
      _showMessage(result.message ?? 'تعذر إنشاء الحساب حالياً');
      return;
    }

    if (WaselAuthService.instance.currentUser != null) {
      context.go('/account-type');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message ?? 'تم إنشاء الحساب. يمكنك تسجيل الدخول الآن.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/login');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء حساب'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Image.asset(
                  'assets/images/wasel-logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'أنشئ حسابك في WASEL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'أدخل بياناتك للبدء في استخدام خدمات WASEL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: 'مثال: 00249110033224',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _continue(),
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              WaselButton(
                text: isLoading ? 'جارٍ إنشاء الحساب...' : 'متابعة',
                onPressed: isLoading ? () {} : _continue,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'لديك حساب بالفعل؟',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        isLoading ? null : () => context.go('/login'),
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'بإنشاء الحساب، أنت توافق على شروط استخدام WASEL وسياسة الخصوصية.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
