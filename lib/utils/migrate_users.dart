import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateNestedUsers() async {
  final firestore = FirebaseFirestore.instance;

  print("🚀 Starting user data migration...");

  // Get all top-level user docs
  final usersSnapshot = await firestore.collection("users").get();

  for (var parentDoc in usersSnapshot.docs) {
    final nestedUsersRef = parentDoc.reference.collection("users");
    final nestedUsersSnapshot = await nestedUsersRef.get();

    for (var nestedDoc in nestedUsersSnapshot.docs) {
      final data = nestedDoc.data();

      // Write to top-level "users" collection using nested UID
      await firestore.collection("users").doc(nestedDoc.id).set(data);
      print("✅ Migrated: ${nestedDoc.id}");

      // Optionally delete old nested data (uncomment after verifying)
      // await nestedDoc.reference.delete();
    }
  }

  print("🎯 Migration complete! Check your Firestore now.");
}
