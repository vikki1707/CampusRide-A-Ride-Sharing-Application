import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final ridesCollection = FirebaseFirestore.instance.collection('rides');

  // Fetch all rides
  final snapshot = await ridesCollection.get();

  for (var doc in snapshot.docs) {
    try {
      final sourceLat = (doc['sourceLat'] as num).toDouble();
      final sourceLng = (doc['sourceLng'] as num).toDouble();
      final destinationLat = (doc['destinationLat'] as num).toDouble();
      final destinationLng = (doc['destinationLng'] as num).toDouble();

      final sourceGeohash = GeoHash.encode(sourceLat, sourceLng, precision: 8);
      final destinationGeohash = GeoHash.encode(destinationLat, destinationLng, precision: 8);

      // Update Firestore document
      await doc.reference.update({
        'sourceGeohash': sourceGeohash,
        'destinationGeohash': destinationGeohash,
      });

      print('Updated ride ${doc.id}');
    } catch (e) {
      print('Failed to update ride ${doc.id}: $e');
    }
  }

  print('All rides updated with geohash!');
}
