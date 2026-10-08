import 'package:flutter/material.dart';

import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() => _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final client = SupabaseService.client;
    if (client == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final rows = await client
          .from('app_settings')
          .select('key,value_text')
          .inFilter('key', ['announcement_title_ar', 'announcement_body_ar']);
      for (final row in rows as List) {
        final key = row['key']?.toString();
        final value = row['value_text']?.toString() ?? '';
        if (key == 'announcement_title_ar') _titleController.text = value;
        if (key == 'announcement_body_ar') _bodyController.text = value;
      }
    } catch (error) {
      debugPrint('WASEL announcement load error: $error');
      _message('تعذر تحميل الإعلان. تأكد من تطبيق تحديث قاعدة البيانات.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final client = SupabaseService.client;
    if (client == null) return;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      _message('اكتب عنوان الإعلان ونصه أولاً');
      return;
    }

    setState(() => _saving = true);
    try {
      await client.rpc('admin_update_app_setting', params: {
        'setting_key': 'announcement_title_ar',
        'setting_value': title,
      });
      await client.rpc('admin_update_app_setting', params: {
        'setting_key': 'announcement_body_ar',
        'setting_value': body,
      });
      _message('تم تحديث الإعلان');
    } catch (error) {
      debugPrint('WASEL announcement save error: $error');
      _message('تعذر حفظ الإعلان. تأكد من تطبيق تحديث قاعدة البيانات.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, textAlign: TextAlign.right)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('إدارة الإعلان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.lime))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('الإعلان الظاهر في الصفحة الرئيسية', textAlign: TextAlign.right,
                    style: TextStyle(color: AppColors.lime, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'عنوان الإعلان'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyController,
                  textAlign: TextAlign.right,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'نص الإعلان'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'جاري الحفظ...' : 'حفظ الإعلان'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: Colors.black),
                ),
              ],
            ),
    );
  }
}
