import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/wasel_auth_service.dart';
import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_locale.dart';
import '../../core/localization/app_strings.dart';
import '../../core/widgets/wasel_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.message});

  final String? message;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode passwordVisibilityFocusNode = FocusNode(
    skipTraversal: true,
    canRequestFocus: false,
  );

  void _togglePasswordVisibility() {
    final selection = passwordController.selection;
    setState(() {
      obscurePassword = !obscurePassword;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      passwordFocusNode.requestFocus();
      passwordController.selection = selection;
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    passwordVisibilityFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    final result = await WaselAuthService.instance.signIn(
      phone: phoneController.text,
      password: passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (result.success) {
      final user = WaselAuthService.instance.currentUser;
      if (user != null) {
        try {
          final client = SupabaseService.client;
          final profile = await client
              ?.from('profiles')
              .select('role')
              .eq('id', user.id)
              .maybeSingle();
          final role = profile?['role'] as String?;
          final requestedType =
              WaselAuthService.instance.requestedAccountType;
          if (!mounted) return;

          if (role == 'admin' || role == 'supervisor') {
            context.go('/admin');
          } else if (role == 'driver') {
            context.go('/account-mode');
          } else if (role == 'company') {
            context.go('/company-home');
          } else if (requestedType == 'driver') {
            context.go('/account-mode');
          } else if (requestedType == 'company') {
            context.go('/company-register');
          } else {
            context.go('/home');
          }
          return;
        } catch (_) {
          // Fall back to the normal home screen if the profile cannot be read.
        }
      }

      if (mounted) context.go('/home');
      return;
    }

    final message = result.message ?? (AppLocale.isEnglish ? 'Unable to log in right now' : 'تعذر تسجيل الدخول حالياً');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: message.contains('إنشاء حساب') || message.contains('Create an account')
            ? SnackBarAction(
                label: AppStrings.createAccount.replaceFirst('Create a new account', 'Create account'),
                onPressed: () => context.go('/register'),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.login),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Image.asset(
                  'assets/images/wasel-logo.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.welcome,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.loginSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppStrings.phone,
                  hintText: AppStrings.phoneHint,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordVisibility,
                    focusNode: passwordVisibilityFocusNode,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppStrings.passwordRecoveryLater,
                        ),
                      ),
                    );
                  },
                  child: Text(AppStrings.forgotPassword),
                ),
              ),
              const SizedBox(height: 16),
              WaselButton(
                text: isLoading ? AppStrings.loggingIn : AppStrings.enter,
                onPressed: isLoading ? () {} : _login,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppStrings.or,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      isLoading ? null : () => context.go('/register'),
                  child: Text(AppStrings.createAccount),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.terms,
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
