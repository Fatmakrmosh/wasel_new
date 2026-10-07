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
      final current = client.auth.currentUser;
      if (current == null) return;
      final profile = await client.from('profiles').select('role,is_active').eq('id', current.id).maybeSingle();
      final isAdmin = profile?['role']?.toString() == 'admin' && profile?['is_active'] == true;
      if (!isAdmin) {
        if (mounted) {
          setState(() { _isAdmin = false; _loading = false; });
        }
        return;
      }

      final supervisors = await client.from('profiles').select('id,full_name,phone,is_active,created_at')
          .eq('role', 'supervisor').order('created_at', ascending: false);
      final permissions = await client.from('permissions').select('id,code,label_ar').order('id');
      final grants = _selectedSupervisor == null
          ? const <Map<String, dynamic>>[]
          : await client.from('user_permissions').select('permission_id').eq('user_id', _selectedSupervisor!);
      if (!mounted) return;
      setState(() {
        _isAdmin = true;
        _supervisors = List<Map<String, dynamic>>.from(supervisors);
        _permissions = List<Map<String, dynamic>>.from(permissions);
        _granted = grants.map<int>((row) => (row['permission_id'] as num).toInt()).toSet();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('تعذر تحميل الصلاحيات');
    }
  }

  Future<void> _selectSupervisor(String id) async {
    setState(() => _selectedSupervisor = id);
    await _load();
  }

  Future<void> _togglePermission(int permissionId, bool enabled) async {
    final client = SupabaseService.client;
    final supervisor = _selectedSupervisor;
    if (client == null || supervisor == null) return;
    try {
      if (enabled) {
        await client.from('user_permissions').upsert({'user_id': supervisor, 'permission_id': permissionId});
      } else {
        await client.from('user_permissions').delete().eq('user_id', supervisor).eq('permission_id', permissionId);
      }
      setState(() {
        if (enabled) { _granted = {..._granted, permissionId}; }
        else { _granted = {..._granted}..remove(permissionId); }
      });
    } catch (_) {
      _message('تعذر تحديث الصلاحية');
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, textAlign: TextAlign.right)));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _supervisors.where((s) => s['id'] == _selectedSupervisor);
    final selectedName = selected.isEmpty ? null : (selected.first['full_name']?.toString().isNotEmpty == true
        ? selected.first['full_name'].toString() : selected.first['phone']?.toString());

    if (!_isAdmin && !_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('صلاحيات المشرفين', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: Text(
            'هذه الصفحة متاحة للمدير فقط',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('صلاحيات المشرفين', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white))],
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
                  ..._supervisors.map((s) => RadioListTile<String>(
                    value: s['id'].toString(),
                    groupValue: _selectedSupervisor,
                    onChanged: (v) { if (v != null) _selectSupervisor(v); },
                    activeColor: AppColors.lime,
                    tileColor: AppColors.surface,
                    title: Text(s['full_name']?.toString().isNotEmpty == true ? s['full_name'].toString() : 'بدون اسم',
                        textAlign: TextAlign.right, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(s['phone']?.toString() ?? '', textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white54)),
                  )),
                if (selectedName != null) ...[
                  const SizedBox(height: 24),
                  Text('صلاحيات ' + selectedName.toString(), textAlign: TextAlign.right,
                      style: const TextStyle(color: AppColors.lime, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ..._permissions.map((p) {
                    final id = (p['id'] as num).toInt();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                      child: SwitchListTile(
                        value: _granted.contains(id),
                        onChanged: (v) => _togglePermission(id, v),
                        activeThumbColor: AppColors.lime,
                        title: Text(p['label_ar']?.toString() ?? p['code'].toString(),
                            textAlign: TextAlign.right, style: const TextStyle(color: Colors.white)),
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
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
    child: Text(text, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white54, height: 1.6)),
  );
}
