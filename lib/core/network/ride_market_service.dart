import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class RideMarketService {
  RideMarketService._();

  static SupabaseClient? get _client => SupabaseService.client;

  static Future<String?> createRideRequest({
    required double pickupLat,
    required double pickupLng,
    required double destinationLat,
    required double destinationLng,
    required String pickupAddress,
    required String destinationAddress,
    required String vehicleType,
    required int passengers,
    required double suggestedFare,
    required String notes,
  }) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      throw Exception('AUTH_REQUIRED');
    }

    try {
      final result = await client.rpc(
        'create_ride_request',
        params: {
          'p_pickup_lat': pickupLat,
          'p_pickup_lng': pickupLng,
          'p_destination_lat': destinationLat,
          'p_destination_lng': destinationLng,
          'p_pickup_address': pickupAddress,
          'p_destination_address': destinationAddress,
          'p_vehicle_type': vehicleType,
          'p_passengers': passengers,
          'p_suggested_fare': suggestedFare,
          'p_notes': notes,
        },
      );

      final rideId = result?.toString().trim();

      if (rideId == null || rideId.isEmpty) {
        throw Exception('تعذر إنشاء طلب الرحلة.');
      }

      return rideId;
    } on PostgrestException catch (error) {
      throw Exception(
        'تعذر إنشاء الطلب: ${error.message}'
        '${error.code == null ? '' : ' (${error.code})'}',
      );
    } catch (error) {
      throw Exception(
        'تعذر إنشاء طلب الرحلة: $error',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> listPendingRides() async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      return [];
    }

    final result = await client.rpc('driver_list_pending_rides');

    return (result as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<String?> submitOffer({
    required String rideId,
    required double proposedFare,
  }) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      throw Exception('AUTH_REQUIRED');
    }

    final result = await client.rpc(
      'submit_ride_offer',
      params: {
        'p_ride_id': rideId,
        'p_proposed_fare': proposedFare,
      },
    );

    return result?.toString();
  }

  static Future<List<Map<String, dynamic>>> listOffers({
    required String rideId,
  }) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      return [];
    }

    final result = await client.rpc(
      'passenger_list_ride_offers',
      params: {'p_ride_id': rideId},
    );

    return (result as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> acceptOffer({
    required String offerId,
  }) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      throw Exception('AUTH_REQUIRED');
    }

    final result = await client.rpc(
      'accept_ride_offer',
      params: {'p_offer_id': offerId},
    );

    return result == true;
  }
}
