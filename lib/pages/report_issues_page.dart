import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // To handle File for the image
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For map
import 'package:location/location.dart'; // For requesting location

class ReportIssuesPage extends StatefulWidget {
  @override
  _ReportIssuesPageState createState() => _ReportIssuesPageState();
}

class _ReportIssuesPageState extends State<ReportIssuesPage> {
  final _descriptionController = TextEditingController();
  File? _image; // Image picked by user
  LatLng? _location; // Location picked by user
  GoogleMapController? _mapController;
  Location _locationService = Location(); // To get location

  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // Request permissions when page is initialized
    _getUserLocation(); // Fetch the user's current location
  }

  // Request Location Permissions
  Future<void> _requestLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await _locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationService.requestService();
      if (!_serviceEnabled) {
        return; // Handle if service is not enabled
      }
    }

    // Check for permissions
    _permissionGranted = await _locationService.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationService.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("Location permission denied.");
        return; // Handle if permission is not granted
      }
    }

    print("Location permission granted.");

    // Fetch the location after permission is granted
    _getUserLocation();
  }

  // Fetch User's Current Location
  Future<void> _getUserLocation() async {
    try {
      LocationData currentLocation = await _locationService.getLocation();
      setState(() {
        _location = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
      print('Current location: ${currentLocation.latitude}, ${currentLocation.longitude}');
      
      // Animate the map to the user's location after it's fetched
      if (_mapController != null && _location != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _location!, zoom: 15),
          ),
        );
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  // Method to handle tap on the map and select a location
  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      _location = tappedPoint; // Update to the new tapped location
    });
  }

  // Method to pick an image from the camera or gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Show a dialog to let the user choose between camera or gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a picture'),
                onTap: () async {
                  final pickedImage = await picker.getImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    setState(() {
                      _image = File(pickedImage.path);
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  final pickedImage = await picker.getImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      _image = File(pickedImage.path);
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to submit the report
  void _submitReport() {
    String description = _descriptionController.text;
    // Check if description, image, and location are available
    if (description.isNotEmpty && _image != null && _location != null) {
      // Submit the report
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Report submitted!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please complete all fields.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Description Field
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'A detailed description of the issue...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Photo Picker
            Text(
              'Photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage, // Call image picker dialog on tap
              child: _image != null
                  ? Image.file(_image!) // Show selected image
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.camera_alt, size: 100, color: Colors.grey[600]),
                    ),
            ),
            SizedBox(height: 20),

            // Location Picker
            Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[300],
              child: _location != null
                  ? GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      
                      if (_location != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: _location!, zoom: 15),
                          ),
                        );
                      } else {
                        _mapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: LatLng(40.7128, -74.0060), zoom: 10), // Default location: New York
                          ),
                        );
                      }
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(40.7128, -74.0060), // New York as a default location
                      zoom: 10,
                    ),
                    markers: _location != null
                        ? {
                            Marker(
                              markerId: MarkerId('selected-location'),
                              position: _location!,
                            ),
                          }
                        : {},
                    onTap: _onMapTapped, // Allow user to tap and change location
                  )
                  : Center(child: CircularProgressIndicator()), // Show loader until location is fetched
            ),
            SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text('Submit Report', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
