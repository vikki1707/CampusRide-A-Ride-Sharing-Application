class UserData {
  static bool isVerified = false;

  // Rides created/offered by the user
  static List<Map<String, dynamic>> rides = [];

  // Ride requests received from others
  static List<Map<String, dynamic>> rideRequests = [
    {
      "name": "Rahul",
      "from": "Campus Gate",
      "to": "City Center",
      "status": "Pending",
    },
    {
      "name": "Sneha",
      "from": "Hostel",
      "to": "Library",
      "status": "Pending",
    }
  ];
}
