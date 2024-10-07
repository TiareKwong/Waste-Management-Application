import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data'; // For storing the snapshot as bytes
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../viewmodels/report_issues_view_model.dart';
import 'full_screen_map.dart';

class ReportIssuesPage extends StatefulWidget {
  @override
  _ReportIssuesPageState createState() => _ReportIssuesPageState();
}

class _ReportIssuesPageState extends State<ReportIssuesPage> {
  final _descriptionController = TextEditingController();
  final ReportIssuesViewModel _viewModel = ReportIssuesViewModel();
  bool _isLoading = false;  // Loading state
  File? _image;
  LatLng? _location;
  Uint8List? _snapshot; // Store the map snapshot
  GoogleMapController? _mapController; // Controller for Google Map
  Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Fetch user's current location on init
  }

  // Method to open camera or gallery
  Future<void> _pickImage() async {
    if (_isLoading) return; // Disable input when loading

    final picker = ImagePicker();

    // Show a dialog to choose between camera and gallery
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a picture'),
                onTap: () async {
                  final pickedImage = await picker.pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    setState(() {
                      _image = File(pickedImage.path); // Store the image
                    });
                  }
                  Navigator.of(context).pop(); // Close the modal
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from gallery'),
                onTap: () async {
                  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      _image = File(pickedImage.path); // Store the image
                    });
                  }
                  Navigator.of(context).pop(); // Close the modal
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to fetch user location
  Future<void> _getUserLocation() async {
    if (_isLoading) return; // Disable input when loading

    try {
      LocationData currentLocation = await _locationService.getLocation();
      setState(() {
        _location = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  // Method to take a snapshot of the map
  Future<void> _takeSnapshot() async {
    if (_mapController != null) {
      // Delay for a second to ensure the map is fully loaded
      await Future.delayed(Duration(seconds: 1));

      final imageBytes = await _mapController!.takeSnapshot();
      if (imageBytes != null) {
        setState(() {
          _snapshot = imageBytes; // Save the snapshot
        });
      }
    }
  }

  // Open full-screen map for location selection
  Future<void> _navigateToFullScreenMap() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMapPage(
          initialLocation: _location, // Pass the current location
        ),
      ),
    );

    if (selectedLocation != null && _mapController != null) {
      setState(() {
        _location = selectedLocation;
      });

      // Try to move the camera to the new location and retry if it fails
      try {
        await _mapController!.moveCamera(CameraUpdate.newLatLng(_location!));
        print('Camera moved to new location: $_location');

        // Wait for the camera to settle
        await Future.delayed(Duration(milliseconds: 500));

        // Take a new snapshot
        await _takeSnapshot();
      } catch (e) {
        print('Error moving camera or taking snapshot: $e');
      }
    }
  }

  // Method to submit the report
  Future<void> _submitReport() async {
    if (_isLoading) return; // Prevent multiple submissions

    if (_descriptionController.text.isEmpty || _image == null || _location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      await _viewModel.submitReport(
        _descriptionController.text,
        _location!.latitude,
        _location!.longitude,
        _image!,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report submitted successfully!')));
      setState(() {
        _descriptionController.clear();
        _image = null;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit report.')));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Report Issue'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  enabled: !_isLoading,  // Disable input when loading
                  decoration: InputDecoration(
                    hintText: 'A detailed description of the issue...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                
                // Image picker
                GestureDetector(
                  onTap: _pickImage, // Trigger the image picker on tap
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

                // Snapshot or map preview
                _snapshot != null
                    ? Image.memory(_snapshot!) // Display the snapshot if available
                    : GestureDetector(
                        child: _location == null
                            ? Center(child: CircularProgressIndicator()) // Show loader while fetching location
                            : Container(
                                height: 300, // Show map preview for selected location
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _location!, // Show current or selected location
                                    zoom: 15, // Initial zoom level
                                  ),
                                  onTap: (LatLng newLocation) {  // Allow tapping to select a new location
                                    setState(() {
                                      _location = newLocation;  // Update the location
                                    });
                                  },
                                  markers: _location != null
                                      ? {
                                          Marker(
                                            markerId: MarkerId('user-location'),
                                            position: _location!,
                                          ),
                                        }
                                      : {},
                                  onMapCreated: (GoogleMapController controller) {
                                    _mapController = controller;
                                    print('GoogleMapController initialized');
                                    _takeSnapshot(); // Take the snapshot after map is created
                                  },
                                ),
                              ),
                      ),
                SizedBox(height: 20),

                // Button to change location
                Center(
                  child: ElevatedButton(
                    onPressed: _navigateToFullScreenMap, // Open the full-screen map
                    child: Text('Change Location'),
                  ),
                ),

                SizedBox(height: 20),

                // Submit button
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReport,  // Disable button when loading
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white) // Show loader when submitting
                        : Text('Submit Report', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Show loading overlay when the app is loading
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),  // Full screen loading indicator
            ),
          ),
      ],
    );
  }
}
