import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/supabase_service.dart';
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
      // The profiles.id is linked to auth.users.id, so this is the
      // RLS-safe lookup and matches the "read own profile" policy.
      final row = await client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

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
      if (!mounted) {
        return;
      }

      String message = 'حدث خطأ أثناء التحقق من صلاحية الإدارة.';
      final text = error.toString().toLowerCase();

      if (text.contains('permission denied') ||
          text.contains('row-level security') ||
          text.contains('rls')) {
        message = 'تعذر قراءة صلاحية الحساب من Supabase.';
      } else if (text.contains('user_permissions')) {
        message = 'حصل خطأ في صلاحيات المشرفين.';
      } else if (text.contains('profiles')) {
        message = 'تعذر قراءة ملف الحساب من profiles.';
      }

      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 6),
        ),
      );
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
