import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _uploading = false;

  /// 🔹 Upload and store ID card as Base64 string
  Future<void> _uploadIdCard() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No file selected.")));
      return;
    }

    setState(() => _uploading = true);

    try {
      final file = File(pickedFile.path);
      final imageBytes = await file.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        "idBase64": base64Image,
        "verified": false, // admin verification later
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "✅ ID uploaded successfully! Awaiting admin verification."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _uploading = false);
    }
  }

  /// 🔹 Logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.amber.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Profile data unavailable."));
          }

          // User fields
          final name = data["name"] ?? "No Name";
          final email = data["email"] ?? "No Email";
          final userType = data["userType"] ?? "N/A";
          final orgName = data["orgName"] ?? "Not Provided";
          final orgAddress = data["orgAddress"] ?? "Not Provided";
          final verified = data["verified"] ?? false;
          final idType = data["idType"] ?? "ID Card";
          final idUrl = data["idUrl"] ?? "";
          final idBase64 = data["idBase64"] ?? "";

          // Image provider for ID
          ImageProvider? idImageProvider;
          if (idUrl.isNotEmpty) {
            idImageProvider = NetworkImage(idUrl);
          } else if (idBase64.isNotEmpty) {
            try {
              idImageProvider = MemoryImage(base64Decode(idBase64));
            } catch (_) {}
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔸 Profile Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.amber.shade100,
                          child: Icon(Icons.person,
                              size: 50, color: Colors.amber.shade700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            if (verified)
                              const Icon(Icons.verified,
                                  color: Colors.blue, size: 22),
                          ],
                        ),
                        Text(email, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔸 Info Cards
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.badge, color: Colors.amber),
                    title: Text("User Type: $userType"),
                    subtitle: Text(orgName),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.amber),
                    title: const Text("Organization Address"),
                    subtitle: Text(orgAddress),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔸 ID Upload Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.credit_card, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text("$idType Upload",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (idImageProvider != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image(
                              image: idImageProvider,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const Text("No ID uploaded yet.",
                              style: TextStyle(color: Colors.grey)),

                        const SizedBox(height: 10),
                        _uploading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                          onPressed: _uploadIdCard,
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Upload ID"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
