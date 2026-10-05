import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  bool isActive = true;

  final List<Map<String, dynamic>> upcomingTrips = [
    {
      'route': 'الخرطوم → شندي',
      'date': 'اليوم',
      'time': '08:00 صباحًا',
      'vehicle': 'باص 32 راكب',
      'bookings': '24 / 32',
      'status': 'مؤكد',
    },
    {
      'route': 'الخرطوم → عطبرة',
      'date': 'غدًا',
      'time': '07:30 صباحًا',
      'vehicle': 'باص 45 راكب',
      'bookings': '31 / 45',
      'status': 'متاح',
    },
    {
      'route': 'بحري → بورتسودان',
      'date': 'الخميس',
      'time': '06:00 صباحًا',
      'vehicle': 'حافلة 28 راكب',
      'bookings': '18 / 28',
      'status': 'متاح',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'لوحة الشركة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => context.push('/account'),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFA3E635),
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () async {
            await Future<void>.delayed(
              const Duration(milliseconds: 500),
            );

            if (mounted) {
              setState(() {});
            }
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _buildCompanyHeader(),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('ملخص الشركة'),
              const SizedBox(height: 12),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('الوصول السريع'),
              const SizedBox(height: 12),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'الرحلات القادمة',
                actionText: 'عرض الكل',
                onAction: _showAllTrips,
              ),
              const SizedBox(height: 12),
              ...upcomingTrips
                  .take(3)
                  .map((trip) => _buildTripCard(trip)),
              const SizedBox(height: 24),
              _buildSectionTitle('حالة التشغيل'),
              const SizedBox(height: 12),
              _buildOperationSummary(),
              const SizedBox(height: 24),
              _buildSectionTitle('تنبيهات الشركة'),
              const SizedBox(height: 12),
              _buildAlerts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA3E635).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFA3E635).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.business_rounded,
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
                  'شركة واصل للنقل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'الخرطوم • شركة نقل معتمدة',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFFA3E635),
                      size: 15,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'حساب موثق',
                      style: TextStyle(
                        color: Color(0xFFA3E635),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1B2612)
            : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? const Color(0xFFA3E635).withValues(alpha: 0.30)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFA3E635).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive
                  ? Icons.power_settings_new_rounded
                  : Icons.pause_circle_outline_rounded,
              color: isActive
                  ? const Color(0xFFA3E635)
                  : Colors.white54,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'الشركة تعمل الآن' : 'الشركة متوقفة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive
                      ? 'يمكن للعملاء حجز الرحلات المتاحة'
                      : 'لن تظهر الرحلات الجديدة للعملاء',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeThumbColor: const Color(0xFFA3E635),
            activeTrackColor:
                const Color(0xFFA3E635).withValues(alpha: 0.30),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
            onChanged: (value) {
              setState(() {
                isActive = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: const TextStyle(
                color: Color(0xFFA3E635),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.60,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          icon: Icons.route_rounded,
          title: 'الرحلات',
          value: '38',
          suffix: 'هذا الشهر',
        ),
        _buildStatCard(
          icon: Icons.event_seat_outlined,
          title: 'الحجوزات',
          value: '684',
          suffix: 'راكب',
        ),
        _buildStatCard(
          icon: Icons.directions_bus_outlined,
          title: 'المركبات',
          value: '12',
          suffix: 'مركبة',
        ),
        _buildStatCard(
          icon: Icons.payments_outlined,
          title: 'الإيرادات',
          value: '4.8M',
          suffix: 'جنيه',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFA3E635),
                size: 20,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 10,
      childAspectRatio: 0.88,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildQuickAction(
          Icons.directions_bus_outlined,
          'المركبات',
          _showVehicles,
        ),
        _buildQuickAction(
          Icons.people_outline_rounded,
          'السائقون',
          _showDrivers,
        ),
        _buildQuickAction(
          Icons.route_outlined,
          'الرحلات',
          () => context.push('/intercity'),
        ),
        _buildQuickAction(
          Icons.account_balance_wallet_outlined,
          'الإيرادات',
          _showRevenue,
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFFA3E635),
              size: 25,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final bool confirmed = trip['status'] == 'مؤكد';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: confirmed
                      ? const Color(0xFFA3E635).withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip['status'] as String,
                  style: TextStyle(
                    color: confirmed
                        ? const Color(0xFFA3E635)
                        : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                trip['date'] as String,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFA3E635).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Color(0xFFA3E635),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip['route'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${trip['time']} • ${trip['vehicle']}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_seat_outlined,
                  color: Colors.white54,
                  size: 17,
                ),
                const SizedBox(width: 7),
                const Text(
                  'الحجوزات',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  trip['bookings'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: () => _showTripDetails(trip),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFA3E635),
                side: BorderSide(
                  color: const Color(0xFFA3E635).withValues(alpha: 0.50),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'إدارة الرحلة',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationSummary() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _buildOperationRow(
            'المركبات العاملة',
            '9 من 12',
            0.75,
            Icons.directions_bus_outlined,
          ),
          const SizedBox(height: 18),
          _buildOperationRow(
            'السائقون المتاحون',
            '16 من 20',
            0.80,
            Icons.people_outline_rounded,
          ),
          const SizedBox(height: 18),
          _buildOperationRow(
            'نسبة إشغال المقاعد',
            '78%',
            0.78,
            Icons.event_seat_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationRow(
    String title,
    String value,
    double progress,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFA3E635),
              size: 19,
            ),
            const SizedBox(width: 8),
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
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white12,
            color: const Color(0xFFA3E635),
          ),
        ),
      ],
    );
  }

  Widget _buildAlerts() {
    return Column(
      children: [
        _buildAlertCard(
          icon: Icons.warning_amber_rounded,
          title: 'مركبتان تحتاجان إلى تحديث المستندات',
          subtitle: 'يرجى مراجعة بيانات المركبات',
          iconColor: Colors.orange,
        ),
        const SizedBox(height: 10),
        _buildAlertCard(
          icon: Icons.event_available_outlined,
          title: 'رحلة الخرطوم - عطبرة تقترب من الامتلاء',
          subtitle: '31 من أصل 45 مقعدًا محجوز',
          iconColor: const Color(0xFFA3E635),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 20),
                const Text(
                  'إدارة الرحلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  Icons.route_rounded,
                  'المسار',
                  trip['route'] as String,
                ),
                _buildDetailRow(
                  Icons.calendar_today_outlined,
                  'التاريخ',
                  trip['date'] as String,
                ),
                _buildDetailRow(
                  Icons.access_time_rounded,
                  'الوقت',
                  trip['time'] as String,
                ),
                _buildDetailRow(
                  Icons.directions_bus_outlined,
                  'المركبة',
                  trip['vehicle'] as String,
                ),
                _buildDetailRow(
                  Icons.event_seat_outlined,
                  'الحجوزات',
                  trip['bookings'] as String,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessage('تم فتح إدارة الرحلة.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3E635),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'فتح إدارة الرحلة',
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

  Widget _buildSheetHandle() {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFA3E635),
            size: 20,
          ),
          const SizedBox(width: 11),
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicles() {
    _showSimpleListSheet(
      title: 'مركبات الشركة',
      items: [
        'باص 32 راكب — شغال',
        'باص 45 راكب — شغال',
        'حافلة 28 راكب — شغال',
        'باص 30 راكب — في الصيانة',
        'حافلة 24 راكب — شغال',
      ],
      icon: Icons.directions_bus_outlined,
    );
  }

  void _showDrivers() {
    _showSimpleListSheet(
      title: 'سائقو الشركة',
      items: [
        'محمد أحمد — متاح',
        'عبدالله حسن — في رحلة',
        'أحمد محمد — متاح',
        'عثمان علي — غير متاح',
        'مصطفى حسن — في رحلة',
      ],
      icon: Icons.person_outline_rounded,
    );
  }

  void _showRevenue() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ملخص الإيرادات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                _buildRevenueRow('اليوم', '186,000 جنيه'),
                _buildRevenueRow('هذا الأسبوع', '1,240,000 جنيه'),
                _buildRevenueRow('هذا الشهر', '4,800,000 جنيه'),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFA3E635),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSimpleListSheet({
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ...items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: const Color(0xFFA3E635),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
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

  void _showAllTrips() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.82,
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildSheetHandle(),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'جميع الرحلات القادمة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: upcomingTrips
                        .map((trip) => _buildTripCard(trip))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
        backgroundColor: const Color(0xFFA3E635),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}