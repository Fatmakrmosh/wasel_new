import 'package:flutter/material.dart';

import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class AdminPermissionsScreen extends StatefulWidget {
  const AdminPermissionsScreen({super.key});
  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  bool _loading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _supervisors = [];
  List<Map<String, dynamic>> _permissions = [];
  String? _selectedSupervisor;
  Set<int> _granted = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final client = SupabaseService.client;
    if (client == null) return;
    setState(() => _loading = true);
    try {
      if (client.auth.currentUser == null) return;
      final role = await client.rpc('get_my_role');
      if (role?.toString().trim().toLowerCase() != 'admin') {
        if (mounted) setState(() { _isAdmin = false; _loading = false; });
        return;
      }

      final supervisorsRaw = await client.rpc('admin_list_supervisors');
      final permissionsRaw = await client.rpc('admin_list_permissions');
      final supervisors = List<Map<String, dynamic>>.from(
        (supervisorsRaw as List).map((r) => Map<String, dynamic>.from(r)));
      final permissions = List<Map<String, dynamic>>.from(
        (permissionsRaw as List).map((r) => Map<String, dynamic>.from(r)));

      var selected = _selectedSupervisor;
      if (selected == null && supervisors.isNotEmpty) {
        selected = supervisors.first['id'].toString();
      }

      Set<int> granted = {};
      if (selected != null) {
        final grantsRaw = await client.rpc('admin_get_user_permissions',
            params: {'target_user': selected});
        granted = (grantsRaw as List)
            .map((r) => (r['permission_id'] as num).toInt()).toSet();
      }

      if (!mounted) return;
      setState(() {
        _isAdmin = true;
        _supervisors = supervisors;
        _permissions = permissions;
        _selectedSupervisor = selected;
        _granted = granted;
        _loading = false;
      });
    } catch (error) {
      debugPrint('WASEL admin permissions error: $error');
      if (!mounted) return;
      setState(() => _loading = false);
      _message('تعذر تحميل الصلاحيات');
    }
  }

  Future<void> _selectSupervisor(String id) async {
    setState(() { _selectedSupervisor = id; _loading = true; });
    final client = SupabaseService.client;
    if (client == null) return;
    try {
      final raw = await client.rpc('admin_get_user_permissions',
          params: {'target_user': id});
      final granted = (raw as List)
          .map((r) => (r['permission_id'] as num).toInt()).toSet();
      if (!mounted) return;
      setState(() { _granted = granted; _loading = false; });
    } catch (error) {
      debugPrint('WASEL supervisor permission load error: $error');
      if (!mounted) return;
      setState(() => _loading = false);
      _message('تعذر تحميل صلاحيات هذا المشرف');
    }
  }

  Future<void> _togglePermission(int permissionId, bool enabled) async {
    final client = SupabaseService.client;
    final supervisor = _selectedSupervisor;
    if (client == null || supervisor == null) return;
    try {
      await client.rpc('admin_set_permission', params: {
        'target_user': supervisor,
        'target_permission': permissionId,
        'enabled': enabled,
      });
      if (!mounted) return;
      setState(() {
        if (enabled) {
          _granted = {..._granted, permissionId};
        } else {
          _granted = {..._granted}..remove(permissionId);
        }
      });
      _message(enabled ? 'تم منح الصلاحية' : 'تم سحب الصلاحية');
    } catch (error) {
      debugPrint('WASEL permission update error: $error');
      _message('تعذر تحديث الصلاحية');
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin && !_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('صلاحيات المشرفين',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: Text('هذه الصفحة متاحة للمدير فقط',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('صلاحيات المشرفين',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.lime))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('اختر المشرف', textAlign: TextAlign.right,
                    style: TextStyle(color: AppColors.lime, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (_supervisors.isEmpty)
                  _emptyCard('لا يوجد مشرفون حالياً. عيّن مستخدماً كمشرف أولاً.')
                else
                  RadioGroup<String>(
                    groupValue: _selectedSupervisor,
                    onChanged: (v) {
                      if (v != null) _selectSupervisor(v);
                    },
                    child: Column(
                      children: [
                        ..._supervisors.map((s) => RadioListTile<String>(
                          value: s['id'].toString(),
                          activeColor: AppColors.lime,
                          tileColor: AppColors.surface,
                          title: Text(s['full_name']?.toString().isNotEmpty == true
                              ? s['full_name'].toString() : 'بدون اسم',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(s['phone']?.toString() ?? '',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white54)),
                        )),
                      ],
                    ),
                  ),
                if (_selectedSupervisor != null) ...[
                  const SizedBox(height: 24),
                  const Text('الصلاحيات', textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.lime, fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (_permissions.isEmpty)
                    _emptyCard('لا توجد صلاحيات معرفة في جدول permissions.')
                  else
                    ..._permissions.map((p) {
                      final id = (p['id'] as num).toInt();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14)),
                        child: SwitchListTile(
                          value: _granted.contains(id),
                          onChanged: (v) => _togglePermission(id, v),
                          activeThumbColor: AppColors.lime,
                          title: Text(p['label_ar']?.toString() ?? p['code'].toString(),
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(p['code'].toString(), textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white38)),
                        ),
                      );
                    }),
                ],
              ],
            ),
    );
  }

  Widget _emptyCard(String text) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.surface,
        borderRadius: BorderRadius.circular(16)),
    child: Text(text, textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.white54, height: 1.6)),
  );
}
