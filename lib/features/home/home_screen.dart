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

  static const _blue = Color(0xFF1769D2);
  static const _blueLight = Color(0xFFEAF3FF);
  static const _text = Color(0xFF172033);
  static const _muted = Color(0xFF737B8C);

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

  List<({IconData icon, String title, String subtitle, String route})>
      get services => [
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
      case 1:
        context.push('/notifications');
        break;
      case 2:
        context.push('/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          AppLocale.isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildLocationBar(),
                    const SizedBox(height: 12),
                    _buildSearchHint(),
                    const SizedBox(height: 20),
                    _buildWelcome(),
                    const SizedBox(height: 16),
                    _buildAnnouncement(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(AppStrings.services),
                    const SizedBox(height: 12),
                    _buildServices(),
                    const SizedBox(height: 24),
                    _buildQuickAction(),
                  ]),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.push('/account'),
            tooltip: AppStrings.account,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F6FA),
            ),
            icon: const Icon(Icons.person_outline, color: _text),
          ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            tooltip: AppStrings.notifications,
            icon: const Icon(Icons.notifications_none, color: _text),
          ),
          const Spacer(),
          Image.asset(
            'assets/images/wasel-logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBar() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, color: _blue, size: 19),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            AppLocale.isEnglish ? 'Khartoum' : 'الخرطوم',
            style: const TextStyle(
              color: _text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Icon(Icons.keyboard_arrow_down, color: _muted, size: 20),
      ],
    );
  }

  Widget _buildSearchHint() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: _muted, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              AppLocale.isEnglish
                  ? 'What are you looking for?'
                  : 'ما الخدمة التي تبحث عنها؟',
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Text(
      AppStrings.homeWelcome,
      style: const TextStyle(
        color: _text,
        fontSize: 25,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildAnnouncement() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _announcementTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _announcementBody,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _text,
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildServices() {
    return SizedBox(
      height: 138,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
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
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 128,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFFE7EBF1)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A172033),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: _blueLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: _blue, size: 23),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction() {
    return Material(
      color: const Color(0xFFF5F8FC),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => context.push('/account'),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE7EBF1)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _blueLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: _blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.needHelp,
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppStrings.teamReady,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: _blueLight,
      elevation: 8,
      selectedIndex: _currentIndex,
      onDestinationSelected: _onNavigationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home, color: _blue),
          label: AppStrings.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.notifications_none),
          selectedIcon: const Icon(Icons.notifications, color: _blue),
          label: AppStrings.notifications,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person, color: _blue),
          label: AppStrings.account,
        ),
      ],
    );
  }
}
