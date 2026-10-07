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
      // Read the current user's role through a small SECURITY DEFINER RPC.
      // This avoids evaluating the profiles RLS policies while the gate
      // itself is deciding whether the user can enter administration.
      final result = await client.rpc('get_my_role');
      final role = result?.toString().trim().toLowerCase();
      final allowed = role == 'admin';

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

      debugPrint('WASEL admin gate error: $error');
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر التحقق من صلاحية الإدارة.'),
          duration: Duration(seconds: 6),
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
