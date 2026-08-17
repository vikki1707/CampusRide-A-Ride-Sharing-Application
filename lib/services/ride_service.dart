import 'package:cloud_firestore/cloud_firestore.dart';

class RideService {
  final CollectionReference ridesCollection =
  FirebaseFirestore.instance.collection('rides');

  /// Post a ride
  Future<void> postRide({
    required String driverId,
    required String driverName,
    required String source,
    required String destination,
    required String date,
    required String time,
    required int seatsAvailable,
  }) async {
    await ridesCollection.add({
      'driverId': driverId,
      'driverName': driverName,
      'source': source,
      'destination': destination,
      'date': date,
      'time': time,
      'seatsAvailable': seatsAvailable,
      'requests': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all rides (for Find Ride screen)
  Stream<QuerySnapshot> getRides() {
    return ridesCollection.orderBy('createdAt', descending: true).snapshots();
  }

  /// Request a ride
  Future<void> requestRide(String rideId, String userId, String userName) async {
    final doc = ridesCollection.doc(rideId);
    await doc.update({
      'requests': FieldValue.arrayUnion([
        {"userId": userId, "userName": userName}
      ])
    });
  }
}
