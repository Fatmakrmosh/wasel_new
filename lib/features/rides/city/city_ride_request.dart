import 'package:latlong2/latlong.dart';

class CityRideRequest {
  const CityRideRequest({
    required this.pickupLabel,
    required this.destinationLabel,
    required this.pickupPoint,
    required this.destinationPoint,
    required this.distanceKm,
    required this.durationMinutes,
    required this.estimatedFare,
    required this.vehicleType,
    required this.passengers,
    required this.notes,
  });

  final String pickupLabel;
  final String destinationLabel;

  final LatLng pickupPoint;
  final LatLng destinationPoint;

  final double distanceKm;
  final double durationMinutes;

  final double estimatedFare;

  final String vehicleType;
  final int passengers;

  final String notes;
}