import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/network/ride_market_service.dart';
import '../../../core/network/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../city/city_ride_request.dart';

class DriverOffersScreen extends StatefulWidget {
  const DriverOffersScreen({super.key});

  @override
  State<DriverOffersScreen> createState() => _DriverOffersScreenState();
}

class _DriverOffersScreenState extends State<DriverOffersScreen> {
  Timer? _timer;

  String? _rideId;
  CityRideRequest? _request;

  bool _isLoading = true;
  bool _isAccepting = false;

  List<Map<String, dynamic>> _offers = <Map<String, dynamic>>[];

  bool get _isEnglish => AppLocale.isEnglish;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readRouteData();
      _loadOffers();
    });

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadOffers(silent: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _readRouteData() {
    final state = GoRouterState.of(context);
    _rideId = state.uri.queryParameters['rideId'];

    final extra = state.extra;

    if (extra is CityRideRequest) {
      _request = extra;
      return;
    }

    if (extra is Map) {
      _rideId ??= extra['rideId']?.toString();
      final value = extra['request'];

      if (value is CityRideRequest) {
        _request = value;
      }
    }
  }

  Future<void> _loadOffers({bool silent = false}) async {
    final rideId = _rideId;

    if (rideId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final offers = await RideMarketService.listOffers(
        rideId: rideId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted && !silent) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptOffer(
    Map<String, dynamic> offer,
  ) async {
    if (_isAccepting) {
      return;
    }

    setState(() {
      _isAccepting = true;
    });

    try {
      final success = await RideMarketService.acceptOffer(
        offerId: offer['id'].toString(),
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showMessage(
          _isEnglish
              ? 'Unable to accept this offer.'
              : 'تعذر قبول هذا العرض.',
        );
        return;
      }

      _showMessage(
        _isEnglish
            ? 'Offer accepted. Your driver is on the way.'
            : 'تم قبول العرض. السائق في طريقه إليك.',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) {
        return;
      }

      context.go('/ride-status');
    } catch (_) {
      if (mounted) {
        _showMessage(
          _isEnglish
              ? 'This offer is no longer available.'
              : 'هذا العرض لم يعد متاحاً.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> _cancelRide() async {
    final client = SupabaseService.client;
    final rideId = _rideId;
    final userId = client?.auth.currentUser?.id;

    if (client == null || rideId == null || userId == null) {
      return;
    }

    try {
      await client
          .from('rides')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', rideId)
          .eq('passenger_id', userId);
    } catch (_) {
      // Keep the waiting screen usable if cancellation fails.
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          _isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            _isEnglish ? 'Driver offers' : 'عروض السائقين',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _loadOffers,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            children: [
              if (_request != null) _buildRequestSummary(_request!),
              const SizedBox(height: 14),
              _buildWaitingBanner(),
              const SizedBox(height: 16),
              if (_isLoading && _offers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 70),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lime,
                    ),
                  ),
                )
              else if (_offers.isEmpty)
                _buildNoOffers()
              else
                ..._offers.map(_buildOfferCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestSummary(CityRideRequest request) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEnglish ? 'Ride request sent' : 'تم إرسال طلب الرحلة',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${request.pickupLabel}  →  ${request.destinationLabel}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${request.estimatedFare.round()} ${_isEnglish ? 'SDG estimated' : 'جنيه تقديري'}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingBanner() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.lime,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _isEnglish
                  ? 'Waiting for nearby drivers. New offers will appear automatically.'
                  : 'في انتظار السائقين القريبين. العروض الجديدة ستظهر تلقائياً.',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final status = offer['status']?.toString() ?? 'pending';
    final fare = _number(offer['proposed_fare']).round();
    final name = offer['driver_name']?.toString().trim();
    final phone = offer['driver_phone']?.toString().trim();
    final accepted = status == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accepted
              ? AppColors.lime.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.lime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (name?.isNotEmpty ?? false)
                          ? name!
                          : (_isEnglish ? 'Driver' : 'سائق'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (phone?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone!,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '$fare ${_isEnglish ? 'SDG' : 'جنيه'}',
                style: const TextStyle(
                  color: AppColors.lime,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (accepted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isEnglish ? 'Accepted offer' : 'العرض المقبول',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isAccepting
                    ? null
                    : () => _acceptOffer(offer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isAccepting
                      ? (_isEnglish ? 'Accepting...' : 'جارٍ القبول...')
                      : (_isEnglish
                          ? 'Accept this offer'
                          : 'قبول هذا العرض'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoOffers() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 40, 22, 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.directions_car_outlined,
            color: AppColors.lime,
            size: 50,
          ),
          const SizedBox(height: 15),
          Text(
            _isEnglish ? 'No offers yet' : 'لا توجد عروض بعد',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isEnglish
                ? 'Keep the request open. Nearby drivers can see it and send their fares.'
                : 'خلي الطلب مفتوحاً. السائقون القريبون يمكنهم مشاهدة الطلب وإرسال أسعارهم.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () async {
              await _cancelRide();

              if (!mounted) {
                return;
              }

              context.go('/home');
            },
            child: Text(
              _isEnglish ? 'Cancel request' : 'إلغاء الطلب',
            ),
          ),
        ],
      ),
    );
  }
}