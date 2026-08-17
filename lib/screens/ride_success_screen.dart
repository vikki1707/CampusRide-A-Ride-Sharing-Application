import 'package:flutter/material.dart';
import 'my_rides_screen.dart';

class RideSuccessScreen extends StatelessWidget {
  final double farePerPerson;

  const RideSuccessScreen({Key? key, required this.farePerPerson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amber = Colors.amber[700];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Posted!"),
        backgroundColor: amber,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              Text(
                "Ride offered successfully!\nFare per person ₹${farePerPerson.toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Pop all previous routes and go to MyRidesScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MyRidesScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Go to My Rides",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
