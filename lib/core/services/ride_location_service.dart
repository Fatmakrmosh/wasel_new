import 'package:supabase_flutter/supabase_flutter.dart';

class RideLocationService {
  RideLocationService._();

  static final RideLocationService instance = RideLocationService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updateDriverLocation({
    required String rideId,
    required String driverId,
    required double latitude,
    required double longitude,
    double heading = 0,
    double speed = 0,
  }) async {
    await _supabase.from('ride_driver_locations').upsert(
      {
        'ride_id': rideId,
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'speed': speed,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'ride_id,driver_id',
    );
  }

  Stream<Map<String, dynamic>> watchRideLocation(String rideId) {
    return _supabase
        .from('ride_driver_locations')
        .stream(primaryKey: ['ride_id', 'driver_id'])
        .eq('ride_id', rideId)
        .map((rows) {
          if (rows.isEmpty) {
            return <String, dynamic>{};
          }

          return rows.first;
        });
  }

  Future<Map<String, dynamic>?> getRideLocation(String rideId) async {
    final response = await _supabase
        .from('ride_driver_locations')
        .select()
        .eq('ride_id', rideId)
        .maybeSingle();

    return response;
  }

  Future<void> removeRideLocation(String rideId) async {
    await _supabase
        .from('ride_driver_locations')
        .delete()
        .eq('ride_id', rideId);
  }
}