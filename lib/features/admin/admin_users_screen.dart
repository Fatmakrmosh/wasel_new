import 'package:flutter/material.dart';

import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  final String initialFilter;

  const AdminUsersScreen({super.key, this.initialFilter = 'all'});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _loading = true;
  String _filter = 'all';
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final client = SupabaseService.client;
    if (client == null) return;
    setState(() => _loading = true);
    try {
      final rows = await client.from('profiles').select(
        'id,full_name,phone,role',
      );
      if (!mounted) return;
      setState(() {
        _users = List<Map<String, dynamic>>.from(rows);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('تعذر تحميل المستخدمين');
    }
  }

  List<Map<String, dynamic>> get _filteredUsers =>
      _filter == 'all' ? _users : _users.where((u) => u['role'] == _filter).toList();

  Future<bool> _isCurrentUserAdmin() async {
    final client = SupabaseService.client;
    if (client == null) return false;
    try {
      final role = await client.rpc('get_my_role');
      return role?.toString().trim().toLowerCase() == 'admin';
    } catch (_) {
      return false;
    }
  }

  Future<void> _setActive(Map<String, dynamic> user, bool active) async {
    final client = SupabaseService.client;
    if (client == null) return;
    if (!await _isCurrentUserAdmin()) {
      _message('تفعيل وإيقاف الحسابات من صلاحيات المدير فقط');
      return;
    }
    try {
      // profiles currently has no is_active column, so activation is not
      // exposed until that field is added to the database schema.
      _message('حالة التفعيل غير مضافة لجدول الحسابات حالياً');
    } catch (_) {
      _message('تعذر تحديث حالة الحساب');
    }
  }

  Future<void> _changeRole(Map<String, dynamic> user, String role) async {
    if (!await _isCurrentUserAdmin()) {
      _message('تغيير الأدوار وصلاحيات المشرفين من صلاحيات المدير فقط');
      return;
    }
    if (user['role'] == 'admin' && role != 'admin') {
      _message('لا تغيّر حساب المدير الرئيسي من هذه الشاشة');
      return;
    }
    final client = SupabaseService.client;
    if (client == null) return;
    try {
      await client.from('profiles').update({'role': role}).eq('id', user['id']);
      await _loadUsers();
      _message('تم تحديث الصلاحية');
    } catch (_) {
      _message('تعذر تحديث الصلاحية');
    }
  }

  void _showUser(Map<String, dynamic> user) {
    final role = user['role']?.toString() ?? 'passenger';
    const active = true;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              user['full_name']?.toString().isNotEmpty == true
                  ? user['full_name'].toString() : 'بدون اسم',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user['phone']?.toString() ?? '', textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 18),
            _infoRow('الدور الحالي', _roleLabel(role)),
            _infoRow('الحالة', 'الحساب موجود'),

            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: role,
              dropdownColor: const Color(0xFF252525),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'الدور', labelStyle: TextStyle(color: Colors.white54)),
              items: const [
                DropdownMenuItem(value: 'passenger', child: Text('مستخدم')),
                DropdownMenuItem(value: 'driver', child: Text('سائق')),
                DropdownMenuItem(value: 'company', child: Text('شركة')),
                DropdownMenuItem(value: 'supervisor', child: Text('مشرف')),
                DropdownMenuItem(value: 'admin', child: Text('مدير')),
              ],
              onChanged: role == 'admin' ? null : (value) {
                if (value == null) return;
                Navigator.pop(sheetContext);
                _changeRole(user, value);
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                _setActive(user, !active);
              },
              icon: Icon(active ? Icons.block_outlined : Icons.check_circle_outline,
                  color: active ? Colors.redAccent : AppColors.lime),
              label: Text(active ? 'إيقاف الحساب' : 'تفعيل الحساب',
                  style: TextStyle(color: active ? Colors.redAccent : AppColors.lime)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Expanded(child: Text(value, textAlign: TextAlign.left, style: const TextStyle(color: Colors.white))),
      Text(title, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white54)),
    ]),
  );

  String _roleLabel(dynamic value) {
    switch (value?.toString()) {
      case 'admin': return 'مدير';
      case 'supervisor': return 'مشرف';
      case 'driver': return 'سائق';
      case 'company': return 'شركة';
      default: return 'مستخدم';
    }
  }

  String _typeLabel(dynamic value) {
    switch (value?.toString()) {
      case 'driver': return 'طلب سائق';
      case 'company': return 'طلب شركة';
      default: return 'مستخدم';
    }
  }

  Widget _chip(String value, String label) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppColors.lime,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(color: selected ? Colors.black : Colors.white70, fontWeight: FontWeight.w600),
    );
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, textAlign: TextAlign.right)));
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('إدارة المستخدمين', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _loadUsers, icon: const Icon(Icons.refresh_rounded, color: Colors.white))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.lime))
          : RefreshIndicator(
              onRefresh: _loadUsers,
              color: AppColors.lime,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _chip('all', 'الكل'), _chip('passenger', 'المستخدمون'),
                    _chip('driver', 'السائقون'), _chip('company', 'الشركات'),
                    _chip('supervisor', 'المشرفون'), _chip('admin', 'المديرون'),
                  ]),
                  const SizedBox(height: 18),
                  Text('النتائج: ' + users.length.toString(), textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 10),
                  ...users.map((user) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                    child: ListTile(
                      onTap: () => _showUser(user),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.lime.withValues(alpha: 0.12),
                        child: const Icon(Icons.person_outline_rounded, color: AppColors.lime),
                      ),
                      title: Text(
                        user['full_name']?.toString().isNotEmpty == true ? user['full_name'].toString() : 'بدون اسم',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        (user['phone']?.toString() ?? '') + ' • ' + _roleLabel(user['role']),
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: const Icon(Icons.chevron_left_rounded, color: Colors.white30),
                    ),
                  )),
                ],
              ),
            ),
    );
  }
}
