import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/supabase_service.dart';
import '../../core/auth/phone_validator.dart';
import '../../core/theme/app_theme.dart';
import 'admin_dashboard_screen.dart';

class AdminGateScreen extends StatefulWidget {
  const AdminGateScreen({super.key});

  @override
  State<AdminGateScreen> createState() => _AdminGateScreenState();
}

class _AdminGateScreenState extends State<AdminGateScreen> {
  bool _loading = true;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    try {
      Map<String, dynamic>? row = await client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (row == null && user.phone != null && user.phone!.isNotEmpty) {
        row = await client
            .from('profiles')
            .select('role')
            .eq('phone', user.phone!)
            .maybeSingle();
      }

      if (row == null && user.email != null) {
        final email = user.email!;
        const prefix = 'wasel_';
        if (email.startsWith(prefix)) {
          final at = email.indexOf('@');
          if (at > prefix.length) {
            final digits = email.substring(prefix.length, at);
            final phone = SudanPhoneValidator.normalize('+$digits');
            row = await client
                .from('profiles')
                .select('role')
                .eq('phone', phone)
                .maybeSingle();
          }
        }
      }

      final role = row?['role']?.toString().trim().toLowerCase();
      var allowed = role == 'admin';

      if (role == 'supervisor') {
        final grants = await client
            .from('user_permissions')
            .select('permission_id')
            .eq('user_id', user.id)
            .limit(1);
        allowed = grants.isNotEmpty;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _allowed = allowed;
        _loading = false;
      });

      if (!_allowed) {
        context.go('/home');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر فتح لوحة الإدارة: $error')),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_allowed) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.lime,
          ),
        ),
      );
    }

    return const AdminDashboardScreen();
  }
}
