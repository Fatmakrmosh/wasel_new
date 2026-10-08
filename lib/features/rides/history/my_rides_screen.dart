import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_text.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _rides = [
    {
      'status': 'مكتملة',
      'statusColor': AppColors.lime,
      'from': 'الخرطوم',
      'to': 'بحري',
      'date': 'اليوم',
      'time': '10:30 ص',
      'driver': 'محمد أحمد',
      'vehicle': 'Toyota Corolla',
      'price': '4,000 جنيه',
      'id': 'WAS-R-10254',
      'rating': '5.0',
    },
    {
      'status': 'قادمة',
      'statusColor': Colors.orange,
      'from': 'أم درمان',
      'to': 'الخرطوم',
      'date': 'غداً',
      'time': '08:00 ص',
      'driver': 'عبدالله حسن',
      'vehicle': 'Hyundai Accent',
      'price': '5,500 جنيه',
      'id': 'WAS-R-10261',
      'rating': '-',
    },
    {
      'status': 'ملغاة',
      'statusColor': Colors.redAccent,
      'from': 'بحري',
      'to': 'أم درمان',
      'date': '28 سبتمبر',
      'time': '06:45 م',
      'driver': 'أحمد محمد',
      'vehicle': 'Kia Rio',
      'price': '3,500 جنيه',
      'id': 'WAS-R-10198',
      'rating': '-',
    },
  ];

  List<Map<String, dynamic>> get _filteredRides {
    if (_selectedTab == 0) {
      return _rides;
    }

    if (_selectedTab == 1) {
      return _rides
          .where((ride) => ride['status'] == 'قادمة')
          .toList();
    }

    return _rides
        .where((ride) => ride['status'] == 'مكتملة')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            AppText.t('رحلاتي'),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildTabs(),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredRides.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          30,
                        ),
                        itemCount: _filteredRides.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _buildRideCard(
                            _filteredRides[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: AppColors.lime,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.t('رحلاتك'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  AppText.t('تابع رحلاتك السابقة والقادمة بسهولة'),
                  style: TextStyle(
                    color: Colors.white54,
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

  Widget _buildTabs() {
    final tabs = ['الكل', 'القادمة', 'المكتملة'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: List.generate(
            tabs.length,
            (index) => Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: _selectedTab == index
                        ? AppColors.lime
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppText.t(tabs[index]),
                    style: TextStyle(
                      color: _selectedTab == index
                          ? Colors.black
                          : Colors.white60,
                      fontSize: 13,
                      fontWeight: _selectedTab == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride) {
    final Color statusColor = ride['statusColor'] as Color;

    return GestureDetector(
      onTap: () => _showRideDetails(ride),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ride['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  ride['id'],
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            _buildRoute(
              from: ride['from'],
              to: ride['to'],
            ),
            const SizedBox(height: 16),
            const Divider(
              color: Colors.white10,
              height: 1,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Text(
                  ride['date'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Text(
                  ride['time'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  ride['price'],
                  style: const TextStyle(
                    color: AppColors.lime,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF303030),
                  child: Icon(
                    Icons.person,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride['driver'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ride['vehicle'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (ride['rating'] != '-')
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ride['rating'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_left,
                  color: Colors.white38,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoute({
    required String from,
    required String to,
  }) {
    return Row(
      children: [
        Column(
          children: [
            const Icon(
              Icons.radio_button_checked,
              color: AppColors.lime,
              size: 18,
            ),
            Container(
              width: 1,
              height: 28,
              color: Colors.white24,
            ),
            const Icon(
              Icons.location_on,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 23),
              Text(
                to,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.directions_car_outlined,
          color: Colors.white38,
          size: 25,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    String message = 'لا توجد رحلات';

    if (_selectedTab == 1) {
      message = 'لا توجد رحلات قادمة';
    } else if (_selectedTab == 2) {
      message = 'لا توجد رحلات مكتملة';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                color: AppColors.lime,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ستظهر رحلاتك هنا عند توفرها.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRideDetails(Map<String, dynamic> ride) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تفاصيل الرحلة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _detailLine('رقم الرحلة', ride['id']),
                  _detailLine('الحالة', ride['status']),
                  _detailLine('من', ride['from']),
                  _detailLine('إلى', ride['to']),
                  _detailLine('التاريخ', ride['date']),
                  _detailLine('الوقت', ride['time']),
                  _detailLine('السائق', ride['driver']),
                  _detailLine('المركبة', ride['vehicle']),
                  _detailLine('المبلغ', ride['price']),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lime,
                        foregroundColor: Colors.black,
                        elevation: 0,
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
          ),
        );
      },
    );
  }

  Widget _detailLine(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
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
}