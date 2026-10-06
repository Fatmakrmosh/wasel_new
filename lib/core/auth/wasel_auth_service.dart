import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_service.dart';
import 'phone_validator.dart';

class AuthResult {
  final bool success;
  final String? message;

  const AuthResult({
    required this.success,
    this.message,
  });
}

class WaselAuthService {
  WaselAuthService._();

  static final WaselAuthService instance = WaselAuthService._();

  SupabaseClient? get _client => SupabaseService.client;

  String _authEmail(String phone) {
    final normalized = SudanPhoneValidator.normalize(phone);
    final local = normalized.replaceFirst('+', '');
    return '$local@auth.wasel.internal';
  }

  Future<AuthResult> signIn({
    required String phone,
    required String password,
  }) async {
    final validation = SudanPhoneValidator.validate(phone);
    if (validation != null) {
      return AuthResult(success: false, message: validation);
    }

    final client = _client;
    if (client == null) {
      return const AuthResult(
        success: false,
        message: 'خدمة الدخول غير مهيأة حالياً',
      );
    }

    try {
      await client.auth.signInWithPassword(
        email: _authEmail(phone),
        password: password,
      );
      return const AuthResult(success: true);
    } on AuthException catch (error) {
      if (error.message.toLowerCase().contains('invalid login credentials')) {
        return const AuthResult(
          success: false,
          message: 'رقم الهاتف أو كلمة المرور غير صحيحة',
        );
      }

      return AuthResult(
        success: false,
        message: error.message,
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'تعذر تسجيل الدخول حالياً',
      );
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    if (name.trim().isEmpty) {
      return const AuthResult(
        success: false,
        message: 'يرجى إدخال الاسم الكامل',
      );
    }

    final validation = SudanPhoneValidator.validate(phone);
    if (validation != null) {
      return AuthResult(success: false, message: validation);
    }

    if (password.length < 6) {
      return const AuthResult(
        success: false,
        message: 'كلمة المرور يجب أن تكون 6 أحرف أو أكثر',
      );
    }

    final client = _client;
    if (client == null) {
      return const AuthResult(
        success: false,
        message: 'خدمة التسجيل غير مهيأة حالياً',
      );
    }

    try {
      final normalizedPhone = SudanPhoneValidator.normalize(phone);
      final response = await client.auth.signUp(
        email: _authEmail(phone),
        password: password,
        data: {
          'full_name': name.trim(),
          'phone': normalizedPhone,
        },
      );

      if (response.user == null) {
        return const AuthResult(
          success: false,
          message: 'تعذر إنشاء الحساب',
        );
      }

      return const AuthResult(success: true);
    } on AuthException catch (error) {
      return AuthResult(
        success: false,
        message: error.message,
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'تعذر إنشاء الحساب حالياً',
      );
    }
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) {
      return;
    }

    await client.auth.signOut();
  }

  Session? get session => _client?.auth.currentSession;

  User? get currentUser => _client?.auth.currentUser;
}
