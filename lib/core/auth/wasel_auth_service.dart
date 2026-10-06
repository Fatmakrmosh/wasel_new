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

  Future<bool?> phoneAccountExists(String phone) async {
    final client = _client;
    if (client == null) {
      return null;
    }

    final normalized = SudanPhoneValidator.normalize(phone);

    try {
      final result = await client.rpc(
        'phone_account_exists',
        params: {'normalized_phone': normalized},
      );

      return result == true;
    } on PostgrestException {
      return null;
    } catch (_) {
      return null;
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

    if (exists == false) {
      return const AuthResult(
        success: false,
        message: 'لا يوجد حساب بهذا الرقم — هل تريد إنشاء حساب؟',
      );
    }

    if (exists == null) {
      return const AuthResult(
        success: false,
        message: 'تعذر التحقق من الحساب حالياً. حاول مرة أخرى.',
      );
    }

    try {
      await client.auth.signInWithPassword(
        email: _authEmail(phone),
        password: password,
      );

      return const AuthResult(success: true);
    } on AuthException catch (_) {
      return const AuthResult(
        success: false,
        message: 'كلمة المرور غير صحيحة.',
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'تعذر تسجيل الدخول حالياً. حاول مرة أخرى.',
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

    if (exists == true) {
      return const AuthResult(
        success: false,
        message: 'يوجد حساب بهذا الرقم بالفعل. استخدم تسجيل الدخول.',
      );
    }

    if (exists == null) {
      return const AuthResult(
        success: false,
        message: 'تعذر التحقق من الرقم حالياً. حاول مرة أخرى.',
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
          message: 'تعذر إنشاء الحساب حالياً.',
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
      final message = error.message.toLowerCase();
      if (message.contains('already registered') ||
          message.contains('already exists') ||
          message.contains('user already')) {
        return const AuthResult(
          success: false,
          message: 'يوجد حساب بهذا الرقم بالفعل. استخدم تسجيل الدخول.',
        );
      }

      return const AuthResult(
        success: false,
        message: 'تعذر إنشاء الحساب حالياً. حاول مرة أخرى.',
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'تعذر إنشاء الحساب حالياً. حاول مرة أخرى.',
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