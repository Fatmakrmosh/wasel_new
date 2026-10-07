import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = true;
  String _role = 'supervisor';
  Set<String> _permissionCodes = {};
  int _users = 0;
  int _drivers = 0;
  int _companies = 0;
  int _supervisors = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;

    // The role is the critical part of the dashboard. Load it first and
    // render the admin actions immediately. Statistics/permissions must not
    // be allowed to disable the whole administration screen.
    try {
      final roleResult = await client.rpc('get_my_role');
      final role = roleResult?.toString().trim().toLowerCase() ?? 'supervisor';

      if (!mounted) return;
      setState(() {
        _role = role;
        _permissionCodes = {};
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('WASEL admin role error: $error');
      setState(() => _loading = false);
      _message('تعذر تحميل صلاحيات الإدارة');
      return;
    }

    // Permissions are only needed for supervisors. Admins already have full
    // access and should never depend on the permission tables to open the UI.
    if (_role == 'supervisor') {
      try {
        final grants = await client
            .from('user_permissions')
            .select('permission_id')
            .eq('user_id', user.id);

        final permissionIds = grants
            .map((row) => (row['permission_id'] as num).toInt())
            .toList();

        if (permissionIds.isNotEmpty) {
          final permissions = await client
              .from('permissions')
              .select('id,code')
              .inFilter('id', permissionIds);

          final permissionCodes = permissions
              .map<String>((row) => row['code'].toString().toLowerCase())
              .toSet();

          if (mounted) {
            setState(() => _permissionCodes = permissionCodes);
          }
        }
      } catch (error) {
        debugPrint('WASEL supervisor permissions error: $error');
        // Keep the dashboard usable even if permission details cannot be read.
      }
    }

    // Statistics are optional. A failure here must not hide management actions.
    try {
      final stats = await client.rpc('admin_get_profile_counts');
      final data = Map<String, dynamic>.from(stats as Map);
      final users = (data['passenger'] as num?)?.toInt() ?? 0;
      final drivers = (data['driver'] as num?)?.toInt() ?? 0;
      final companies = (data['company'] as num?)?.toInt() ?? 0;
      final supervisors = (data['supervisor'] as num?)?.toInt() ?? 0;

      if (!mounted) return;
      setState(() {
        _users = users;
        _drivers = drivers;
        _companies = companies;
        _supervisors = supervisors;
      });
    } catch (error) {
      debugPrint('WASEL admin statistics error: $error');
      // Leave statistics at zero and keep all admin actions available.
    }
  }

  bool get _isAdmin => _role == 'admin';

  bool _can(String area) {
    if (_isAdmin) return true;
    if (_role != 'supervisor') return false;
    if (_permissionCodes.contains('manage_all') || _permissionCodes.contains('admin_all')) return true;

    const aliases = <String, List<String>>{
      'users': ['user', 'account', 'passenger'],
      'drivers': ['driver'],
      'companies': ['company'],
      'rides': ['ride', 'trip', 'route'],
      'parcels': ['parcel', 'package', 'shipment'],
      'permissions': ['permission', 'supervisor'],
      'settings': ['setting', 'system'],
    };
    return _permissionCodes.any((code) =>
        aliases[area]?.any((word) => code.contains(word)) ?? false);
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.lime)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          _isAdmin ? 'لوحة المدير' : 'لوحة المشرف',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.lime,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 18),
            _section('الإحصائيات'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                _stat('المستخدمون', _users, Icons.people_alt_outlined),
                _stat('السائقون', _drivers, Icons.drive_eta_outlined),
                _stat('الشركات', _companies, Icons.business_outlined),
                _stat('المشرفون', _supervisors, Icons.admin_panel_settings_outlined),
              ],
            ),
            const SizedBox(height: 24),
            _section('الإدارة'),
            const SizedBox(height: 10),
            if (_can('users'))
              _action(
                'المستخدمون والحسابات',
                'عرض الحسابات وإدارة الحسابات حسب الصلاحية',
                Icons.people_alt_outlined,
                () => context.push('/admin/users'),
              ),
            if (_isAdmin)
              _action(
                'المشرفون والصلاحيات',
                'تعيين المشرفين ومنح أو سحب الصلاحيات',
                Icons.admin_panel_settings_outlined,
                () => context.push('/admin/permissions'),
              ),
            if (_can('drivers'))
              _action(
              'مراجعة السائقين',
              'عرض حسابات السائقين ومراجعة بياناتهم',
              Icons.fact_check_outlined,
              () => context.push('/admin/users?filter=driver'),
            ),
            if (_can('rides'))
              _action(
              'الرحلات والمتابعة',
              'مراقبة الرحلات وحالاتها من البيانات الفعلية',
              Icons.route_outlined,
              () => context.push('/admin/rides'),
            ),
            if (_can('companies'))
              _action(
                'إدارة الشركات',
                'عرض حسابات شركات النقل المسجلة',
                Icons.business_outlined,
                () => context.push('/admin/users?filter=company'),
              ),
            if (_isAdmin || _can('settings'))
              _action(
                'إعدادات النظام',
                'الإعدادات العامة للمنصة',
                Icons.settings_outlined,
                () => _message('إعدادات النظام قيد البناء'),
              ),
            const SizedBox(height: 20),
            if (_isAdmin)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lime.withValues(alpha: 0.16)),
                ),
                child: const Text(
                  'المدير هو صاحب الصلاحية الأعلى. المشرف لا يحصل على صلاحيات إضافية إلا التي يمنحها المدير.',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white70, height: 1.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.lime.withValues(alpha: 0.18)),
    ),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.lime.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.lime, size: 31),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isAdmin ? 'مدير النظام' : 'مشرف النظام',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                _isAdmin ? 'تحكم كامل في منصة WASEL' : 'إدارة حسب الصلاحيات الممنوحة',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _section(String title) => Text(
    title,
    textAlign: TextAlign.right,
    style: const TextStyle(color: AppColors.lime, fontSize: 16, fontWeight: FontWeight.bold),
  );

  Widget _stat(String title, int value, IconData icon) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.lime, size: 22),
        const Spacer(),
        Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    ),
  );

  Widget _action(String title, String subtitle, IconData icon, VoidCallback onTap) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: Colors.white10),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: ListTile(
      onTap: onTap,
      leading: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white30, size: 16),
      trailing: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.lime.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.lime),
      ),
      title: Text(title, textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ),
    ),
  );
}
