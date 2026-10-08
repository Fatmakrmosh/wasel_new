import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_text.dart';

class TrackParcelScreen extends StatefulWidget {
  const TrackParcelScreen({super.key});

  @override
  State<TrackParcelScreen> createState() => _TrackParcelScreenState();
}

class _TrackParcelScreenState extends State<TrackParcelScreen> {
  final TextEditingController _trackingController =
      TextEditingController(text: 'WAS-102548');

  bool _searched = false;

  final List<Map<String, String>> _trackingSteps = [
    {
      'title': 'تم إنشاء الشحنة',
      'subtitle': 'تم تسجيل الطرد في نظام واصل',
      'time': '10:30 ص',
    },
    {
      'title': 'تم استلام الطرد',
      'subtitle': 'تم استلام الطرد من المرسل',
      'time': '11:15 ص',
    },
    {
      'title': 'في الطريق',
      'subtitle': 'الطرد في طريقه إلى وجهته',
      'time': '01:20 م',
    },
    {
      'title': 'وصل إلى نقطة التوزيع',
      'subtitle': 'بانتظار التسليم إلى المستلم',
      'time': 'متوقع اليوم',
    },
    {
      'title': 'تم التسليم',
      'subtitle': 'سيظهر هنا عند اكتمال التسليم',
      'time': '',
    },
  ];

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  void _searchParcel() {
    final value = _trackingController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppText.t('أدخل رقم التتبع أولاً')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppText.t('تتبع طرد'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildTrackingInput(),
              if (_searched) ...[
                const SizedBox(height: 24),
                _buildCurrentStatus(),
                const SizedBox(height: 20),
                _buildTrackingTimeline(),
                const SizedBox(height: 20),
                _buildParcelDetails(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.lime,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.t('تتبع شحنتك'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  AppText.t('أدخل رقم التتبع لمعرفة حالة طردك ومكانه.'),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppText.t('رقم التتبع'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _trackingController,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: AppText.t('مثال: WAS-102548'),
              hintStyle: TextStyle(color: Colors.white38),
              prefixIcon: Icon(
                Icons.qr_code_2,
                color: AppColors.lime,
              ),
              filled: true,
              fillColor: Color(0xFF262626),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _searchParcel,
              icon: const Icon(Icons.search),
              label: Text(
                AppText.t('تتبع الطرد'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.lime,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.black,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.t('حالة الطرد الحالية'),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  AppText.t('الطرد في الطريق'),
                  style: TextStyle(
                    color: AppColors.lime,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppText.t('آخر تحديث: اليوم، 01:20 م'),
                  style: TextStyle(
                    color: Colors.white60,
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

  Widget _buildTrackingTimeline() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.t('رحلة الطرد'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            _trackingSteps.length,
            (index) => _buildTimelineItem(
              index,
              _trackingSteps[index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    int index,
    Map<String, String> step,
  ) {
    final bool completed = index <= 2;
    final bool current = index == 2;
    final bool isLast = index == _trackingSteps.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.lime
                      : const Color(0xFF303030),
                  shape: BoxShape.circle,
                  border: current
                      ? Border.all(
                          color: AppColors.lime,
                          width: 3,
                        )
                      : null,
                ),
                child: completed
                    ? const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 15,
                      )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 54,
                  color: completed
                      ? AppColors.lime.withValues(alpha: 0.6)
                      : const Color(0xFF333333),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.t(step['title'] ?? ''),
                  style: TextStyle(
                    color: completed ? Colors.white : Colors.white54,
                    fontSize: 14,
                    fontWeight:
                        completed ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppText.t(step['subtitle'] ?? ''),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                if ((step['time'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppText.t(step['time']!),
                    style: TextStyle(
                      color: completed ? AppColors.lime : Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParcelDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل الشحنة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          _detailRow(
            Icons.qr_code,
            'رقم التتبع',
            _trackingController.text.trim(),
          ),
          _detailRow(
            Icons.location_on_outlined,
            'من',
            'الخرطوم',
          ),
          _detailRow(
            Icons.flag_outlined,
            'إلى',
            'شندي',
          ),
          _detailRow(
            Icons.inventory_2_outlined,
            'نوع الطرد',
            'طرد عادي',
          ),
          _detailRow(
            Icons.payments_outlined,
            'التكلفة',
            '3,500 جنيه',
          ),
          _detailRow(
            Icons.calendar_today_outlined,
            'تاريخ الإرسال',
            'اليوم',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.lime,
                size: 20,
              ),
              const SizedBox(width: 12),
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
        ),
        if (showDivider)
          const Divider(
            color: Colors.white10,
            height: 1,
          ),
      ],
    );
  }
}