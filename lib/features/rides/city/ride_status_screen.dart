import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/driver_location_service.dart';
import '../../../core/network/supabase_service.dart';
import '../../../core/theme/app_theme.dart';

class RideStatusScreen extends StatefulWidget {
  const RideStatusScreen({super.key});

  @override
  State<RideStatusScreen> createState() => _RideStatusScreenState();
}

class _RideStatusScreenState extends State<RideStatusScreen> {
  final MapController _mapController = MapController();

  StreamSubscription<Map<String, dynamic>?>? _locationSubscription;
  Timer? _rideRefreshTimer;

  int currentStep = 0;

  bool _isTracking = true;
  bool _isLiveLocation = false;
  bool _isLoadingRide = true;

  String? _activeRideId;
  String? _driverId;
  String? get driverId => _driverId;

  LatLng? _liveDriverPosition;
  double _driverHeading = 0;
  double _driverSpeed = 0;

  final List<String> steps = [
    'السائق في الطريق إليك',
    'وصل السائق',
    'بدأت الرحلة',
    'انتهت الرحلة',
  ];

  final List<IconData> stepIcons = [
    Icons.directions_car,
    Icons.location_on,
    Icons.route,
    Icons.flag,
  ];

  final List<LatLng> _routePoints = const [
    LatLng(15.6377, 32.5540),
    LatLng(15.6364, 32.5531),
    LatLng(15.6351, 32.5521),
    LatLng(15.6338, 32.5511),
    LatLng(15.6323, 32.5501),
    LatLng(15.6309, 32.5490),
    LatLng(15.6293, 32.5480),
    LatLng(15.6278, 32.5468),
    LatLng(15.6261, 32.5457),
    LatLng(15.6245, 32.5445),
    LatLng(15.6228, 32.5434),
    LatLng(15.6212, 32.5421),
    LatLng(15.6195, 32.5409),
    LatLng(15.6178, 32.5397),
    LatLng(15.6160, 32.5384),
    LatLng(15.6143, 32.5371),
    LatLng(15.6125, 32.5358),
    LatLng(15.6108, 32.5345),
    LatLng(15.6090, 32.5332),
    LatLng(15.6072, 32.5319),
    LatLng(15.6054, 32.5305),
    LatLng(15.6036, 32.5292),
    LatLng(15.6018, 32.5278),
    LatLng(15.6000, 32.5264),
  ];

  LatLng get _fallbackDriverPosition {
    if (_routePoints.isEmpty) {
      return const LatLng(15.6377, 32.5540);
    }

    return _routePoints.first;
  }

  LatLng get _driverPosition =>
      _liveDriverPosition ?? _fallbackDriverPosition;

  LatLng get _pickupPoint => _routePoints.first;

  LatLng get _destinationPoint => _routePoints.last;

