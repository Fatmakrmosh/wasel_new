import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../core/network/ride_market_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_text.dart';
import 'city_ride_request.dart';

class CityRideScreen extends StatefulWidget {
  const CityRideScreen({super.key});

  @override
  State<CityRideScreen> createState() => _CityRideScreenState();
}

class _CityRideScreenState extends State<CityRideScreen> {
  static const LatLng _defaultCenter = LatLng(15.5007, 32.5599);

  final TextEditingController _pickupController =
      TextEditingController();

  final TextEditingController _destinationController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  final MapController _mapController = MapController();

  Position? _currentPosition;

  LatLng? _pickupPoint;
  LatLng? _destinationPoint;

  List<LatLng> _routePoints = <LatLng>[];

  double _distanceKm = 0;
  double _durationMinutes = 0;

  bool _loadingLocation = false;
  bool _loadingRoute = false;
  bool _routeFailed = false;

  String _selectedVehicle = 'سيارة';
  int _passengers = 1;

  final Map<String, _VehicleOption> _vehicleOptions = const {
    'دراجة': _VehicleOption(
      icon: Icons.motorcycle,
      description: 'لشخص واحد',
      capacity: 1,
    ),
    'ركشة': _VehicleOption(
      icon: Icons.electric_rickshaw,
      description: 'مناسبة للمشاوير القصيرة',
      capacity: 3,
    ),
    'سيارة': _VehicleOption(
      icon: Icons.directions_car,
      description: 'الخيار المعتاد داخل المدينة',
      capacity: 4,
    ),
    'بوكس': _VehicleOption(
      icon: Icons.local_shipping,
      description: 'للركاب مع أمتعة أو حمل خفيف',
      capacity: 4,
    ),
  };

  double get _baseFare => 5000;

  double get _distanceFare => _distanceKm * 6000;

  double get _waitingMinutes => 0;

  double get _waitingFare => _waitingMinutes * 500;

  double get _estimatedFare =>
      _baseFare + _distanceFare + _waitingFare;

  int get _selectedCapacity =>
      _vehicleOptions[_selectedVehicle]?.capacity ?? 4;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(
      showMessage: false,
      centerMap: false,
      autoSetPickup: true,
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation({
    required bool showMessage,
    required bool centerMap,
    required bool autoSetPickup,
  }) async {
    if (_loadingLocation) {
      return;
    }

    setState(() {
      _loadingLocation = true;
    });

    try {
      final allowed = await _ensureLocationPermission(
        showMessage: showMessage,
      );

      if (!allowed) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final point = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = position;

        if (autoSetPickup &&
            _pickupPoint == null &&
            _pickupController.text.trim().isEmpty) {
          _pickupPoint = point;
        }
      });

      if (centerMap) {
        _moveMapTo(point, 15);
      }

      if (autoSetPickup &&
          _pickupController.text.trim().isEmpty) {
        final address = await _reverseGeocode(point);

        if (!mounted) {
          return;
        }

        setState(() {
          _pickupPoint = point;
          _pickupController.text =
              address ?? 'موقعي الحالي';
        });

        await _updateRoute();
      }
    } catch (_) {
      if (showMessage && mounted) {
        _showMessage(
          AppText.t('تعذر الحصول على موقعك الحالي'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  Future<bool> _ensureLocationPermission({
    required bool showMessage,
  }) async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (showMessage && mounted) {
        await _showActionDialog(
          title: AppText.t('خدمة الموقع مغلقة'),
          message:
              AppText.t('فعّل خدمة الموقع حتى يتمكن واصل من تحديد موقعك.'),
          actionText: AppText.t('فتح الموقع'),
          action: () async {
            await Geolocator.openLocationSettings();
          },
        );
      }

      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (showMessage && mounted) {
        _showMessage(
          AppText.t('تم رفض صلاحية الموقع'),
        );
      }

      return false;
    }

    if (permission ==
        LocationPermission.deniedForever) {
      if (showMessage && mounted) {
        await _showActionDialog(
          title: AppText.t('صلاحية الموقع مرفوضة'),
          message:
              AppText.t('افتح إعدادات التطبيق واسمح له باستخدام الموقع.'),
          actionText: AppText.t('فتح الإعدادات'),
          action: () async {
            await Geolocator.openAppSettings();
          },
        );
      }

      return false;
    }

    return true;
  }

  Future<String?> _reverseGeocode(
    LatLng point,
  ) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'lat': point.latitude.toString(),
          'lon': point.longitude.toString(),
          'format': 'jsonv2',
          'accept-language': 'ar',
          'zoom': '18',
        },
      );

