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
      final rows = await client.rpc('admin_list_profiles');
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
      await client.rpc('admin_set_profile_role', params: {
        'target_user': user['id'],
        'target_role': role,
      });
      await _loadUsers();
      _message('تم تحديث الصلاحية');
    } catch (_) {
      _message('تعذر تحديث الصلاحية');
    }
  }

  Future<void> _addCompany() async {
    final candidates = _users.where((user) {
      final role = user['role']?.toString().trim().toLowerCase();
      return role != 'admin' && role != 'supervisor' && role != 'company';
    }).toList();

    if (candidates.isEmpty) {
      _message('لا يوجد مستخدم متاح لإضافته كشركة');
      return;
    }

    String? selectedId;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('إضافة شركة',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: DropdownButtonFormField<String>(
            initialValue: selectedId,
            dropdownColor: const Color(0xFF252525),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'اختر المستخدم',
              labelStyle: TextStyle(color: Colors.white54),
            ),
            items: candidates.map((user) {
              final name = user['full_name']?.toString().trim();
              final phone = user['phone']?.toString() ?? '';
              return DropdownMenuItem<String>(
                value: user['id'].toString(),
                child: Text(
                  (name?.isNotEmpty == true ? name! : 'بدون اسم') +
                      (phone.isEmpty ? '' : ' - $phone'),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) => setDialogState(() => selectedId = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: selectedId == null
                  ? null
                  : () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: Colors.black,
              ),
              child: const Text('إضافة شركة'),
            ),
          ],
        ),
      ),
    );

    if (selectedId == null) return;
    await _changeRole(
      _users.firstWhere((u) => u['id'].toString() == selectedId),
      'company',
    );
  }

  Future<void> _removeCompany() async {
    final companies = _filteredUsers;
    if (companies.isEmpty) {
      _message('لا توجد شركات مسجلة حالياً');
      return;
    }

    String? selectedId;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('إزالة شركة',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: DropdownButtonFormField<String>(
            initialValue: selectedId,
            dropdownColor: const Color(0xFF252525),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'اختر الشركة',
              labelStyle: TextStyle(color: Colors.white54),
            ),
            items: companies.map((user) => DropdownMenuItem<String>(
              value: user['id'].toString(),
              child: Text(
                user['full_name']?.toString().isNotEmpty == true
                    ? user['full_name'].toString()
                    : 'بدون اسم',
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
            onChanged: (value) => setDialogState(() => selectedId = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: selectedId == null
                  ? null
                  : () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('إزالة'),
            ),
          ],
        ),
      ),
    );

    if (selectedId == null) return;
    await _changeRole(
      _users.firstWhere((u) => u['id'].toString() == selectedId),
      'passenger',
    );
  }

  void _showUser(Map<String, dynamic> user) {
    final role = user['role']?.toString() ?? 'passenger';
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
            const SizedBox(height: 10),
            const Text(
              'حالة التفعيل ستُضاف عند اعتماد حقل حالة الحساب في قاعدة البيانات.',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right)),
    );
  }

  String get _screenTitle {
    switch (_filter) {
      case 'driver': return 'إدارة السائقين';
      case 'company': return 'الشركات المسجلة';
      case 'supervisor': return 'المشرفون';
      case 'admin': return 'المديرون';
      case 'passenger': return 'المستخدمون';
      default: return 'المستخدمون المسجلون';
    }
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

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(_screenTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  if (_filter == 'company') ...[
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _addCompany,
                            icon: const Icon(Icons.business_rounded),
                            label: const Text('إضافة شركة'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.lime,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _removeCompany,
                            icon: const Icon(Icons.business_center_outlined),
                            label: const Text('إزالة شركة'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
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
                        '${user['phone']?.toString() ?? ''} • ${_roleLabel(user['role'])}',
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
