import 'package:flutter/material.dart';

import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class AdminRidesScreen extends StatefulWidget {
  const AdminRidesScreen({super.key});

  @override
  State<AdminRidesScreen> createState() => _AdminRidesScreenState();
}

class _AdminRidesScreenState extends State<AdminRidesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rides = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = SupabaseService.client;
    if (client == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final role = await client.rpc('get_my_role');
      final normalizedRole = role?.toString().trim().toLowerCase();
      if (normalizedRole == 'admin') {
        // Full access.
      } else if (normalizedRole == 'supervisor') {
        final allowed = await client.rpc('has_permission', params: {
          'permission_code': 'monitor_rides',
        });
        if (allowed != true) {
          throw Exception('not authorized');
        }
      } else {
        throw Exception('not authorized');
      }

      final rows = await client
          .from('rides')
          .select('id,driver_id,status,updated_at')
          .order('updated_at', ascending: false)
          .limit(100);

      if (!mounted) return;
      setState(() {
        _rides = List<Map<String, dynamic>>.from(rows);
        _loading = false;
      });
    } catch (error) {
      debugPrint('WASEL admin rides error: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل الرحلات. تأكد من صلاحية الوصول إلى جدول الرحلات.';
      });
    }
  }

  String _statusLabel(dynamic value) {
    switch (value?.toString()) {
      case 'accepted':
        return 'مقبولة';
      case 'driver_arriving':
        return 'السائق في الطريق';
      case 'in_progress':
        return 'جارية';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغاة';
      case 'pending':
        return 'بانتظار السائق';
      default:
        return value?.toString() ?? 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'الرحلات والمتابعة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lime),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.lime,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    _messageCard(_error!)
                  else if (_rides.isEmpty)
                    _messageCard('لا توجد رحلات مسجلة حالياً.')
                  else
                    ..._rides.map(
                      (ride) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'رحلة #\${ride['id']}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الحالة: \${_statusLabel(ride['status'])}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: AppColors.lime),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'السائق: \${ride['driver_id']?.toString() ?? 'غير محدد'}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'آخر تحديث: \${ride['updated_at']?.toString() ?? 'غير متوفر'}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _messageCard(String message) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white54, height: 1.6),
        ),
      );
}
