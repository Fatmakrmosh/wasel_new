import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/wasel_auth_service.dart';
import '../../core/network/supabase_service.dart';
import '../../core/localization/app_locale.dart';
import '../../core/localization/app_strings.dart';

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

  static const _blue = Color(0xFF1769D2);
  static const _text = Color(0xFF172033);
  static const _muted = Color(0xFF737B8C);

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

    final message = result.message ??
        (AppLocale.isEnglish
            ? 'Unable to log in right now'
            : 'تعذر تسجيل الدخول حالياً');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: message.contains('إنشاء حساب') ||
                message.contains('Create an account')
            ? SnackBarAction(
                label: AppStrings.createAccount.replaceFirst(
                  'Create a new account',
                  'Create account',
                ),
                onPressed: () => context.go('/register'),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          AppLocale.isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.language_outlined, color: _muted),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Image.asset(
                  'assets/images/wasel-logo.png',
                  width: 94,
                  height: 94,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocale.isEnglish ? 'Welcome!' : 'مرحباً بك!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _text,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.login,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),
              _buildField(
                controller: phoneController,
                label: AppStrings.phone,
                hint: AppStrings.phoneHint,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: passwordController,
                label: AppStrings.password,
                icon: Icons.lock_outline,
                focusNode: passwordFocusNode,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                suffix: IconButton(
                  onPressed: _togglePasswordVisibility,
                  focusNode: passwordVisibilityFocusNode,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _muted,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.passwordRecoveryLater),
                      ),
                    );
                  },
                  child: Text(
                    AppStrings.forgotPassword,
                    style: const TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    disabledBackgroundColor: _blue.withValues(alpha: 0.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    isLoading ? AppStrings.loggingIn : AppStrings.enter,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Color(0xFFE1E5EB)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppStrings.or,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Color(0xFFE1E5EB)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed:
                      isLoading ? null : () => context.go('/register'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: Color(0xFFD4DCE8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    AppStrings.createAccount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (widget.message != null) ...[
                const SizedBox(height: 14),
                Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                AppStrings.terms,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _muted),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
      ),
    );
  }

}