      final response = await http.get(
        uri,
        headers: const {
          'User-Agent': 'WASEL Flutter App/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final displayName = decoded['display_name'];

      if (displayName is String &&
          displayName.trim().isNotEmpty) {
        return displayName.trim();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<_MapSelection?> _openLocationPicker({
    required String title,
    required LatLng initialCenter,
    required String initialLabel,
    required Color accentColor,
    required bool showCurrentLocation,
  }) {
    return showModalBottomSheet<_MapSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return _LocationPickerSheet(
          title: title,
          initialCenter: initialCenter,
          initialLabel: initialLabel,
          accentColor: accentColor,
          showCurrentLocation: showCurrentLocation,
        );
      },
    );
  }

  Future<void> _choosePickup() async {
    final selection = await _openLocationPicker(
      title: AppText.t('تحديد نقطة الانطلاق'),
      initialCenter:
          _pickupPoint ?? _currentPointOrDefault,
      initialLabel: _pickupController.text.trim(),
      accentColor: AppColors.lime,
      showCurrentLocation: true,
    );

    if (selection == null || !mounted) {
      return;
    }

    setState(() {
      _pickupPoint = selection.point;
      _pickupController.text = selection.label;
    });

    await _updateRoute();
  }

  Future<void> _chooseDestination() async {
    final selection = await _openLocationPicker(
      title: AppText.t('تحديد الوجهة'),
      initialCenter:
          _destinationPoint ?? _currentPointOrDefault,
      initialLabel:
          _destinationController.text.trim(),
      accentColor: Colors.redAccent,
      showCurrentLocation: false,
    );

    if (selection == null || !mounted) {
      return;
    }

    setState(() {
      _destinationPoint = selection.point;
      _destinationController.text = selection.label;
    });

    await _updateRoute();
  }

  LatLng get _currentPointOrDefault {
    if (_currentPosition != null) {
      return LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }

    return _defaultCenter;
  }

  Future<void> _updateRoute() async {
    if (_pickupPoint == null ||
        _destinationPoint == null) {
      setState(() {
        _routePoints = <LatLng>[];
        _distanceKm = 0;
        _durationMinutes = 0;
        _routeFailed = false;
      });
      return;
    }

    final pickup = _pickupPoint!;
    final destination = _destinationPoint!;

    final directDistance =
        Geolocator.distanceBetween(
      pickup.latitude,
      pickup.longitude,
      destination.latitude,
      destination.longitude,
    );

    if (directDistance < 10) {
      setState(() {
        _routePoints = <LatLng>[
          pickup,
          destination,
        ];
        _distanceKm = 0;
        _durationMinutes = 0;
        _routeFailed = true;
      });

      _fitRoute();
      return;
    }

    setState(() {
      _loadingRoute = true;
      _routeFailed = false;
    });

    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${pickup.longitude},${pickup.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson&steps=false',
      );

      final response = await http.get(
        uri,
        headers: const {
          'User-Agent': 'WASEL Flutter App/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Route request failed',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid route response',
        );
      }

      final routes = decoded['routes'];

      if (routes is! List || routes.isEmpty) {
        throw Exception(
          'No route found',
        );
      }

      final firstRoute = routes.first;

      if (firstRoute is! Map<String, dynamic>) {
        throw Exception(
          'Invalid route data',
        );
      }

      final distanceMeters =
          (firstRoute['distance'] as num?)
                  ?.toDouble() ??
              0;

      final durationSeconds =
          (firstRoute['duration'] as num?)
                  ?.toDouble() ??
              0;

      final geometry =
          firstRoute['geometry'];

      if (geometry
          is! Map<String, dynamic>) {
        throw Exception(
          'Route geometry missing',
        );
      }

      final coordinates =
          geometry['coordinates'];

      if (coordinates is! List ||
          coordinates.isEmpty) {
        throw Exception(
          'Route coordinates missing',
        );
      }

      final points = <LatLng>[];

      for (final coordinate
          in coordinates) {
        if (coordinate is! List ||
            coordinate.length < 2) {
          continue;
        }

        final longitude =
            (coordinate[0] as num?)
                ?.toDouble();

        final latitude =
            (coordinate[1] as num?)
                ?.toDouble();

        if (latitude == null ||
            longitude == null) {
          continue;
        }

        points.add(
          LatLng(
            latitude,
            longitude,
          ),
        );
      }

      if (points.length < 2) {
        throw Exception(
          'Route path is empty',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _routePoints = points;
        _distanceKm =
            distanceMeters / 1000;
        _durationMinutes =
            durationSeconds / 60;
        _routeFailed = false;
      });

      _fitRoute();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _routePoints = <LatLng>[
          pickup,
          destination,
        ];
        _distanceKm = 0;
        _durationMinutes = 0;
        _routeFailed = true;
      });

