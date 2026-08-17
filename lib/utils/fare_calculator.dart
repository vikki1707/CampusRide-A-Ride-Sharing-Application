import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class FareCalculator {
  /// Calculate approximate fare based on distance
  static double calculateFare(LatLng source, LatLng destination) {
    final double distance = _calculateDistance(
      source.latitude,
      source.longitude,
      destination.latitude,
      destination.longitude,
    );

    const double baseFare = 20.0; // base fare in ₹
    const double perKmFare = 10.0; // per km fare in ₹

    return baseFare + (distance * perKmFare);
  }

  // Haversine formula to calculate distance between two coordinates in km
  static double _calculateDistance(lat1, lon1, lat2, lon2) {
    const double R = 6371; // Radius of Earth in km
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);
    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
                sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = R * c;
    return distance;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);
}
