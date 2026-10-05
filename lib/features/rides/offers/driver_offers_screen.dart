import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../city/city_ride_request.dart';

class DriverOffersScreen extends StatefulWidget {
  const DriverOffersScreen({
    super.key,
  });

  @override
  State<DriverOffersScreen> createState() => _DriverOffersScreenState();
}

class _DriverOffersScreenState extends State<DriverOffersScreen> {
  CityRideRequest? _request;

  bool _isWaiting = true;
  bool _showRequestDetails = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final extra = GoRouterState.of(context).extra;

    if (extra is CityRideRequest) {
      _request = extra;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text(
            'عروض السائقين',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (request != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _showRequestDetails = !_showRequestDetails;
                  });
                },
                icon: Icon(
                  _showRequestDetails
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: request == null
              ? _buildMissingRequest()
              : _buildContent(request),
        ),
      ),
    );
  }

  Widget _buildContent(CityRideRequest request) {
    return Column(
      children: [
        _buildRequestSummary(request),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              30,
            ),
            children: [
              if (_showRequestDetails) ...[
                _buildRequestDetails(request),
                const SizedBox(height: 18),
              ],
              _buildWaitingBanner(),
              const SizedBox(height: 18),
              _buildOffersArea(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestSummary(CityRideRequest request) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.local_taxi_outlined,
              color: Colors.black,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تم إرسال طلب الرحلة',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${request.pickupLabel} ← ${request.destinationLabel}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'تقديري',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${request.estimatedFare.round()}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'جنيه',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(CityRideRequest request) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'تفاصيل الطلب',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _detailRow(
            icon: Icons.my_location,
            title: 'الانطلاق',
            value: request.pickupLabel,
            iconColor: AppColors.lime,
          ),
          const SizedBox(height: 12),
          _detailRow(
            icon: Icons.location_on,
            title: 'الوجهة',
            value: request.destinationLabel,
            iconColor: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          _detailRow(
            icon: Icons.route_outlined,
            title: 'المسافة',
            value: '${request.distanceKm.toStringAsFixed(1)} كم',
          ),
          const SizedBox(height: 12),
          _detailRow(
            icon: Icons.access_time,
            title: 'الوقت المتوقع',
            value: '${request.durationMinutes.round()} دقيقة',
          ),
          const SizedBox(height: 12),
          _detailRow(
            icon: Icons.directions_car_outlined,
            title: 'المركبة',
            value: request.vehicleType,
          ),
          const SizedBox(height: 12),
          _detailRow(
            icon: Icons.people_outline,
            title: 'الركاب',
            value: '${request.passengers}',
          ),
          if (request.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _detailRow(
              icon: Icons.notes_outlined,
              title: 'الملاحظات',
              value: request.notes.trim(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor ?? Colors.grey.shade400,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isWaiting)
                  const SizedBox(
                    width: 46,
                    height: 46,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.lime,
                    ),
                  ),
                Icon(
                  _isWaiting
                      ? Icons.search
                      : Icons.pause_circle_outline,
                  color: AppColors.lime,
                  size: 21,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isWaiting
                      ? 'في انتظار عروض السائقين'
                      : 'تم إيقاف انتظار العروض',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'السائقون القريبون منك سيشاهدون الطلب ويمكنهم تقديم سعرهم.',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        30,
        18,
        30,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              color: AppColors.lime,
              size: 35,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'لا توجد عروض بعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'طلبك أصبح جاهزًا لاستقبال عروض السائقين. '
            'بمجرد وصول عرض سيظهر هنا مع بيانات السائق والمركبة والسعر.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _buildStatusSteps(),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isWaiting = !_isWaiting;
              });
            },
            icon: Icon(
              _isWaiting
                  ? Icons.pause_circle_outline
                  : Icons.play_arrow,
            ),
            label: Text(
              _isWaiting
                  ? 'إيقاف انتظار العروض'
                  : 'متابعة انتظار العروض',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.grey.shade700,
              ),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSteps() {
    final steps = <Map<String, dynamic>>[
      {
        'icon': Icons.check_circle,
        'title': 'تم إنشاء الطلب',
        'done': true,
      },
      {
        'icon': Icons.radar,
        'title': 'البحث عن سائقين قريبين',
        'done': _isWaiting,
      },
      {
        'icon': Icons.local_taxi_outlined,
        'title': 'وصول عروض السائقين',
        'done': false,
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'اختيار العرض المناسب',
        'done': false,
      },
    ];

    return Column(
      children: List.generate(
        steps.length,
        (index) {
          final step = steps[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  step['icon'] as IconData,
                  color: step['done'] == true
                      ? AppColors.lime
                      : Colors.grey.shade700,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step['title'] as String,
                    style: TextStyle(
                      color: step['done'] == true
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: step['done'] == true
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (step['done'] == true)
                  const Icon(
                    Icons.done,
                    color: AppColors.lime,
                    size: 17,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMissingRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orangeAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'بيانات الرحلة غير متوفرة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هذه الشاشة تحتاج بيانات الطلب القادم من رحلة المدينة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/city-ride');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'العودة لطلب الرحلة',
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
  }
}