// report_issues_view_model.dart
import '../services/api_service.dart';
import '../model/report_model.dart';  // Import the Report model
import 'dart:io';

class ReportIssuesViewModel {
  final ApiService _apiService = ApiService();

  // Modify this function to create a Report object and pass it to the service
  Future<void> submitReport(String description, double latitude, double longitude, File image) async {
    // Create a Report object
    Report report = Report(
      description: description,
      latitude: latitude,
      longitude: longitude,
      imageUrl: '',  // You can leave this empty for now, as imagePath is handled separately
    );

    // Pass the Report object and image path to the service
    await _apiService.submitReportWithImage(report, image.path);
  }
}
