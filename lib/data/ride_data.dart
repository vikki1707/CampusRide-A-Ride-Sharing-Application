// lib/data/ride_data.dart
class Ride {
  final String from;
  final String to;
  final DateTime dateTime;
  final int seats;
  final double price;
  final String vehicle;
  final bool trustedOnly;     // ✅ Trusted Circle toggle
  final String? eventTag;     // ✅ Event-centric rides (Exam, Fest, etc.)
  final double? distanceKm;   // ✅ To estimate CO₂ saved

  Ride({
    required this.from,
    required this.to,
    required this.dateTime,
    required this.seats,
    required this.price,
    required this.vehicle,
    this.trustedOnly = false,
    this.eventTag,
    this.distanceKm,
  });
}

class RideData {
  static final List<Ride> rides = [];

  static void addRide(Ride r) => rides.add(r);
  static List<Ride> all() => rides;
}
