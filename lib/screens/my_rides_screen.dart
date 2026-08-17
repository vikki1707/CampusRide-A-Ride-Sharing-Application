import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Your bottom-tabbed main screen

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({Key? key}) : super(key: key);

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final amber = Colors.amber[700];

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Rides"),
          backgroundColor: amber,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: Text("Please log in to view your rides.")),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Rides"),
          backgroundColor: amber,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
              );
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rides')
              .where('userId', isEqualTo: user!.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No rides posted yet.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            }

            final rides = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                final source = ride['sourceName'] ?? '';
                final destination = ride['destinationName'] ?? '';
                final totalFare = ride['totalFare']?.toDouble() ?? 0.0;
                final passengerCount = ride['passengerCount'] ?? 1;
                final farePerPerson = ride['farePerPerson']?.toDouble() ?? 0.0;
                final timestamp = ride['createdAt'] as Timestamp?;
                final dateTime = timestamp?.toDate();

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("From: $source",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("To: $destination",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text("Total Fare: ₹${totalFare.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 14)),
                        Text("Passengers: $passengerCount",
                            style: const TextStyle(fontSize: 14)),
                        Text(
                            "Fare Per Person: ₹${farePerPerson.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 14)),
                        if (dateTime != null)
                          Text("Posted on: ${dateTime.toLocal()}",
                              style:  TextStyle(
                                  fontSize: 12, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
