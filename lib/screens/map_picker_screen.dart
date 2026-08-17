import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final String? title;

  const MapPickerScreen({super.key, this.title});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _controller;
  bool _isNavigatingBack = false;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  Future<void> _confirmSelection() async {
    if (_isNavigatingBack) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location first")),
      );
      return;
    }

    _isNavigatingBack = true;

    // ✅ Use WidgetsBinding to delay pop after frame is complete (no lock)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(_selectedLocation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Pick Location"),
        backgroundColor: Colors.amber.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onTap,
        initialCameraPosition: const CameraPosition(
          target: LatLng(12.9716, 77.5946), // Default: Bengaluru
          zoom: 12,
        ),
        markers: _selectedLocation == null
            ? {}
            : {
          Marker(
            markerId: const MarkerId('selected'),
            position: _selectedLocation!,
          ),
        },
      ),
    );
  }
}
