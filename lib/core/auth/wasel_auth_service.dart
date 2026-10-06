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
    final digits = normalized.substring(1).replaceAll('+', '');
    return '$digits@auth.wasel.internal';
  }

  Future<bool> phoneAccountExists(String phone) async {
    final client = _client;
    if (client == null) {
      return false;
    }

    final normalized = SudanPhoneValidator.normalize(phone);

    try {
      final result = await client.rpc(
        'phone_account_exists',
        params: {'normalized_phone': normalized},
      );
      return result == true;
    } catch (_) {
      // Do not block login if the optional account-existence RPC
      // has not been installed yet.
      return true;
    }
  }

  Future<AuthResult> signIn({
    required String phone,
    required String password,
  }) async {
    final validation = SudanPhoneValidator.validate(phone);
    if (validation != null) {
      return AuthResult(success: false, message: validation);
    }

    if (password.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'يرجى إدخال كلمة المرور',
      );
    }

    final client = _client;
    if (client == null) {
      return const AuthResult(
        success: false,
        message: 'خدمة الدخول غير مهيأة حالياً',
      );
    }

    final exists = await phoneAccountExists(phone);

    if (!exists) {
      return const AuthResult(
        success: false,
        message: 'لا يوجد حساب بهذا الرقم — هل تريد إنشاء حساب؟',
      );
    }

    try {
      await client.auth.signInWithPassword(
        email: _authEmail(phone),
        password: password,
      );

      return const AuthResult(success: true);
    } on AuthException catch (error) {
      final message = error.message.toLowerCase();

      if (message.contains('invalid login credentials')) {
        return const AuthResult(
          success: false,
          message: 'كلمة المرور غير صحيحة.',
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

    final exists = await phoneAccountExists(phone);

    if (exists) {
      return const AuthResult(
        success: false,
        message: 'يوجد حساب بهذا الرقم بالفعل. استخدم تسجيل الدخول.',
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
          'requested_account_type': 'passenger',
        },
      );

      if (response.user == null) {
        return const AuthResult(
          success: false,
          message: 'تعذر إنشاء الحساب',
        );
      }

      if (response.session == null) {
        return const AuthResult(
          success: true,
          message: 'تم إنشاء الحساب. يمكنك تسجيل الدخول الآن.',
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

  Future<AuthResult> setRequestedAccountType(
    String accountType,
  ) async {
    final client = _client;
    final user = currentUser;

    if (client == null || user == null) {
      return const AuthResult(
        success: false,
        message: 'انتهت جلسة التسجيل، يرجى تسجيل الدخول مرة أخرى.',
      );
    }

    if (!{'passenger', 'driver', 'company'}.contains(accountType)) {
      return const AuthResult(
        success: false,
        message: 'نوع الحساب غير صالح',
      );
    }

    try {
      final result = await client.rpc(
        'set_requested_account_type',
        params: {'account_type': accountType},
      );

      if (result != true) {
        return const AuthResult(
          success: false,
          message: 'تعذر حفظ نوع الحساب حالياً',
        );
      }

      return const AuthResult(success: true);
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'تعذر حفظ نوع الحساب حالياً',
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
