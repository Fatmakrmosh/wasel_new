import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _canManage = false;

  @override
  void initState() {
    super.initState();
    _loadManagementAccess();
  }

  Future<void> _loadManagementAccess() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;

    try {
      final row = await client
          .from('profiles')
          .select('role,is_active')
          .eq('id', user.id)
          .maybeSingle();

      final role = row?['role']?.toString();
      final active = row?['is_active'] == true;
      var hasPermission = false;

      if (role == 'supervisor' && active) {
        final grants = await client
            .from('user_permissions')
            .select('permission_id')
            .eq('user_id', user.id)
            .limit(1);
        hasPermission = grants.isNotEmpty;
      }

      if (!mounted) return;
      setState(() {
        _canManage = active && (role == 'admin' || (role == 'supervisor' && hasPermission));
      });
    } catch (_) {
      // Keep the management button hidden if access cannot be verified.
    }
  }

  final services = const [
    (
      icon: Icons.location_on_outlined,
      title: 'رحلات داخل المدينة',
      subtitle: 'اطلب رحلة الآن',
      route: '/city-ride',
    ),
    (
      icon: Icons.directions_car_outlined,
      title: 'ليموزين بين المدن',
      subtitle: 'سافر براحة',
      route: '/intercity',
    ),
    (
      icon: Icons.directions_bus_outlined,
      title: 'باصات وحافلات',
      subtitle: 'احجز مقعدك',
      route: '/bus',
    ),
    (
      icon: Icons.inventory_2_outlined,
      title: 'إرسال طرد',
      subtitle: 'أرسل بأمان',
      route: '/send-parcel',
    ),
    (
      icon: Icons.location_searching,
      title: 'تتبع طرد',
      subtitle: 'تابع شحنتك',
      route: '/track-parcel',
    ),
    (
      icon: Icons.history,
      title: 'رحلاتي',
      subtitle: 'السجل والحجوزات',
      route: '/my-rides',
    ),
  ];

  void _onNavigationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 1:
        context.push('/my-rides');
        break;
      case 2:
        context.push('/send-parcel');
        break;
      case 3:
        context.push('/notifications');
        break;
      case 4:
        context.push('/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.background,
          elevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              Image.asset(
                'assets/images/wasel-logo.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'واصل',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'WASEL',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'الإشعارات',
              onPressed: () => context.push('/notifications'),
              icon: const Icon(Icons.notifications_none),
            ),
            if (_canManage)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextButton.icon(
                  onPressed: () => context.push('/admin'),
                  icon: const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 19,
                  ),
                  label: const Text('الإدارة'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.lime,
                    backgroundColor: AppColors.lime.withValues(alpha: 0.10),
                    side: BorderSide(
                      color: AppColors.lime.withValues(alpha: 0.30),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مرحباً بك 👋',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'إلى أين تريد الذهاب اليوم؟',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnnouncement(),
                const SizedBox(height: 26),
                const Text(
                  'خدمات واصل',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];

                    return _buildServiceCard(
                      icon: service.icon,
                      title: service.title,
                      subtitle: service.subtitle,
                      onTap: () => context.push(service.route),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildQuickAction(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildAnnouncement() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Colors.black,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'واصل معك دائماً',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'رحلات، طرود وسفر بين المدن في مكان واحد',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.lime,
                  size: 25,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => context.push('/account'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.support_agent,
                color: AppColors.lime,
                size: 30,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحتاج إلى مساعدة؟',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'فريق واصل جاهز لمساعدتك',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.lime.withValues(alpha: 0.18),
      selectedIndex: _currentIndex,
      onDestinationSelected: _onNavigationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_car_outlined),
          selectedIcon: Icon(Icons.directions_car),
          label: 'الرحلات',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'الطرود',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none),
          selectedIcon: Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    );
  }
}