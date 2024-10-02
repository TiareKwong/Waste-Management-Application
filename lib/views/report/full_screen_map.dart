import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullScreenMapPage extends StatefulWidget {
  final LatLng? initialLocation;

  FullScreenMapPage({this.initialLocation});

  @override
  _FullScreenMapPageState createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Set the initial location to the passed location or a default value
    _selectedLocation = widget.initialLocation ?? LatLng(40.7128, -74.0060); // Default location is New York City
  }

  // Update the selected location when the user taps on the map
  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      _selectedLocation = tappedPoint;
    });
  }

  // Confirm the selected location and return it to the previous screen
  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation); // Return the selected location
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation, // Confirm the location and go back
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation!, // Center on the selected location
          zoom: 15,
        ),
        onTap: _onMapTapped, // Update the selected location on map tap
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: _selectedLocation!,
                ),
              }
            : {},
      ),
    );
  }
}
