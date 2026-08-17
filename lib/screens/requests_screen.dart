import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ride Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rides")
            .where("driverId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final rides = snapshot.data!.docs;
          return ListView(
            children: rides.map((ride) {
              return ExpansionTile(
                title: Text("${ride["from"]} ➝ ${ride["to"]}"),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: ride.reference.collection("requests").snapshots(),
                    builder: (context, reqSnap) {
                      if (!reqSnap.hasData) return const SizedBox();
                      final requests = reqSnap.data!.docs;

                      return Column(
                        children: requests.map((req) {
                          return ListTile(
                            title: Text(req["userName"]),
                            subtitle: Text("Status: ${req["status"]}"),
                            trailing: req["status"] == "pending"
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    req.reference.update({"status": "approved"});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    req.reference.update({"status": "rejected"});
                                  },
                                ),
                              ],
                            )
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