  @override
  void initState() {
    super.initState();
    _loadActiveRide();
    _startRideRefresh();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _rideRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveRide() async {
    final client = SupabaseService.client;

    if (client == null) {
      _clearRide();
      return;
    }

    final user = client.auth.currentUser;

    if (user == null) {
      _clearRide();
      return;
    }

    try {
      final response = await client
          .from('rides')
          .select('id, driver_id, status')
          .eq('passenger_id', user.id)
          .inFilter('status', [
            'accepted',
            'driver_arriving',
            'in_progress',
          ])
          .order('updated_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        _clearRide();
      } else {
        final ride = response.first;
        final rideId = ride['id']?.toString();
        final driverId = ride['driver_id']?.toString();
        final status = ride['status']?.toString();

        if (rideId != _activeRideId) {
          _locationSubscription?.cancel();
          _locationSubscription = null;
          _liveDriverPosition = null;
          _isLiveLocation = false;
        }

        _activeRideId = rideId;
        _driverId = driverId;
        _setStepFromStatus(status);

        if (_activeRideId != null) {
          await _loadInitialDriverLocation();
          _startLiveLocationTracking();
        }
      }
    } catch (_) {
      _clearRide();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRide = false;
        });
      }
    }
  }

  void _clearRide() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _activeRideId = null;
    _driverId = null;
    _liveDriverPosition = null;
    _isLiveLocation = false;
    currentStep = 0;

    if (mounted) {
      setState(() {
        _isLoadingRide = false;
      });
    }
  }

  void _setStepFromStatus(String? status) {
    final step = switch (status) {
      'accepted' => 0,
      'driver_arriving' => 0,
      'in_progress' => 2,
      _ => 0,
    };

    currentStep = step;
  }

  void _startRideRefresh() {
    _rideRefreshTimer?.cancel();
    _rideRefreshTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) {
        if (mounted) {
          _loadActiveRide();
        }
      },
    );
  }

  Future<void> _loadInitialDriverLocation() async {
    final rideId = _activeRideId;

    if (rideId == null) {
      return;
    }

    try {
      final location =
          await DriverLocationService.getLocation(
        rideId: rideId,
      );

      if (location == null || !mounted) {
        return;
      }

      _updateDriverLocation(location);
    } catch (_) {
      // Keep the map available even if the initial
      // location cannot be loaded.
    }
  }

  void _startLiveLocationTracking() {
    final rideId = _activeRideId;

    if (rideId == null) {
      return;
    }

    _locationSubscription?.cancel();

    _locationSubscription =
        DriverLocationService.watchLocation(
      rideId: rideId,
    ).listen(
      (location) {
        if (location == null) {
          return;
        }

        _updateDriverLocation(location);
      },
      onError: (_) {
        // Keep the screen usable if realtime temporarily fails.
      },
    );
  }

  void _updateDriverLocation(
    Map<String, dynamic> location,
  ) {
    final latitude = _toDouble(location['latitude']);
    final longitude = _toDouble(location['longitude']);

    if (latitude == null || longitude == null) {
      return;
    }

    final heading =
        _toDouble(location['heading']) ?? 0;

    final speed =
        _toDouble(location['speed']) ?? 0;

    final position = LatLng(
      latitude,
      longitude,
    );

    if (!mounted) {
      _liveDriverPosition = position;
      _driverHeading = heading;
      _driverSpeed = speed;
      _isLiveLocation = true;
      return;
    }

    setState(() {
      _liveDriverPosition = position;
      _driverHeading = heading;
      _driverSpeed = speed;
      _isLiveLocation = true;
    });

    if (_isTracking) {
      try {
        _mapController.move(
          position,
          15.5,
        );
      } catch (_) {
        // MapController may not be ready yet.
      }
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking && _liveDriverPosition != null) {
      _mapController.move(
        _liveDriverPosition!,
        15.5,
      );
    }
  }

  void _centerOnDriver() {
    _mapController.move(
      _driverPosition,
      15.5,
    );
  }

  void _centerOnDestination() {
    _mapController.move(
      _destinationPoint,
      14.5,
    );
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
          title: const Text(
            'حالة الرحلة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  context.push('/ride-chat'),
              icon: const Icon(
                Icons.chat_outlined,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              30,
            ),
            child: Column(
              children: [
                _buildMap(),
                const SizedBox(height: 18),
                _buildTrackingInfo(),
                const SizedBox(height: 18),
                _buildStatusCard(),
                const SizedBox(height: 18),
                _buildDriverCard(),
                const SizedBox(height: 18),
                _buildProgress(),
                const SizedBox(height: 18),
                _buildTripDetails(),
                const SizedBox(height: 20),
                if (currentStep < 3)
                  _buildNextStepButton()
                else
                  _buildFinishSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 330,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _driverPosition,
              initialZoom: 14.5,
              minZoom: 10,
              maxZoom: 19,
              interactionOptions:
                  const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.wasel.app',
              ),
              if (_activeRideId != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 6,
                      color: AppColors.lime,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickupPoint,
                    width: 48,
                    height: 48,
                    child: _mapMarker(
                      icon:
                          Icons.person_pin_circle,
                      color: Colors.redAccent,
                      label: 'نقطة الانطلاق',
                    ),
                  ),
                  Marker(
                    point: _destinationPoint,
                    width: 48,
                    height: 48,
                    child: _mapMarker(
                      icon: Icons.flag,
                      color: Colors.blueAccent,
                      label: 'الوجهة',
                    ),
                  ),
                  Marker(
                    point: _driverPosition,
                    width: 68,
                    height: 68,
                    child: _driverMarker(),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _mapInfoBadge(),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Column(
              children: [
                _mapControlButton(
                  icon: Icons.my_location,
                  onPressed: _centerOnDriver,
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Icons.flag_outlined,
                  onPressed:
                      _centerOnDestination,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            left: 12,
            child: _buildMapBottomInfo(),
          ),
        ],
      ),
    );
  }

  Widget _mapInfoBadge() {
    final bool live = _isLiveLocation;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(
          alpha: 0.94,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: live
                  ? AppColors.lime
                  : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            live
                ? 'GPS مباشر'
                : _isLoadingRide
                    ? 'جاري الاتصال...'
                    : 'بانتظار GPS',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBottomInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(
          alpha: 0.95,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isLiveLocation
                ? Icons.gps_fixed
                : Icons.route,
            color: AppColors.lime,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isLiveLocation
                  ? 'موقع السائق يتحدث مباشرة'
                  : 'بانتظار GPS',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            _isLiveLocation
                ? _speedText()
                : '${_routeProgress()}%',
            style: const TextStyle(
              color: AppColors.lime,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _speedText() {
    final kmh = _driverSpeed * 3.6;

    if (kmh <= 0) {
      return 'متوقف';
    }

    return '${kmh.toStringAsFixed(0)} كم/س';
  }

  int _routeProgress() {
    return 0;
  }

  Widget _mapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: AppColors.surface.withValues(
        alpha: 0.95,
      ),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: AppColors.lime,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _mapMarker({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Tooltip(
      message: label,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.25,
              ),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 23,
        ),
      ),
    );
  }

  Widget _driverMarker() {
    return Transform.rotate(
      angle: _driverHeading * 3.141592653589793 / 180,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lime,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.lime.withValues(
                alpha: 0.45,
              ),
              blurRadius: 14,
              spreadRadius: 3,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.directions_car,
            color: Colors.black,
            size: 29,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingInfo() {
    final bool locationReady =
        _isLiveLocation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: (locationReady
                      ? AppColors.lime
                      : Colors.orange)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              !locationReady
                  ? Icons.location_searching
                  : _isTracking
                      ? Icons.gps_fixed
                      : Icons.gps_off,
              color: locationReady
                  ? AppColors.lime
                  : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  locationReady
                      ? 'تتبع مباشر للسائق'
                      : _isLoadingRide
                          ? 'جاري الاتصال بالرحلة'
                          : 'بانتظار موقع السائق',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locationReady
                      ? 'يتم تحديث موقع المركبة من GPS السائق مباشرة'
                      : 'بانتظار إشارة GPS من السائق',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _toggleTracking,
            tooltip: _isTracking
                ? 'إيقاف متابعة الخريطة'
                : 'متابعة السائق',
            icon: Icon(
              _isTracking
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              color: AppColors.lime,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stepIcons[currentStep],
              color: Colors.black,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  steps[currentStep],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _statusSubtitle(),
                  style: const TextStyle(
                    color: Colors.black87,
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

  String _statusSubtitle() {
    switch (currentStep) {
      case 0:
        return 'السائق متجه إلى موقعك الآن';
      case 1:
        return 'السائق وصل إلى نقطة الالتقاء';
      case 2:
        return 'رحلتك جارية الآن';
      case 3:
        return 'وصلت إلى وجهتك بنجاح';
      default:
        return '';
    }
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'م',
                style: TextStyle(
                  color: AppColors.lime,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'محمد أحمد',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Toyota Corolla • أبيض',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '⭐ 4.9 • 328 رحلة',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                context.push('/ride-chat'),
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(
          steps.length,
          (index) {
            final bool completed =
                index <= currentStep;
            final bool last =
                index == steps.length - 1;

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.lime
                            : Colors.white
                                .withValues(
                                alpha: 0.05,
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        stepIcons[index],
                        size: 17,
                        color: completed
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                    if (!last)
                      Container(
                        width: 2,
                        height: 32,
                        color: index < currentStep
                            ? AppColors.lime
                            : Colors.grey.shade800,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 7),
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      color: completed
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: completed
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripDetails() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'تفاصيل الرحلة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _detailRow(
            Icons.my_location,
            'نقطة الانطلاق',
            'الخرطوم بحري',
          ),
          const SizedBox(height: 12),
          _detailRow(
            Icons.location_on,
            'الوجهة',
            'الخرطوم',
          ),
          const SizedBox(height: 12),
          _detailRow(
            Icons.route,
            'حالة التتبع',
            _isLiveLocation
                ? 'مباشر'
                : 'بانتظار GPS',
          ),
          const SizedBox(height: 12),
          _detailRow(
            Icons.speed,
            'السرعة',
            _speedText(),
          ),
          const SizedBox(height: 12),
          _detailRow(
            Icons.payments_outlined,
            'السعر',
            '4,000 جنيه',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.lime,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          if (currentStep < 3) {
            setState(() {
              currentStep++;
            });
          }

          if (currentStep == 3) {
            setState(() {
              _isTracking = false;
            });

            _locationSubscription?.cancel();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Text(
          _nextButtonText(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _nextButtonText() {
    switch (currentStep) {
      case 0:
        return 'وصل السائق';
      case 1:
        return 'بدء الرحلة';
      case 2:
        return 'إنهاء الرحلة';
      default:
        return 'متابعة';
    }
  }

  Widget _buildFinishSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.lime.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.lime.withValues(
                alpha: 0.25,
              ),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.lime,
                size: 30,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'انتهت الرحلة بنجاح. شكرًا لاستخدام واصل.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _showRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lime,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(17),
              ),
            ),
            child: const Text(
              'تقييم الرحلة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRating() {
    int rating = 5;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.58,
          minChildSize: 0.42,
          maxChildSize: 0.90,
          expand: false,
          snap: true,
          snapSizes: const [
            0.58,
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
                  20,
                  12,
                  20,
                  30,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'كيف كانت رحلتك؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قيّم تجربتك مع محمد أحمد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    builder: (
                      context,
                      setSheetState,
                    ) {
                      return Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) {
                            final bool selected =
                                index < rating;

                            return IconButton(
                              onPressed: () {
                                setSheetState(() {
                                  rating =
                                      index + 1;
                                });
                              },
                              icon: Icon(
                                selected
                                    ? Icons.star
                                    : Icons.star_border,
                                color: selected
                                    ? AppColors.lime
                                    : Colors.grey
                                        .shade600,
                                size: 38,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(