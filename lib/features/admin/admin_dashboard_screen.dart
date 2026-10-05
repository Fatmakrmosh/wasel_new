import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _systemOnline = true;
  bool _maintenanceMode = false;

  final List<_AdminStat> _stats = const [
    _AdminStat(
      title: 'المستخدمون',
      value: '12,480',
      icon: Icons.people_alt_outlined,
    ),
    _AdminStat(
      title: 'السائقون',
      value: '1,248',
      icon: Icons.drive_eta_outlined,
    ),
    _AdminStat(
      title: 'الشركات',
      value: '86',
      icon: Icons.business_outlined,
    ),
    _AdminStat(
      title: 'رحلات اليوم',
      value: '426',
      icon: Icons.route_outlined,
    ),
    _AdminStat(
      title: 'الطرود',
      value: '183',
      icon: Icons.inventory_2_outlined,
    ),
    _AdminStat(
      title: 'إيرادات اليوم',
      value: '2.84M',
      icon: Icons.payments_outlined,
    ),
  ];

  final List<_AdminAction> _actions = const [
    _AdminAction(
      title: 'المستخدمون',
      subtitle: 'إدارة الحسابات',
      icon: Icons.people_alt_outlined,
    ),
    _AdminAction(
      title: 'السائقون',
      subtitle: 'المراجعة والتوثيق',
      icon: Icons.drive_eta_outlined,
    ),
    _AdminAction(
      title: 'الشركات',
      subtitle: 'إدارة شركات النقل',
      icon: Icons.business_outlined,
    ),
    _AdminAction(
      title: 'الإعلانات',
      subtitle: 'إدارة واجهة التطبيق',
      icon: Icons.campaign_outlined,
    ),
    _AdminAction(
      title: 'الطرود',
      subtitle: 'متابعة الشحنات',
      icon: Icons.inventory_2_outlined,
    ),
    _AdminAction(
      title: 'المالية',
      subtitle: 'الإيرادات والعمولات',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _AdminAction(
      title: 'المركبات',
      subtitle: 'إدارة المركبات',
      icon: Icons.directions_car_outlined,
    ),
    _AdminAction(
      title: 'الإعدادات',
      subtitle: 'إعدادات النظام',
      icon: Icons.settings_outlined,
    ),
  ];

  final List<_ApprovalItem> _approvals = const [
    _ApprovalItem(
      title: 'طلبات تسجيل سائقين',
      count: '18',
      icon: Icons.person_add_alt_1_outlined,
    ),
    _ApprovalItem(
      title: 'طلبات شركات النقل',
      count: '4',
      icon: Icons.business_center_outlined,
    ),
    _ApprovalItem(
      title: 'وثائق تحتاج مراجعة',
      count: '11',
      icon: Icons.description_outlined,
    ),
  ];

  final List<_RideItem> _recentRides = const [
    _RideItem(
      id: 'WAS-R-10254',
      passenger: 'محمد أحمد',
      driver: 'عبدالله حسن',
      route: 'الخرطوم → بحري',
      price: '4,000 جنيه',
      status: 'مكتملة',
    ),
    _RideItem(
      id: 'WAS-R-10253',
      passenger: 'أحمد علي',
      driver: 'محمد عثمان',
      route: 'أم درمان → الخرطوم',
      price: '5,500 جنيه',
      status: 'جارية',
    ),
    _RideItem(
      id: 'WAS-R-10252',
      passenger: 'سارة محمد',
      driver: 'أحمد حسن',
      route: 'بحري → أم درمان',
      price: '3,500 جنيه',
      status: 'مكتملة',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'لوحة الإدارة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () => context.push('/notifications'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA3E635),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFA3E635),
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () async {
            await Future<void>.delayed(
              const Duration(milliseconds: 700),
            );
            if (!mounted) return;
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _buildAdminHeader(),
              const SizedBox(height: 16),
              _buildSystemStatus(),
              const SizedBox(height: 20),
              _buildSectionTitle('الإحصائيات العامة'),
              const SizedBox(height: 12),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('إجراءات سريعة'),
              const SizedBox(height: 12),
              _buildActionsGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('طلبات تحتاج مراجعة'),
              const SizedBox(height: 12),
              _buildApprovals(),
              const SizedBox(height: 24),
              _buildSectionTitle('آخر الرحلات'),
              const SizedBox(height: 12),
              _buildRecentRides(),
              const SizedBox(height: 24),
              _buildParcelSummary(),
              const SizedBox(height: 24),
              _buildAdvertisementManager(),
              const SizedBox(height: 24),
              _buildSystemControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFA3E635).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFA3E635).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Color(0xFFA3E635),
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك، مدير النظام',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'إدارة ومتابعة منصة WASEL',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/account'),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _systemOnline
            ? const Color(0xFF17200F)
            : const Color(0xFF261414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _systemOnline
              ? const Color(0xFFA3E635).withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _systemOnline
                ? Icons.check_circle_outline
                : Icons.error_outline,
            color: _systemOnline
                ? const Color(0xFFA3E635)
                : Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _systemOnline ? 'النظام يعمل بشكل طبيعي' : 'النظام غير متاح',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _maintenanceMode
                      ? 'وضع الصيانة مفعل حالياً'
                      : 'جميع الخدمات الأساسية تعمل',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _systemOnline,
            activeThumbColor: const Color(0xFFA3E635),
            onChanged: (value) {
              setState(() {
                _systemOnline = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFA3E635),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final stat = _stats[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    stat.icon,
                    color: const Color(0xFFA3E635),
                    size: 21,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white38,
                    size: 17,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                stat.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                stat.title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.45,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showActionSheet(action.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3E635).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: const Color(0xFFA3E635),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        action.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovals() {
    return Column(
      children: _approvals.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pending_actions_outlined,
                color: Colors.orangeAccent,
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'اضغط للمراجعة واتخاذ الإجراء',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.count,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showApprovalSheet(item.title),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentRides() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: _recentRides.asMap().entries.map((entry) {
          final index = entry.key;
          final ride = entry.value;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                leading: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3E635).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.route_outlined,
                    color: Color(0xFFA3E635),
                  ),
                ),
                title: Text(
                  ride.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '${ride.route}\n${ride.passenger} • ${ride.driver}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ride.price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _statusChip(ride.status),
                  ],
                ),
                onTap: () => _showRideDetails(ride),
              ),
              if (index < _recentRides.length - 1)
                Divider(
                  height: 1,
                  indent: 70,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _statusChip(String status) {
    final bool active = status == 'جارية';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: active
            ? Colors.orange.withValues(alpha: 0.12)
            : const Color(0xFFA3E635).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: active
              ? Colors.orangeAccent
              : const Color(0xFFA3E635),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParcelSummary() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFFA3E635),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'حالة الطرود',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/track-parcel'),
                child: const Text(
                  'التتبع',
                  style: TextStyle(
                    color: Color(0xFFA3E635),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _parcelProgress('قيد الاستلام', 32, 183),
          _parcelProgress('قيد النقل', 71, 183),
          _parcelProgress('تم التسليم', 80, 183),
        ],
      ),
    );
  }

  Widget _parcelProgress(
    String title,
    int value,
    int total,
  ) {
    final progress = value / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFA3E635),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementManager() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFA3E635).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.campaign_outlined,
                color: Color(0xFFA3E635),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'إعلان الصفحة الرئيسية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showAdvertisementSheet(),
                child: const Text(
                  'إدارة',
                  style: TextStyle(
                    color: Color(0xFFA3E635),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 105,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFA3E635).withValues(alpha: 0.22),
                  const Color(0xFF1C1C1C),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFA3E635).withValues(alpha: 0.15),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    color: Color(0xFFA3E635),
                    size: 32,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خصم على الرحلات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'إعلان تجريبي يتم التحكم فيه من الإدارة',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemControls() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.tune_outlined,
                color: Color(0xFFA3E635),
              ),
              SizedBox(width: 9),
              Text(
                'تحكم النظام',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'وضع الصيانة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'إيقاف الخدمات مؤقتاً للصيانة',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
            value: _maintenanceMode,
            activeThumbColor: const Color(0xFFA3E635),
            onChanged: (value) {
              setState(() {
                _maintenanceMode = value;
              });
            },
          ),
          const Divider(color: Colors.white10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'مركز الإشعارات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_left,
              color: Colors.white38,
            ),
            onTap: () => context.push('/notifications'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.settings_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'إعدادات الحساب',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_left,
              color: Colors.white38,
            ),
            onTap: () => context.push('/account'),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(String title) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Color(0xFFA3E635),
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'هذه الواجهة جاهزة للربط مع نظام الإدارة وقاعدة البيانات.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3E635),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'تم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApprovalSheet(String title) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'سيتم عرض الطلبات والوثائق هنا بعد ربط لوحة الإدارة بقاعدة البيانات.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3E635),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRideDetails(_RideItem ride) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'تفاصيل الرحلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                _detailRow('رقم الرحلة', ride.id),
                _detailRow('الراكب', ride.passenger),
                _detailRow('السائق', ride.driver),
                _detailRow('المسار', ride.route),
                _detailRow('المبلغ', ride.price),
                _detailRow('الحالة', ride.status),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvertisementSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'إدارة الإعلان',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'عنوان الإعلان',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF252525),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'نص الإعلان',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF252525),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3E635),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'حفظ الإعلان',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminStat {
  final String title;
  final String value;
  final IconData icon;

  const _AdminStat({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _AdminAction {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AdminAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _ApprovalItem {
  final String title;
  final String count;
  final IconData icon;

  const _ApprovalItem({
    required this.title,
    required this.count,
    required this.icon,
  });
}

class _RideItem {
  final String id;
  final String passenger;
  final String driver;
  final String route;
  final String price;
  final String status;

  const _RideItem({
    required this.id,
    required this.passenger,
    required this.driver,
    required this.route,
    required this.price,
    required this.status,
  });
}