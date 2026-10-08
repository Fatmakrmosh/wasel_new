import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/localization/app_locale.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _announcementTitle = AppStrings.alwaysWithYou;
  String _announcementBody = AppStrings.allInOne;

  @override
  void initState() {
    super.initState();
    _loadAnnouncement();
  }

  Future<void> _loadAnnouncement() async {
    final client = SupabaseService.client;
    if (client == null) return;
    try {
      final rows = await client
          .from('app_settings')
          .select('key,value_text')
          .inFilter('key', ['announcement_title_ar', 'announcement_body_ar']);
      var title = _announcementTitle;
      var body = _announcementBody;
      for (final row in rows as List) {
        final key = row['key']?.toString();
        final value = row['value_text']?.toString().trim() ?? '';
        if (value.isEmpty) continue;
        if (key == 'announcement_title_ar') title = value;
        if (key == 'announcement_body_ar') body = value;
      }
      if (!mounted) return;
      setState(() {
        _announcementTitle = title;
        _announcementBody = body;
      });
    } catch (error) {
      debugPrint('WASEL announcement load error: $error');
    }
  }
  List<({IconData icon, String title, String subtitle, String route})> get services => [
    (
      icon: Icons.location_on_outlined,
      title: AppStrings.cityRides,
      subtitle: AppStrings.requestRide,
      route: '/city-ride',
    ),
    (
      icon: Icons.directions_car_outlined,
      title: AppStrings.intercity,
      subtitle: AppStrings.travelComfortably,
      route: '/intercity',
    ),
    (
      icon: Icons.directions_bus_outlined,
      title: AppStrings.buses,
      subtitle: AppStrings.bookSeat,
      route: '/bus',
    ),
    (
      icon: Icons.inventory_2_outlined,
      title: AppStrings.sendParcel,
      subtitle: AppStrings.sendSafely,
      route: '/send-parcel',
    ),
    (
      icon: Icons.location_searching,
      title: AppStrings.trackParcel,
      subtitle: AppStrings.trackShipment,
      route: '/track-parcel',
    ),
    (
      icon: Icons.history,
      title: AppStrings.myRides,
      subtitle: AppStrings.historyBookings,
      route: '/my-rides',
    ),
  ];

  void _onNavigationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
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
      textDirection: AppLocale.isEnglish ? TextDirection.ltr : TextDirection.rtl,
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
                    'WASEL',
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
            Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilledButton.icon(
                  onPressed: () => context.push('/admin'),
                  icon: const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 19,
                  ),
                  label: Text(AppStrings.admin),
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColors.lime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
                Text(
                  AppStrings.homeWelcome,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.whereToday,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnnouncement(),
                const SizedBox(height: 26),
                Text(
                  AppStrings.services,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _announcementTitle,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _announcementBody,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.needHelp,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppStrings.teamReady,
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
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none),
          selectedIcon: Icon(Icons.notifications),
          label: AppStrings.notifications,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: AppStrings.account,
        ),
      ],
    );
  }
}