      _fitRoute();
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
        });
      }
    }
  }

  void _fitRoute() {
    if (_pickupPoint == null ||
        _destinationPoint == null) {
      return;
    }

    final pickup = _pickupPoint!;
    final destination =
        _destinationPoint!;

    final center = LatLng(
      (pickup.latitude +
              destination.latitude) /
          2,
      (pickup.longitude +
              destination.longitude) /
          2,
    );

    final distanceMeters =
        Geolocator.distanceBetween(
      pickup.latitude,
      pickup.longitude,
      destination.latitude,
      destination.longitude,
    );

    double zoom;

    if (distanceMeters < 2000) {
      zoom = 14.5;
    } else if (distanceMeters < 5000) {
      zoom = 13.5;
    } else if (distanceMeters < 10000) {
      zoom = 12.8;
    } else if (distanceMeters < 25000) {
      zoom = 11.5;
    } else if (distanceMeters < 50000) {
      zoom = 10.5;
    } else {
      zoom = 9.5;
    }

    _moveMapTo(center, zoom);
  }

  void _moveMapTo(
    LatLng point,
    double zoom,
  ) {
    try {
      _mapController.move(
        point,
        zoom,
      );
    } catch (_) {
      // The map controller may not be attached yet.
    }
  }

  bool _samePoint(
    LatLng first,
    LatLng second,
  ) {
    final distanceMeters =
        Geolocator.distanceBetween(
      first.latitude,
      first.longitude,
      second.latitude,
      second.longitude,
    );

    return distanceMeters < 10;
  }

  Future<void> _submitRide() async {
    FocusScope.of(context).unfocus();

    if (_pickupPoint == null ||
        _pickupController.text.trim().isEmpty) {
      _showMessage(
        AppText.t('حدد نقطة الانطلاق أولاً'),
      );
      return;
    }

    if (_destinationPoint == null ||
        _destinationController.text.trim().isEmpty) {
      _showMessage(
        AppText.t('حدد الوجهة أولاً'),
      );
      return;
    }

    if (_samePoint(
      _pickupPoint!,
      _destinationPoint!,
    )) {
      _showMessage(
        AppText.t('نقطة الانطلاق والوجهة متطابقتان'),
      );
      return;
    }

    if (_routePoints.length < 2 ||
        _distanceKm <= 0) {
      await _updateRoute();
    }

    if (!mounted) {
      return;
    }

    if (_distanceKm <= 0) {
      _showMessage(
        AppText.t('تعذر حساب مسافة الطريق. تحقق من الإنترنت وحاول مرة أخرى.'),
      );
      return;
    }

    _showConfirmationSheet();
  }

  void _showConfirmationSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.68,
          minChildSize: 0.42,
          maxChildSize: 0.94,
          expand: false,
          snap: true,
          snapSizes: const [
            0.68,
            0.94,
          ],
          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration:
                  const BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ListView(
                controller:
                    scrollController,
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
                      width: 46,
                      height: 5,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade700,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    AppText.t('تأكيد طلب الرحلة'),
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _summaryRow(
                    Icons.my_location,
                    AppText.t('من'),
                    _pickupController.text
                        .trim(),
                    AppColors.lime,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    Icons.location_on,
                    AppText.t('إلى'),
                    _destinationController
                        .text
                        .trim(),
                    Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    Icons.directions_car,
                    AppText.t('المركبة'),
                    _selectedVehicle,
                    AppColors.lime,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    Icons.people_outline,
                    AppText.t('الركاب'),
                    '$_passengers',
                    AppColors.lime,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    Icons.route_outlined,
                    AppText.t('المسافة'),
                    '${_distanceKm.toStringAsFixed(1)} كم',
                    AppColors.lime,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    Icons.access_time,
                    AppText.t('الوقت المتوقع'),
                    '${_durationMinutes.round()} دقيقة',
                    AppColors.lime,
                  ),
                  const SizedBox(height: 20),
                  _buildFareBreakdown(),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final request =
                            CityRideRequest(
                          pickupLabel:
                              _pickupController
                                  .text
                                  .trim(),
                          destinationLabel:
                              _destinationController
                                  .text
                                  .trim(),
                          pickupPoint:
                              _pickupPoint!,
                          destinationPoint:
                              _destinationPoint!,
                          distanceKm:
                              _distanceKm,
                          durationMinutes:
                              _durationMinutes,
                          estimatedFare:
                              _estimatedFare,
                          vehicleType:
                              _selectedVehicle,
                          passengers:
                              _passengers,
                          notes:
                              _notesController
                                  .text
                                  .trim(),
                        );

                        try {
                          final rideId =
                              await RideMarketService.createRideRequest(
                            pickupLat: request.pickupPoint.latitude,
                            pickupLng: request.pickupPoint.longitude,
                            destinationLat:
                                request.destinationPoint.latitude,
                            destinationLng:
                                request.destinationPoint.longitude,
                            pickupAddress: request.pickupLabel,
                            destinationAddress:
                                request.destinationLabel,
                            vehicleType: request.vehicleType,
                            passengers: request.passengers,
                            suggestedFare: request.estimatedFare,
                            notes: request.notes,
                          );

                          if (rideId == null || !sheetContext.mounted) {
                            return;
                          }

                          Navigator.pop(sheetContext);

                          if (!mounted) {
                            return;
                          }

                          context.push(
                            '/driver-offers?rideId=$rideId',
                            extra: request,
                          );
                        } catch (error) {
                          if (!mounted) {
                            return;
                          }

                          _showMessage(
                            error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                          );
                        }
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
                            16,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        AppText.t('تأكيد وإرسال الطلب'),
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
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

  Widget _summaryRow(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: iconColor,
        ),
        const SizedBox(width: 12),
        Text(
          '$title: ',
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 3,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFareBreakdown() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color:
            AppColors.lime.withValues(
          alpha: 0.09,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              AppColors.lime.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color:
                    AppColors.lime,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'السعر التقديري',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_estimatedFare.round()} جنيه',
                style:
                    const TextStyle(
                  color:
                      AppColors.lime,
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: Colors.white
                .withValues(
              alpha: 0.08,
            ),
          ),
          const SizedBox(height: 14),
          _fareLine(
            'رسوم فتح الرحلة',
            '${_baseFare.round()} جنيه',
          ),
          const SizedBox(height: 8),
          _fareLine(
            AppText.t('المسافة'),
            '${_distanceFare.round()} جنيه',
          ),
          const SizedBox(height: 8),
          _fareLine(
            'الانتظار',
            _waitingMinutes == 0
                ? 'يُحسب أثناء الرحلة'
                : '${_waitingFare.round()} جنيه',
          ),
          const SizedBox(height: 10),
          Align(
            alignment:
                Alignment.centerRight,
            child: Text(
              'المعادلة: 5,000 + 6,000 لكل كم + 500 لكل دقيقة انتظار',
              style: TextStyle(
                color:
                    Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fareLine(
    String title,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color:
                  Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final center =
        _currentPointOrDefault;

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        24,
      ),
      child: SizedBox(
        height: 360,
        child: Stack(
          children: [
            FlutterMap(
              mapController:
                  _mapController,
              options: MapOptions(
                initialCenter:
                    center,
                initialZoom: 13.5,
                minZoom: 5,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.wasel_new',
                  maxNativeZoom: 19,
                  maxZoom: 19,
                ),
                if (_routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points:
                            _routePoints,
                        strokeWidth: 5,
                        color:
                            AppColors.lime,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        point:
                            LatLng(
                          _currentPosition!
                              .latitude,
                          _currentPosition!
                              .longitude,
                        ),
                        width: 42,
                        height: 42,
                        child:
                            _mapMarker(
                          icon:
                              Icons.my_location,
                          background:
                              Colors.blueAccent,
                        ),
                      ),
                    if (_pickupPoint != null)
                      Marker(
                        point:
                            _pickupPoint!,
                        width: 50,
                        height: 50,
                        child:
                            _mapMarker(
                          icon:
                              Icons.my_location,
                          background:
                              AppColors.lime,
                          darkIcon: true,
                        ),
                      ),
                    if (_destinationPoint != null)
                      Marker(
                        point:
                            _destinationPoint!,
                        width: 50,
                        height: 50,
                        child:
                            _mapMarker(
                          icon:
                              Icons.location_on,
                          background:
                              Colors.redAccent,
                        ),
                      ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Column(
                children: [
                  _mapButton(
                    icon:
                        Icons.my_location,
                    onTap: () =>
                        _getCurrentLocation(
                      showMessage: true,
                      centerMap: true,
                      autoSetPickup: false,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _mapButton(
                    icon: Icons.add,
                    onTap: () {
                      try {
                        final camera =
                            _mapController
                                .camera;

                        _mapController
                            .move(
                          camera.center,
                          (camera.zoom +
                                  1)
                              .clamp(
                            1.0,
                            19.0,
                          ),
                        );
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _mapButton(
                    icon:
                        Icons.remove,
                    onTap: () {
                      try {
                        final camera =
                            _mapController
                                .camera;

                        _mapController
                            .move(
                          camera.center,
                          (camera.zoom -
                                  1)
                              .clamp(
                            1.0,
                            19.0,
                          ),
                        );
                      } catch (_) {}
                    },
                  ),
                ],
              ),
            ),
            if (_loadingRoute)
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.black
                        .withValues(
                      alpha: 0.78,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 15,
                        height: 15,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              AppColors.lime,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'نحسب المسار...',
                        style:
                            TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withValues(
                    alpha: 0.82,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.route_outlined,
                      color:
                          AppColors.lime,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        _distanceKm > 0
                            ? '${_distanceKm.toStringAsFixed(1)} كم • ${_durationMinutes.round()} دقيقة تقريبًا'
                            : _routeFailed
                                ? 'تعذر تحميل مسار الطريق'
                                : 'حدد الانطلاق والوجهة لحساب المسافة',
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
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
  }

  Widget _mapMarker({
    required IconData icon,
    required Color background,
    bool darkIcon = false,
  }) {
    return Container(
      decoration:
          BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 3),
            color: Colors.black45,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: darkIcon
            ? Colors.black
            : Colors.white,
        size: 24,
      ),
    );
  }

  Widget _mapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        child: Ink(
          width: 46,
          height: 46,
          decoration:
              BoxDecoration(
            color: Colors.black
                .withValues(
              alpha: 0.80,
            ),
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),
      child: Column(
        children: [
          _locationRow(
            icon:
                Icons.my_location,
            iconColor:
                AppColors.lime,
            title:
                'نقطة الانطلاق',
            value:
                _pickupController
                    .text
                    .trim(),
            hint:
                'حدد مكان التقاطك',
            onTap: _choosePickup,
          ),
          Padding(
            padding:
                const EdgeInsets.only(
              right: 19,
              top: 5,
              bottom: 5,
            ),
            child:
                Align(
              alignment:
                  Alignment.centerRight,
              child:
                  Container(
                width: 1,
                height: 18,
                color:
                    Colors.grey.shade700,
              ),
            ),
          ),
          _locationRow(
            icon:
                Icons.location_on,
            iconColor:
                Colors.redAccent,
            title:
                'الوجهة',
            value:
                _destinationController
                    .text
                    .trim(),
            hint:
                'حدد المكان الذي تريد الوصول إليه',
            onTap:
                _chooseDestination,
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final hasValue =
        value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      child: Padding(
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 5,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(
                color: iconColor
                    .withValues(
                  alpha: 0.12,
                ),
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 21,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        TextStyle(
                      color: Colors
                          .grey
                          .shade500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    hasValue
                        ? value
                        : hint,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        TextStyle(
                      color: hasValue
                          ? Colors.white
                          : Colors.grey
                              .shade600,
                      fontSize: 14,
                      fontWeight:
                          hasValue
                              ? FontWeight
                                  .w600
                              : FontWeight
                                  .normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            const Icon(
              Icons.chevron_left,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          AppText.t('نوع المركبة'),
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        ..._vehicleOptions.entries
            .map(
          (entry) {
            final name =
                entry.key;
            final option =
                entry.value;
            final selected =
                _selectedVehicle ==
                    name;

            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedVehicle =
                        name;

                    if (_passengers >
                        option.capacity) {
                      _passengers =
                          option.capacity;
                    }
                  });
                },
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                child:
                    AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds:
                        180,
                  ),
                  padding:
                      const EdgeInsets
                          .all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? AppColors
                            .lime
                            .withValues(
                            alpha: 0.10,
                          )
                        : AppColors
                            .surface,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    border:
                        Border.all(
                      color: selected
                          ? AppColors
                              .lime
                          : Colors.white
                              .withValues(
                              alpha: 0.06,
                            ),
                      width: selected
                          ? 1.4
                          : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration:
                            BoxDecoration(
                          color: selected
                              ? AppColors
                                  .lime
                                  .withValues(
                                  alpha:
                                      0.15,
                                )
                              : Colors.white
                                  .withValues(
                                  alpha:
                                      0.05,
                                ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                        child: Icon(
                          option.icon,
                          color: selected
                              ? AppColors
                                  .lime
                              : Colors
                                  .grey
                                  .shade400,
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              AppText.t(name),
                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color: selected
                                    ? AppColors
                                        .lime
                                    : Colors
                                        .white,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              '${AppText.t(option.description)} • ${AppText.t('حتى')} ${option.capacity} ${AppText.t('ركاب')}',
                              style:
                                  TextStyle(
                                color: Colors
                                    .grey
                                    .shade500,
                                fontSize:
                                    12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons
                                .check_circle
                            : Icons
                                .radio_button_unchecked,
                        color: selected
                            ? AppColors
                                .lime
                            : Colors
                                .grey
                                .shade700,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPassengersSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'عدد الركاب',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          decoration:
              BoxDecoration(
            color:
                AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.people_outline,
                color:
                    AppColors.lime,
              ),
              const SizedBox(
                width: 14,
              ),
              const Expanded(
                child: Text(
                  'عدد الركاب',
                  style:
                      TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ),
              _counter(
                icon:
                    Icons.remove,
                enabled:
                    _passengers > 1,
                onTap: () {
                  if (_passengers >
                      1) {
                    setState(() {
                      _passengers--;
                    });
                  }
                },
              ),
              SizedBox(
                width: 42,
                child: Center(
                  child: Text(
                    '$_passengers',
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
              ),
              _counter(
                icon:
                    Icons.add,
                enabled:
                    _passengers <
                        _selectedCapacity,
                onTap: () {
                  if (_passengers <
                      _selectedCapacity) {
                    setState(() {
                      _passengers++;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _counter({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
          enabled ? onTap : null,
      borderRadius:
          BorderRadius.circular(
        10,
      ),
      child: Container(
        width: 36,
        height: 36,
        decoration:
            BoxDecoration(
          color: enabled
              ? AppColors
                  .lime
                  .withValues(
                  alpha: 0.12,
                )
              : Colors.white
                  .withValues(
                  alpha: 0.04,
                ),
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.lime
              : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'ملاحظات للسائق',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        TextField(
          controller:
              _notesController,
          maxLines: 3,
          textDirection:
              TextDirection.rtl,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration:
              InputDecoration(
            hintText:
                'مثلاً: سأكون أمام البوابة الرئيسية',
            hintStyle:
                TextStyle(
              color:
                  Colors.grey.shade600,
            ),
            filled: true,
            fillColor:
                AppColors.surface,
            prefixIcon:
                const Padding(
              padding:
                  EdgeInsets.only(
                left: 12,
                right: 10,
                top: 12,
              ),
              child:
                  Icon(
                Icons
                    .notes_outlined,
                color:
                    Colors.grey,
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(
              minWidth: 45,
              minHeight: 45,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              borderSide:
                  BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFareCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        color: AppColors.lime,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .payments_outlined,
            color:
                Colors.black,
          ),
          const SizedBox(
            width: 10,
          ),
          const Expanded(
            child: Text(
              'السعر التقديري',
              style:
                  TextStyle(
                color:
                    Colors.black,
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          Text(
            _distanceKm > 0
                ? '${_estimatedFare.round()} جنيه'
                : 'بانتظار المسافة',
            style:
                const TextStyle(
              color:
                  Colors.black,
              fontSize: 18,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Directionality(
      textDirection:
          TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            AppColors.background,
        appBar: AppBar(
          backgroundColor:
              AppColors.background,
          elevation: 0,
          title:
              const Text(
            'رحلة داخل المدينة',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets
                    .fromLTRB(
              16,
              8,
              16,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'اطلب رحلتك داخل المدينة',
                            style:
                                TextStyle(
                              fontSize:
                                  21,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'حدد الانطلاق والوجهة وسنحسب المسافة والسعر التقديري.',
                            style:
                                TextStyle(
                              color: Colors
                                  .grey
                                  .shade500,
                              fontSize:
                                  12,
                              height:
                                  1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .lime
                            .withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .local_taxi_outlined,
                        color:
                            AppColors
                                .lime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                _buildMap(),
                const SizedBox(
                  height: 16,
                ),
                _buildLocationCard(),
                const SizedBox(
                  height: 24,
                ),
                _buildVehicleSection(),
                const SizedBox(
                  height: 14,
                ),
                _buildPassengersSection(),
                const SizedBox(
                  height: 24,
                ),
                _buildNotesSection(),
                const SizedBox(
                  height: 24,
                ),
                _buildFareCard(),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width:
                      double.infinity,
                  height: 56,
                  child:
                      ElevatedButton(
                    onPressed:
                        _submitRide,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors
                              .lime,
                      foregroundColor:
                          Colors.black,
                      elevation:
                          0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          17,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'طلب الرحلة',
                      style:
                          TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );
  }

  Future<void> _showActionDialog({
    required String title,
    required String message,
    required String actionText,
    required Future<void> Function()
        action,
  }) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder:
          (context) {
        return Directionality(
          textDirection:
              TextDirection.rtl,
          child:
              AlertDialog(
            backgroundColor:
                AppColors.surface,
            title:
                Text(title),
            content:
                Text(
              message,
              style:
                  TextStyle(
                color: Colors
                    .grey
                    .shade400,
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.pop(
                  context,
                ),
                child:
                    const Text(
                  'إلغاء',
                ),
              ),
              ElevatedButton(
                onPressed:
                    () async {
                  Navigator.pop(
                    context,
                  );
                  await action();
                },
                child: Text(
                  actionText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VehicleOption {
  const _VehicleOption({
    required this.icon,
    required this.description,
    required this.capacity,
  });

  final IconData icon;
  final String description;
  final int capacity;
}

class _MapSelection {
  const _MapSelection({
    required this.point,
    required this.label,
  });

  final LatLng point;
  final String label;
}

class _PlaceResult {
  const _PlaceResult({
    required this.point,
    required this.label,
  });

  final LatLng point;
  final String label;
}

class _LocationPickerSheet
    extends StatefulWidget {
  const _LocationPickerSheet({
    required this.title,
    required this.initialCenter,
    required this.initialLabel,
    required this.accentColor,
    required this.showCurrentLocation,
  });

  final String title;
  final LatLng initialCenter;
  final String initialLabel;
  final Color accentColor;
  final bool showCurrentLocation;

  @override
  State<_LocationPickerSheet> createState() =>
      _LocationPickerSheetState();
}

class _LocationPickerSheetState
    extends State<_LocationPickerSheet> {
  final MapController _mapController =
      MapController();

  final TextEditingController
      _searchController =
      TextEditingController();

  Timer? _searchTimer;

  List<_PlaceResult> _results =
      <_PlaceResult>[];

  LatLng _mapCenter =
      const LatLng(
    15.5007,
    32.5599,
  );

  String? _selectedLabel;

  bool _searching = false;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();

    _mapCenter =
        widget.initialCenter;

    final initialLabel =
        widget.initialLabel.trim();

    if (initialLabel.isNotEmpty) {
      _selectedLabel =
          initialLabel;
      _searchController.text =
          initialLabel;
    }

    _searchController.addListener(
      _onSearchChanged,
    );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController
        .removeListener(
      _onSearchChanged,
    );
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchTimer?.cancel();

    final query =
        _searchController.text.trim();

    if (query.length < 2) {
      if (mounted) {
        setState(() {
          _results =
              <_PlaceResult>[];
          _searching = false;
        });
      }

      return;
    }

    _searchTimer = Timer(
      const Duration(
        milliseconds: 1200,
      ),
      () => _searchPlaces(query),
    );
  }

  Future<void> _searchPlaces(
    String query,
  ) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _searching = true;
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'jsonv2',
          'addressdetails': '1',
          'limit': '5',
          'countrycodes': 'sd',
          'accept-language': 'ar',
        },
      );

      final response = await http.get(
        uri,
        headers: const {
          'User-Agent':
              'WASEL Flutter App/1.0',
          'Accept':
              'application/json',
        },
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          _results =
              <_PlaceResult>[];
        });

        return;
      }

      final decoded =
          jsonDecode(response.body);

      if (decoded is! List) {
        setState(() {
          _results =
              <_PlaceResult>[];
        });

        return;
      }

      final found =
          <_PlaceResult>[];

      for (final item in decoded) {
        if (item
            is! Map<String, dynamic>) {
          continue;
        }

        final latitudeText =
            item['lat'];

        final longitudeText =
            item['lon'];

        final displayName =
            item['display_name'];

        if (latitudeText is! String ||
            longitudeText is! String ||
            displayName is! String) {
          continue;
        }

        final latitude =
            double.tryParse(
          latitudeText,
        );

        final longitude =
            double.tryParse(
          longitudeText,
        );

        if (latitude == null ||
            longitude == null) {
          continue;
        }

        found.add(
          _PlaceResult(
            point: LatLng(
              latitude,
              longitude,
            ),
            label: displayName,
          ),
        );
      }

      setState(() {
        _results = found;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _results =
              <_PlaceResult>[];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  Future<void> _useCurrentLocation()
      async {
    if (_gettingLocation) {
      return;
    }

    setState(() {
      _gettingLocation = true;
    });

    try {
      final serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        await _showSimpleMessage(
          'فعّل خدمة الموقع أولاً.',
        );
        return;
      }

      LocationPermission
          permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
          LocationPermission.denied) {
        await _showSimpleMessage(
          'تم رفض صلاحية الموقع.',
        );
        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        await _showSimpleMessage(
          'صلاحية الموقع مرفوضة بشكل دائم. افتح إعدادات التطبيق.',
        );
        return;
      }

      final position =
          await Geolocator
              .getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy:
              LocationAccuracy.high,
        ),
      );

      final point =
          LatLng(
        position.latitude,
        position.longitude,
      );

      final label =
          await _reverseGeocode(
        point,
      );

      if (!mounted) {
        return;
      }

      _moveMapTo(
        point,
        16,
      );

      setState(() {
        _mapCenter = point;
        _selectedLabel =
            label ?? 'موقعي الحالي';
        _results =
            <_PlaceResult>[];
      });

      _searchController.text =
          label ?? 'موقعي الحالي';

      FocusScope.of(context)
          .unfocus();
    } catch (_) {
      await _showSimpleMessage(
        'تعذر الحصول على موقعك الحالي.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _gettingLocation = false;
        });
      }
    }
  }

  Future<String?> _reverseGeocode(
    LatLng point,
  ) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'lat':
              point.latitude.toString(),
          'lon':
              point.longitude.toString(),
          'format': 'jsonv2',
          'accept-language': 'ar',
          'zoom': '18',
        },
      );

      final response =
          await http.get(
        uri,
        headers: const {
          'User-Agent':
              'WASEL Flutter App/1.0',
          'Accept':
              'application/json',
        },
      );

      if (response.statusCode !=
          200) {
        return null;
      }

      final decoded =
          jsonDecode(response.body);

      if (decoded
          is! Map<String, dynamic>) {
        return null;
      }

      final displayName =
          decoded['display_name'];

      if (displayName is String &&
          displayName.trim().isNotEmpty) {
        return displayName.trim();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  void _selectSearchResult(
    _PlaceResult result,
  ) {
    _searchController.text =
        result.label;

    FocusScope.of(context)
        .unfocus();

    _moveMapTo(
      result.point,
      16,
    );

    setState(() {
      _mapCenter =
          result.point;
      _selectedLabel =
          result.label;
      _results =
          <_PlaceResult>[];
    });
  }

  void _moveMapTo(
    LatLng point,
    double zoom,
  ) {
    try {
      _mapController.move(
        point,
        zoom,
      );
    } catch (_) {}
  }

  void _confirmLocation() {
    final label =
        _selectedLabel?.trim();

    final finalLabel =
        (label == null ||
                label.isEmpty)
            ? 'الموقع المحدد على الخريطة'
            : label;

    Navigator.pop(
      context,
      _MapSelection(
        point: _mapCenter,
        label: finalLabel,
      ),
    );
  }

  Future<void> _showSimpleMessage(
    String message,
  ) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder:
          (context) {
        return Directionality(
          textDirection:
              TextDirection.rtl,
          child:
              AlertDialog(
            backgroundColor:
                AppColors.surface,
            content:
                Text(message),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.pop(
                  context,
                ),
                child:
                    const Text(
                  'حسنًا',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller:
          _searchController,
      textDirection:
          TextDirection.rtl,
      style:
          const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration:
          InputDecoration(
        hintText:
            'ابحث عن حي أو شارع أو مكان...',
        hintStyle:
            TextStyle(
          color:
              Colors.grey.shade600,
          fontSize: 13,
        ),
        prefixIcon:
            const Icon(
          Icons.search,
          color:
              AppColors.lime,
        ),
        suffixIcon:
            _searchController
                    .text
                    .trim()
                    .isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController
                          .clear();

                      setState(() {
                        _results =
                            <_PlaceResult>[];
                        _selectedLabel =
                            null;
                      });
                    },
                    icon:
                        const Icon(
                      Icons.close,
                      size: 18,
                    ),
                  ),
        filled: true,
        fillColor:
            Colors.black
                .withValues(
          alpha: 0.18,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            17,
          ),
          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searching) {
      return Container(
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 18,
        ),
        alignment:
            Alignment.center,
        child:
            const CircularProgressIndicator(
          color:
              AppColors.lime,
          strokeWidth: 2,
        ),
      );
    }

    if (_results.isEmpty) {
      return const SizedBox
          .shrink();
    }

    return Container(
      margin:
          const EdgeInsets.only(
        top: 8,
      ),
      constraints:
          const BoxConstraints(
        maxHeight: 190,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border:
            Border.all(
          color: Colors.white
              .withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child:
          ListView.separated(
        shrinkWrap: true,
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 5,
        ),
        itemCount:
            _results.length,
        separatorBuilder:
            (_, _) =>
                Divider(
          height: 1,
          color: Colors.white
              .withValues(
            alpha: 0.06,
          ),
        ),
        itemBuilder:
            (context, index) {
          final result =
              _results[index];

          return ListTile(
            dense: true,
            onTap: () =>
                _selectSearchResult(
              result,
            ),
            leading:
                const Icon(
              Icons
                  .location_on_outlined,
              color:
                  AppColors.lime,
            ),
            title:
                Text(
              result.label,
              maxLines: 2,
              overflow:
                  TextOverflow
                      .ellipsis,
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPickerMap() {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      child: SizedBox(
        height: 420,
        child: Stack(
          children: [
            FlutterMap(
              mapController:
                  _mapController,
              options:
                  MapOptions(
                initialCenter:
                    widget.initialCenter,
                initialZoom: 15,
                minZoom: 5,
                maxZoom: 19,
                onPositionChanged:
                    (camera, _) {
                  final newCenter =
                      camera.center;

                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _mapCenter =
                        newCenter;
                    _selectedLabel =
                        null;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.wasel_new',
                  maxNativeZoom: 19,
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point:
                          _mapCenter,
                      width: 60,
                      height: 60,
                      child:
                          IgnorePointer(
                        child:
                            Center(
                          child:
                              Container(
                            width: 44,
                            height: 44,
                            decoration:
                                BoxDecoration(
                              color: widget
                                  .accentColor
                                  .withValues(
                                alpha:
                                    0.14,
                              ),
                              shape: BoxShape
                                  .circle,
                              border:
                                  Border.all(
                                color:
                                    widget
                                        .accentColor,
                                width:
                                    2,
                              ),
                            ),
                            child:
                                Icon(
                              widget.accentColor ==
                                      Colors
                                          .redAccent
                                  ? Icons
                                      .location_on
                                  : Icons
                                      .my_location,
                              color: widget
                                  .accentColor,
                              size:
                                  24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 14,
              right: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withValues(
                    alpha: 0.76,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child:
                    const Text(
                  'حرّك الخريطة وضع النقطة المطلوبة في الوسط',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (widget
                .showCurrentLocation)
              Positioned(
                right: 14,
                bottom: 72,
                child: Material(
                  color:
                      Colors.transparent,
                  child: InkWell(
                    onTap:
                        _useCurrentLocation,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    child:
                        Ink(
                      width: 48,
                      height: 48,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.black
                                .withValues(
                          alpha:
                              0.82,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      child:
                          _gettingLocation
                              ? const Padding(
                                  padding:
                                      EdgeInsets.all(
                                    14,
                                  ),
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        AppColors.lime,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .my_location,
                                  color:
                                      AppColors.lime,
                                ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withValues(
                    alpha: 0.82,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .place_outlined,
                      color:
                          widget
                              .accentColor,
                      size: 21,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                          Text(
                        _selectedLabel ??
                            'حرك الخريطة لاختيار الموقع',
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
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
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Directionality(
      textDirection:
          TextDirection.rtl,
      child:
          FractionallySizedBox(
        heightFactor: 0.94,
        child: Container(
          decoration:
              const BoxDecoration(
            color:
                AppColors.surface,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(
                28,
              ),
            ),
          ),
          child:
              ListView(
            padding:
                const EdgeInsets
                    .fromLTRB(
              16,
              12,
              16,
              24,
            ),
            children: [
              Center(
                child:
                    Container(
                  width: 46,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .grey
                        .shade700,
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Text(
                widget.title,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              _buildSearchField(),
              _buildSearchResults(),
              const SizedBox(
                height: 12,
              ),
              _buildPickerMap(),
              const SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(
                        context,
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            Colors.white,
                        minimumSize:
                            const Size
                                .fromHeight(
                          54,
                        ),
                        side:
                            BorderSide(
                          color: Colors
                              .grey
                              .shade700,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'إلغاء',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child:
                        ElevatedButton(
                      onPressed:
                          _confirmLocation,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            widget
                                .accentColor,
                        foregroundColor:
                            widget.accentColor ==
                                    Colors
                                        .redAccent
                                ? Colors.white
                                : Colors.black,
                        minimumSize:
                            const Size
                                .fromHeight(
                          54,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'تأكيد الموقع',
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}