import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FindRideScreen extends StatefulWidget {
  const FindRideScreen({Key? key}) : super(key: key);

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String _filterSource = '';
  String _filterDestination = '';

  final amber = Colors.amber[700];

  Stream<QuerySnapshot> getAllRidesStream() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    // Fetch rides from the last 24 hours
    return FirebaseFirestore.instance
        .collection('rides')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Rides"),
        backgroundColor: amber,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search Fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sourceController,
                    decoration: const InputDecoration(
                      hintText: "Enter source",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      hintText: "Enter destination",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: amber),
                  onPressed: () {
                    setState(() {
                      _filterSource = _sourceController.text.toLowerCase().trim();
                      _filterDestination =
                          _destinationController.text.toLowerCase().trim();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🚗 Ride List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getAllRidesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No rides available"));
                  }

                  final allRides = snapshot.data!.docs;

                  // Filter results locally for related search
                  final filteredRides = allRides.where((ride) {
                    final source =
                    (ride['sourceName'] ?? '').toString().toLowerCase();
                    final destination =
                    (ride['destinationName'] ?? '').toString().toLowerCase();

                    final sourceMatch = _filterSource.isEmpty ||
                        source.contains(_filterSource);
                    final destMatch = _filterDestination.isEmpty ||
                        destination.contains(_filterDestination);

                    return sourceMatch && destMatch;
                  }).toList();

                  if (filteredRides.isEmpty) {
                    return const Center(
                        child: Text("No matching rides found."));
                  }

                  return ListView.builder(
                    itemCount: filteredRides.length,
                    itemBuilder: (context, index) {
                      final ride = filteredRides[index];
                      final sourceName = ride['sourceName'] ?? 'Unknown';
                      final destinationName = ride['destinationName'] ?? 'Unknown';
                      final totalFare = ride['totalFare'] ?? 0;
                      final passengers = ride['passengerCount'] ?? 1;
                      final farePerPerson = ride['farePerPerson'] ?? 0;
                      final timestamp = ride['createdAt'] as Timestamp?;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$sourceName → $destinationName",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Passengers: $passengers  |  Total Fare: ₹$totalFare  |  Per Person: ₹${farePerPerson.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Posted: ${timestamp != null ? timestamp.toDate().toLocal().toString().substring(0, 16) : 'Unknown'}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
