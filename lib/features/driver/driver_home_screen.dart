import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/driver_location_service.dart';
import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool isAvailable = true;
  bool _locationPermissionGranted = false;
  bool _locationServiceEnabled = false;
  bool _isGettingLocation = false;
  bool _isSyncingLocation = false;

  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _rideRefreshTimer;

  String? _activeRideId;
  String? _driverId;

  final List<Map<String, dynamic>> nearbyRequests = [
    {
      'passenger': 'محمد علي',
      'from': 'بحري - المؤسسة',
      'to': 'الخرطوم - السوق العربي',
      'distance': '6.2 كم',
      'price': '4,500',
      'time': 'منذ دقيقتين',
    },
    {
      'passenger': 'أحمد حسن',
      'from': 'أم درمان - الثورة',
      'to': 'بحري - شمبات',
      'distance': '8.5 كم',
      'price': '5,500',
      'time': 'منذ 4 دقائق',
    },
    {
      'passenger': 'سارة محمد',
      'from': 'الخرطوم - الرياض',
      'to': 'بحري - كافوري',
      'distance': '10.1 كم',
      'price': '6,500',
      'time': 'منذ 7 دقائق',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeDriverTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _rideRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeDriverTracking() async {
    await _loadDriverAndRide();
    await _initializeLocationTracking();

    _rideRefreshTimer?.cancel();
    _rideRefreshTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) async {
        if (!mounted || !isAvailable) {
          return;
        }

        await _loadDriverAndRide();

        final hasActiveRide = _activeRideId != null;
        final isTracking = _positionSubscription != null;

        if (hasActiveRide && !isTracking &&
            _locationPermissionGranted) {
          await _startLocationTracking();
        }
      },
    );
  }

  Future<void> _loadDriverAndRide() async {
    final client = SupabaseService.client;

    if (client == null) {
      return;
    }

    final user = client.auth.currentUser;

    if (user == null) {
      return;
    }

    _driverId = user.id;

    try {
      final response = await client
          .from('rides')
          .select('id')
          .eq('driver_id', user.id)
          .inFilter('status', [
            'accepted',
            'driver_arriving',
            'in_progress',
          ])
          .order('updated_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        _activeRideId = response.first['id'] as String?;
      }
    } catch (_) {
      _activeRideId = null;
    }
  }

  Future<void> _syncCurrentLocation(Position position) async {
    final rideId = _activeRideId;
    final driverId = _driverId;

    if (rideId == null || driverId == null) {
      return;
    }

    if (_isSyncingLocation) {
      return;
    }

    _isSyncingLocation = true;

    try {
      await DriverLocationService.updateLocation(
        rideId: rideId,
        driverId: driverId,
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed,
      );
    } catch (_) {
      // Location updates should not stop the GPS stream
      // if the network is temporarily unavailable.
    } finally {
      _isSyncingLocation = false;
    }
  }

  Future<void> _initializeLocationTracking() async {
    final bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) {
        return;
      }

      setState(() {
        _locationServiceEnabled = false;
        _locationPermissionGranted = false;
        _isGettingLocation = false;
      });

      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final bool granted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (!mounted) {
      return;
    }

    setState(() {
      _locationServiceEnabled = true;
      _locationPermissionGranted = granted;
    });

    if (granted && isAvailable) {
      await _startLocationTracking();
    }
  }

  Future<void> _startLocationTracking() async {
    if (!_locationPermissionGranted) {
      await _initializeLocationTracking();
      return;
    }

    if (_positionSubscription != null) {
      return;
    }

    if (mounted) {
      setState(() {
        _isGettingLocation = true;
      });
    }

    try {
      final Position initialPosition =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = initialPosition;
          _isGettingLocation = false;
        });
      }

      await _syncCurrentLocation(initialPosition);

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionSubscription =
          Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          if (!mounted) {
            return;
          }

          setState(() {
            _currentPosition = position;
            _isGettingLocation = false;
          });

          _syncCurrentLocation(position);
        },
        onError: (_) {
          if (!mounted) {
            return;
          }

          setState(() {
            _isGettingLocation = false;
          });
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    if (_activeRideId != null) {
      try {
        await DriverLocationService.removeLocation(
          rideId: _activeRideId!,
        );
      } catch (_) {
        // Ignore temporary network errors.
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isGettingLocation = false;
    });
  }

  Future<void> _setAvailability(bool value) async {
    setState(() {
      isAvailable = value;
    });

    if (value) {
      await _loadDriverAndRide();
      await _initializeLocationTracking();
    } else {
      await _stopLocationTracking();
    }
  }

  Future<void> _refreshLocation() async {
    await _stopLocationTracking();
    await _loadDriverAndRide();

    if (!mounted) {
      return;
    }

    await _initializeLocationTracking();
  }

  String _locationStatusText() {
    if (!_locationServiceEnabled) {
      return 'خدمة الموقع غير مفعلة';
    }

    if (!_locationPermissionGranted) {
      return 'صلاحية الموقع غير مفعلة';
    }

    if (_isGettingLocation) {
      return 'جاري تحديد موقعك...';
    }

    if (_currentPosition != null && _activeRideId != null) {
      return 'GPS يعمل والموقع متصل بالرحلة';
    }

    if (_currentPosition != null) {
      return 'GPS يعمل ويتم تحديث موقعك';
    }

    return 'في انتظار موقع GPS';
  }

  Color _locationStatusColor() {
    if (!_locationServiceEnabled ||
        !_locationPermissionGranted) {
      return Colors.orange;
    }

    if (_isGettingLocation) {
      return Colors.orange;
    }

    if (_currentPosition != null) {
      return AppColors.lime;
    }

    return Colors.white54;
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
          centerTitle: false,
          title: const Text(
            'لوحة السائق',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
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
            color: AppColors.lime,
            backgroundColor: AppColors.surface,
            onRefresh: _refreshLocation,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                32,
              ),
              children: [
                _buildAvailabilityCard(),
                const SizedBox(height: 14),
                _buildLocationCard(),
                const SizedBox(height: 16),
                _buildVerificationCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('ملخص اليوم'),
                const SizedBox(height: 12),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  'الرحلة الحالية',
                  actionText: 'فتح',
                  onAction: () =>
                      context.push('/ride-status'),
                ),
                const SizedBox(height: 12),
                _buildCurrentRideCard(),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  'طلبات قريبة منك',
                  actionText: 'عرض الكل',
                  onAction: _showAllRequests,
                ),
                const SizedBox(height: 12),
                ...nearbyRequests
                    .take(3)
                    .map(_buildRequestCard),
                const SizedBox(height: 24),
                _buildSectionTitle('الوصول السريع'),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildSectionTitle('تقييمك'),
                const SizedBox(height: 12),
                _buildRatingCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable
              ? AppColors.lime.withValues(alpha: 0.35)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.lime.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable
                  ? Icons.wifi_tethering_rounded
                  : Icons.pause_circle_outline_rounded,
              color:
                  isAvailable ? AppColors.lime : Colors.white54,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable
                      ? 'أنت متاح الآن'
                      : 'أنت غير متاح',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isAvailable
                      ? 'ستظهر لك طلبات الرحلات القريبة'
                      : 'لن تصلك طلبات جديدة حتى تصبح متاحًا',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            activeThumbColor: AppColors.lime,
            activeTrackColor:
                AppColors.lime.withValues(alpha: 0.30),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
            onChanged: _setAvailability,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final Color statusColor = _locationStatusColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _currentPosition != null
                  ? Icons.gps_fixed_rounded
                  : Icons.location_searching_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'موقع السائق',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _locationStatusText(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_currentPosition != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_currentPosition!.latitude.toStringAsFixed(5)}, '
                    '${_currentPosition!.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: _refreshLocation,
            tooltip: 'تحديث الموقع',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2612),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  AppColors.lime.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.lime,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'حسابك موثق',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'يمكنك استقبال طلبات الرحلات',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppColors.lime,
            size: 22,
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
                color: AppColors.lime,
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
      childAspectRatio: 1.65,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          icon: Icons.payments_outlined,
          title: 'أرباح اليوم',
          value: '18,500',
          suffix: 'جنيه',
        ),
        _buildStatCard(
          icon: Icons.route_rounded,
          title: 'رحلات اليوم',
          value: '7',
          suffix: 'رحلات',
        ),
        _buildStatCard(
          icon: Icons.star_rounded,
          title: 'التقييم',
          value: '4.9',
          suffix: '/ 5',
        ),
        _buildStatCard(
          icon: Icons.calendar_month_outlined,
          title: 'هذا الشهر',
          value: '142',
          suffix: 'رحلة',
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.lime,
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
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
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
                padding:
                    const EdgeInsets.only(bottom: 2),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              AppColors.lime.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lime
                      .withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Text(
                  'رحلة نشطة',
                  style: TextStyle(
                    color: AppColors.lime,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '4,000 جنيه',
                style: TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
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
                    Icons.location_on_rounded,
                    color: Colors.redAccent,
                    size: 19,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بحري - المؤسسة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 22),
                    Text(
                      'الخرطوم - السوق العربي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.push('/ride-status'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        AppColors.lime,
                    side: const BorderSide(
                      color: AppColors.lime,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('فتح الرحلة'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      context.push('/ride-status'),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.lime,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'متابعة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.lime.withValues(
                  alpha: 0.12,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.lime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['passenger']
                          as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      request['time'] as String,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${request['price']} جنيه',
                style: const TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRouteRow(
            Icons.radio_button_checked,
            request['from'] as String,
            AppColors.lime,
          ),
          const SizedBox(height: 8),
          _buildRouteRow(
            Icons.location_on_rounded,
            request['to'] as String,
            Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                color: Colors.white38,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                request['distance'] as String,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    _showRequestDetails(request),
                child: const Text(
                  'التفاصيل',
                  style: TextStyle(
                    color: AppColors.lime,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(
    IconData icon,
    String text,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 17,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 10,
      childAspectRatio: 0.90,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      children: [
        _buildQuickAction(
          Icons.route_rounded,
          'رحلاتي',
          () => context.push('/my-rides'),
        ),
        _buildQuickAction(
          Icons.account_balance_wallet_outlined,
          'الأرباح',
          _showEarnings,
        ),
        _buildQuickAction(
          Icons.directions_car_outlined,
          'المركبة',
          () => context.push('/vehicle-register'),
        ),
        _buildQuickAction(
          Icons.description_outlined,
          'المستندات',
          _showDocuments,
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
        padding:
            const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.lime,
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

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color:
                  AppColors.lime.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '4.9',
                style: TextStyle(
                  color: AppColors.lime,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'تقييم ممتاز',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'حافظ على جودة الخدمة واحترام الركاب',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star_rounded,
            color: AppColors.lime,
            size: 28,
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(
    Map<String, dynamic> request,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.62,
          minChildSize: 0.42,
          maxChildSize: 0.92,
          expand: false,
          snap: true,
          snapSizes: const [
            0.62,
            0.92,
          ],
          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  30,
                ),
                children: [
                  _buildSheetHandle(),
                  const SizedBox(height: 20),
                  const Text(
                    'تفاصيل طلب الرحلة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildBottomSheetRow(
                    'الراكب',
                    request['passenger']
                        as String,
                    Icons.person_outline,
                  ),
                  _buildBottomSheetRow(
                    'من',
                    request['from'] as String,
                    Icons.trip_origin,
                  ),
                  _buildBottomSheetRow(
                    'إلى',
                    request['to'] as String,
                    Icons.location_on_outlined,
                  ),
                  _buildBottomSheetRow(
                    'المسافة',
                    request['distance']
                        as String,
                    Icons.route_outlined,
                  ),
                  _buildBottomSheetRow(
                    'السعر المقترح',
                    '${request['price']} جنيه',
                    Icons.payments_outlined,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                        );
                        context.push(
                          '/ride-status',
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.lime,
                        foregroundColor:
                            Colors.black,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                      child: const Text(
                        'قبول الرحلة',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 45,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildBottomSheetRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15),
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
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showAllRequests() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          expand: false,
          snap: true,
          snapSizes: const [
            0.72,
            0.94,
          ],
          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  30,
                ),
                children: [
                  _buildSheetHandle(),
                  const SizedBox(height: 20),
                  const Text(
                    'طلبات الرحلات القريبة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...nearbyRequests.map(
                    _buildRequestCard,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEarnings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.40,
          maxChildSize: 0.85,
          expand: false,
          snap: true,
          snapSizes: const [
            0.55,
            0.85,
          ],
          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding:
                    const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  30,
                ),
                children: [
                  _buildSheetHandle(),
                  const SizedBox(height: 20),
                  const Text(
                    'ملخص الأرباح',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildEarningRow(
                    'اليوم',
                    '18,500 جنيه',
                  ),
                  _buildEarningRow(
                    'هذا الأسبوع',
                    '96,000 جنيه',
                  ),
                  _buildEarningRow(
                    'هذا الشهر',
                    '385,500 جنيه',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEarningRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
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
              color: AppColors.lime,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showDocuments() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.62,
          minChildSize: 0.42,
          maxChildSize: 0.90,
          expand: false,
          snap: true,
          snapSizes: const [
            0.62,
            0.90,
          ],
          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding:
                    const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  30,
                ),
                children: [
                  _buildSheetHandle(),
                  const SizedBox(height: 20),
                  const Text(
                    'مستندات السائق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDocumentRow(
                    'الهوية الوطنية',
                    true,
                  ),
                  _buildDocumentRow(
                    'رخصة القيادة',
                    true,
                  ),
                  _buildDocumentRow(
                    'رخصة المركبة',
                    true,
                  ),
                  _buildDocumentRow(
                    'صورة المركبة',
                    true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDocumentRow(
    String title,
    bool completed,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(alpha: 0.04),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
            color: completed
                ? AppColors.lime
                : Colors.orange,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            completed ? 'مكتمل' : 'ناقص',
            style: TextStyle(
              color: completed
                  ? AppColors.lime
                  : Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}