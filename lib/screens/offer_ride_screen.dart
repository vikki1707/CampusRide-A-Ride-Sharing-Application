import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/fare_calculator.dart';
import 'map_picker_screen.dart';
import 'my_rides_screen.dart'; // Make sure you have this screen
import 'ride_success_screen.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({Key? key}) : super(key: key);

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  LatLng? _sourceLatLng;
  LatLng? _destinationLatLng;
  double? _totalFare;
  int _passengerCount = 1;

  // --- Calculate total and per-person fare ---
  void _calculateFare() {
    if (_sourceLatLng != null && _destinationLatLng != null) {
      final fare = FareCalculator.calculateFare(_sourceLatLng!, _destinationLatLng!);
      setState(() {
        _totalFare = fare;
      });
    }
  }

  // --- Open Map Picker ---
  Future<void> _pickLocation({required bool isSource}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );

    if (result != null && result is LatLng) {
      setState(() {
        if (isSource) {
          _sourceLatLng = result;
        } else {
          _destinationLatLng = result;
        }
      });
      _calculateFare();
    }
  }

  // --- Store ride in Firebase Firestore ---
  Future<void> _postRide() async {
    if (_sourceLatLng == null || _destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both locations.")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to offer a ride.")),
      );
      return;
    }

    final perPersonFare = _totalFare != null ? _totalFare! / _passengerCount : 0;

    await FirebaseFirestore.instance.collection('rides').add({
      'userId': user.uid,
      'userEmail': user.email,
      'sourceName': _sourceController.text,
      'destinationName': _destinationController.text,
      'sourceLat': _sourceLatLng!.latitude,
      'sourceLng': _sourceLatLng!.longitude,
      'destinationLat': _destinationLatLng!.latitude,
      'destinationLng': _destinationLatLng!.longitude,
      'totalFare': _totalFare,
      'passengerCount': _passengerCount,
      'farePerPerson': perPersonFare.toDouble(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Navigate to Success Screen instead of popping
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RideSuccessScreen(farePerPerson: perPersonFare.toDouble()),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final amber = Colors.amber[700];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Offer a Ride"),
        backgroundColor: amber,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source
                const Text("Source", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sourceController,
                        decoration: const InputDecoration(
                          hintText: "Enter source name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.map, color: Colors.amber),
                      onPressed: () => _pickLocation(isSource: true),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Destination
                const Text("Destination", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          hintText: "Enter destination name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.map, color: Colors.amber),
                      onPressed: () => _pickLocation(isSource: false),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Passenger Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Select passengers",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: _passengerCount,
                      items: List.generate(4, (index) {
                        final value = index + 1;
                        return DropdownMenuItem(
                          value: value,
                          child: Text("$value"),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _passengerCount = value ?? 1;
                          _calculateFare();
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Fare details
                if (_totalFare != null) ...[
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Total Fare: ₹${_totalFare!.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "Per Person: ₹${(_totalFare! / _passengerCount).toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // Post Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _postRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Post Ride",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Ride Posted Success Screen
class RidePostedSuccessScreen extends StatelessWidget {
  final double farePerPerson;

  const RidePostedSuccessScreen({Key? key, required this.farePerPerson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amber = Colors.amber[700];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                "Ride Posted Successfully!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Fare per person: ₹${farePerPerson.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MyRidesScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.directions_car),
                label: const Text(
                  "Back to My Rides",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
