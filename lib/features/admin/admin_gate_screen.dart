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
      final row = await client
          .from('profiles')
          .select('role,is_active')
          .eq('id', user.id)
          .maybeSingle();

      final role = row?['role'] as String?;
      final active = row?['is_active'] as bool? ?? false;

      if (!mounted) {
        return;
      }

      setState(() {
        _allowed = active && (role == 'admin' || role == 'supervisor');
        _loading = false;
      });

      if (!_allowed) {
        context.go('/home');
      }
    } catch (_) {
      if (mounted) {
        context.go('/home');
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
