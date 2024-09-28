import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // To handle File for the image
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For map
import 'package:location/location.dart'; // For requesting location
import 'package:http/http.dart' as http;
import 'full_screen_map.dart';

class ReportIssuesPage extends StatefulWidget {
  @override
  _ReportIssuesPageState createState() => _ReportIssuesPageState();
}

class _ReportIssuesPageState extends State<ReportIssuesPage> {
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  File? _image; // Image picked by user
  LatLng? _location; // Location picked by user
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
    _getUserLocation(); // Fetch location
  }

  // Fetch User's Current Location
  Future<void> _getUserLocation() async {
    try {
      LocationData currentLocation = await _locationService.getLocation();
      setState(() {
        _location = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
      print('Current location: ${currentLocation.latitude}, ${currentLocation.longitude}');
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  // Method to open the full-screen map for location selection
  void _openFullMap() async {
    LatLng? newLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMapPage(initialLocation: _location),
      ),
    );

    if (newLocation != null) {
      setState(() {
        _location = newLocation; // Update the location if a new one is selected
      });
    }
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

  // Method to submit the report to Node.js API
  Future<void> _submitReport() async {
    if (_descriptionController.text.isEmpty || _image == null || _location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://4c48-101-98-168-49.ngrok-free.app/reports'),
      );

      request.fields['description'] = _descriptionController.text;
      request.fields['latitude'] = _location!.latitude.toString();
      request.fields['longitude'] = _location!.longitude.toString();

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted successfully!')),
        );
        setState(() {
          _descriptionController.clear();
          _image = null;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report.')),
        );
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: AbsorbPointer( // Disable all interactions if loading
            absorbing: _isLoading,
            child: SingleChildScrollView(
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
                    onTap: _pickImage,
                    child: _image != null
                        ? Image.file(_image!)
                        : Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.camera_alt, size: 100, color: Colors.grey[600]),
                          ),
                  ),
                  SizedBox(height: 20),

                  // Static Location Map Preview
                  Text(
                    'Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openFullMap, // Opens the full-screen map when tapped
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey[300],
                      child: _location != null
                          ? GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _location!,
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('selected-location'),
                                  position: _location!,
                                ),
                              },
                              zoomGesturesEnabled: false, // Disable zoom on static view
                              scrollGesturesEnabled: false, // Disable map scrolling on static view
                              myLocationButtonEnabled: false,
                              onTap: (_) => _openFullMap(), // Open full-screen map when clicked
                            )
                          : Center(child: CircularProgressIndicator()), // Show loader until location is fetched
                    ),
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitReport,  // Disable if loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading ? Colors.grey : Colors.purple,  // Change color if loading
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: _isLoading 
                        ? CircularProgressIndicator(color: Colors.white) // Show loading spinner
                        : Text('Submit Report', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Show loading spinner in the middle of the screen if _isLoading is true
        if (_isLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
