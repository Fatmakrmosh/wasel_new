import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_locale.dart';
import '../../core/network/driver_location_service.dart';
import '../../core/network/ride_market_service.dart';
import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class DriverMarketplaceScreen extends StatefulWidget {
  const DriverMarketplaceScreen({super.key});

  @override
  State<DriverMarketplaceScreen> createState() => _DriverMarketplaceScreenState();
}

class _DriverMarketplaceScreenState extends State<DriverMarketplaceScreen> {
  Timer? _refreshTimer;
  Timer? _locationTimer;
  bool _isAvailable = true;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _locationPermissionGranted = false;
  bool _locationServiceEnabled = false;
  Position? _currentPosition;
  String? _activeRideId;
  List<Map<String, dynamic>> _requests = [];

  bool get _isEnglish => AppLocale.isEnglish;

  @override
  void initState() {
    super.initState();
    _refreshAll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 6), (_) => _refreshAll(silent: true));
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshAll({bool silent = false}) async {
    if (!_isAvailable) {
      if (mounted && !silent) setState(() => _isLoading = false);
      return;
    }
    if (mounted && !silent) setState(() => _isLoading = true);
    try {
      final requests = await RideMarketService.listPendingRides();
      if (!mounted) return;
      setState(() { _requests = requests; _isLoading = false; });
      await _loadActiveRide();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadActiveRide() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;
    try {
      final response = await client.from('rides').select('id').eq('driver_id', user.id).inFilter('status', ['accepted', 'driver_arriving', 'in_progress']).order('updated_at', ascending: false).limit(1);
      final id = response.isEmpty ? null : response.first['id']?.toString();
      if (mounted && id != _activeRideId) setState(() => _activeRideId = id);
    } catch (_) {}
  }

  Future<void> _startLocationUpdates() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() { _locationServiceEnabled = false; _locationPermissionGranted = false; });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      final granted = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
      if (!mounted) return;
      setState(() { _locationServiceEnabled = true; _locationPermissionGranted = granted; });
      if (!granted) return;
      await _syncLocation();
      _locationTimer?.cancel();
      _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) => _syncLocation());
    } catch (_) {}
  }

  Future<void> _syncLocation() async {
    if (!_locationPermissionGranted) return;
    try {
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (!mounted) return;
      setState(() => _currentPosition = position);
      final activeRideId = _activeRideId;
      final driverId = SupabaseService.client?.auth.currentUser?.id;
      if (activeRideId != null && driverId != null) {
        await DriverLocationService.updateLocation(rideId: activeRideId, driverId: driverId, latitude: position.latitude, longitude: position.longitude, heading: position.heading, speed: position.speed);
      }
    } catch (_) {}
  }

  Future<void> _setAvailability(bool value) async {
    setState(() => _isAvailable = value);
    if (value) await _refreshAll();
    else if (mounted) setState(() => _requests = []);
  }

  Future<void> _showOfferSheet(Map<String, dynamic> request) async {
    final controller = TextEditingController(text: _number(request['suggested_fare']).round().toString());
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Text(_isEnglish ? 'Submit your fare' : 'قدّم عرضك السعري', textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text((request['pickup_address']?.toString() ?? '') + '  →  ' + (request['destination_address']?.toString() ?? ''), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5)),
                const SizedBox(height: 20),
                TextField(controller: controller, autofocus: true, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _isEnglish ? 'Your fare' : 'السعر الذي تقترحه', suffixText: _isEnglish ? 'SDG' : 'جنيه', prefixIcon: const Icon(Icons.payments_outlined))),
                const SizedBox(height: 12),
                Text(_isEnglish ? 'Passenger suggested ' + _number(request['suggested_fare']).round().toString() + ' SDG.' : 'السعر التقديري للراكب ' + _number(request['suggested_fare']).round().toString() + ' جنيه.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 22),
                SizedBox(height: 54, child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    final fare = double.tryParse(controller.text.trim());
                    if (fare == null || fare <= 0) { _showMessage(_isEnglish ? 'Enter a valid fare.' : 'أدخل سعراً صحيحاً.'); return; }
                    setState(() => _isSubmitting = true);
                    try {
                      await RideMarketService.submitOffer(rideId: request['id'].toString(), proposedFare: fare);
                      if (!mounted) return;
                      Navigator.pop(sheetContext);
                      _showMessage(_isEnglish ? 'Your offer was sent successfully.' : 'تم إرسال عرضك السعري بنجاح.');
                      await _refreshAll();
                    } catch (_) {
                      if (mounted) _showMessage(_isEnglish ? 'This request is no longer available.' : 'هذا الطلب لم يعد متاحاً.');
                    } finally {
                      if (mounted) setState(() => _isSubmitting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(_isSubmitting ? (_isEnglish ? 'Sending...' : 'جارٍ الإرسال...') : (_isEnglish ? 'Send offer' : 'إرسال العرض'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                )),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return _isEnglish ? 'just now' : 'الآن';
    if (diff.inMinutes < 60) return _isEnglish ? diff.inMinutes.toString() + ' min ago' : 'منذ ' + diff.inMinutes.toString() + ' دقيقة';
    return _isEnglish ? diff.inHours.toString() + ' hr ago' : 'منذ ' + diff.inHours.toString() + ' ساعة';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, title: Text(_isEnglish ? 'Driver mode' : 'وضع السائق', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), actions: [
          IconButton(onPressed: () => context.push('/account-mode'), icon: const Icon(Icons.swap_horiz_rounded), tooltip: _isEnglish ? 'Switch mode' : 'تبديل الوضع'),
          IconButton(onPressed: () => context.push('/account'), icon: const Icon(Icons.account_circle_outlined)),
        ]),
        body: RefreshIndicator(
          color: AppColors.lime,
          backgroundColor: AppColors.surface,
          onRefresh: () => _refreshAll(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
            children: [
              _buildAvailabilityCard(),
              const SizedBox(height: 14),
              if (_activeRideId != null) ...[_buildActiveRideCard(), const SizedBox(height: 18)],
              _buildLocationCard(),
              const SizedBox(height: 24),
              Row(children: [Expanded(child: Text(_isEnglish ? 'Available ride requests' : 'طلبات الرحلات المتاحة', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), Text(_requests.length.toString(), style: const TextStyle(color: AppColors.lime, fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              if (!_isAvailable)
                _buildEmptyState(_isEnglish ? 'You are offline. Turn availability on to receive requests.' : 'أنت غير متاح حالياً. فعّل الحالة المتاحة لاستقبال الطلبات.')
              else if (_isLoading && _requests.isEmpty)
                const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator(color: AppColors.lime)))
              else if (_requests.isEmpty)
                _buildEmptyState(_isEnglish ? 'No requests right now. New requests will appear here automatically.' : 'لا توجد طلبات الآن. الطلبات الجديدة ستظهر هنا تلقائياً.')
              else
                ..._requests.map(_buildRequestCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _isAvailable ? AppColors.lime.withValues(alpha: 0.30) : Colors.white12)), child: Row(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: _isAvailable ? AppColors.lime.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.06), shape: BoxShape.circle), child: Icon(_isAvailable ? Icons.wifi_tethering_rounded : Icons.pause_circle_outline_rounded, color: _isAvailable ? AppColors.lime : Colors.white54, size: 28)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isAvailable ? (_isEnglish ? 'You are available' : 'أنت متاح الآن') : (_isEnglish ? 'You are offline' : 'أنت غير متاح'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(_isAvailable ? (_isEnglish ? 'Available requests will appear below.' : 'ستظهر طلبات الرحلات المتاحة أدناه.') : (_isEnglish ? 'Turn this on to receive new requests.' : 'فعّلها لاستقبال طلبات جديدة.'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ])),
      Switch(value: _isAvailable, activeThumbColor: AppColors.lime, activeTrackColor: AppColors.lime.withValues(alpha: 0.30), onChanged: _setAvailability),
    ]));
  }

  Widget _buildLocationCard() {
    final ready = _locationServiceEnabled && _locationPermissionGranted;
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: ready ? AppColors.lime.withValues(alpha: 0.22) : Colors.white10)), child: Row(children: [
      const Icon(Icons.gps_fixed_rounded, color: AppColors.lime, size: 25), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isEnglish ? 'Driver location' : 'موقع السائق', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(ready ? (_currentPosition == null ? (_isEnglish ? 'Waiting for GPS...' : 'في انتظار GPS...') : (_isEnglish ? 'GPS is active' : 'GPS يعمل')) : (_isEnglish ? 'Allow location to enable live tracking.' : 'اسمح بالموقع لتفعيل التتبع المباشر.'), style: TextStyle(color: ready ? AppColors.lime : Colors.orange, fontSize: 11)),
      ])),
      if (_currentPosition != null) Text(_currentPosition!.latitude.toStringAsFixed(3), style: const TextStyle(color: Colors.white38, fontSize: 10)),
    ]));
  }

  Widget _buildActiveRideCard() {
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: AppColors.lime.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.lime.withValues(alpha: 0.25))), child: Row(children: [
      const Icon(Icons.local_taxi_rounded, color: AppColors.lime, size: 30), const SizedBox(width: 12),
      Expanded(child: Text(_isEnglish ? 'You have an active ride.' : 'لديك رحلة نشطة حالياً.', style: const TextStyle(fontWeight: FontWeight.bold))),
      FilledButton(onPressed: () => context.push('/ride-status'), style: FilledButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: Colors.black), child: Text(_isEnglish ? 'Open' : 'فتح')),
    ]));
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final fare = _number(request['suggested_fare']).round();
    final passengers = request['passengers'] ?? 1;
    final vehicleType = request['vehicle_type']?.toString() ?? '';
    final notes = request['notes']?.toString() ?? '';
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.06))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const CircleAvatar(radius: 22, backgroundColor: Color(0x1FE0FF4F), child: Icon(Icons.person_outline_rounded, color: AppColors.lime)), const SizedBox(width: 10), Expanded(child: Text(_isEnglish ? 'Passenger request' : 'طلب راكب', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))), Text(fare.toString() + ' ' + (_isEnglish ? 'SDG' : 'جنيه'), style: const TextStyle(color: AppColors.lime, fontSize: 16, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 14),
      _routeRow(Icons.radio_button_checked, request['pickup_address']?.toString() ?? '', AppColors.lime),
      const SizedBox(height: 8),
      _routeRow(Icons.location_on_rounded, request['destination_address']?.toString() ?? '', Colors.redAccent),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [_chip(Icons.people_outline, passengers.toString()), if (vehicleType.isNotEmpty) _chip(Icons.directions_car_outlined, vehicleType), _chip(Icons.schedule, _formatDate(request['created_at']))]),
      if (notes.trim().isNotEmpty) ...[const SizedBox(height: 12), Text(notes, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5))],
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: () => _showOfferSheet(request), icon: const Icon(Icons.local_offer_outlined, size: 20), label: Text(_isEnglish ? 'Submit fare offer' : 'تقديم عرض سعري', style: const TextStyle(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
    ]));
  }

  Widget _routeRow(IconData icon, String text, Color color) => Row(children: [Icon(icon, color: color, size: 17), const SizedBox(width: 9), Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13)))]);
  Widget _chip(IconData icon, String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: Colors.white54), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white54, fontSize: 10))]));
  Widget _buildEmptyState(String message) => Container(padding: const EdgeInsets.fromLTRB(22, 36, 22, 36), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)), child: Column(children: [const Icon(Icons.radar_rounded, color: AppColors.lime, size: 48), const SizedBox(height: 14), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.6))]));
}