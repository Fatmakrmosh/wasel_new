import 'package:supabase_flutter/supabase_flutter.dart';

class DriverLocationService {
  DriverLocationService._();

  static final SupabaseClient _client =
      Supabase.instance.client;

  static Future<void> updateLocation({
    required String rideId,
    required String driverId,
    required double latitude,
    required double longitude,
    double heading = 0,
    double speed = 0,
  }) async {
    await _client
        .from('ride_driver_locations')
        .upsert(
          {
            'ride_id': rideId,
            'driver_id': driverId,
            'latitude': latitude,
            'longitude': longitude,
            'heading': heading,
            'speed': speed,
            'updated_at':
                DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'ride_id,driver_id',
        );
  }

  static Future<void> removeLocation({
    required String rideId,
  }) async {
    await _client
        .from('ride_driver_locations')
        .delete()
        .eq('ride_id', rideId);
  }

  static Stream<Map<String, dynamic>?> watchLocation({
    required String rideId,
  }) {
    return _client
        .from('ride_driver_locations')
        .stream(
          primaryKey: const [
            'ride_id',
            'driver_id',
          ],
        )
        .eq('ride_id', rideId)
        .map(
          (rows) => rows.isEmpty ? null : rows.first,
        );
  }

  static Future<Map<String, dynamic>?> getLocation({
    required String rideId,
  }) async {
    return await _client
        .from('ride_driver_locations')
        .select()
        .eq('ride_id', rideId)
        .maybeSingle();
  }
}