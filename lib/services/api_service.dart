// api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/report_model.dart';  // Import the Report model
import '../model/collection_schedule_model.dart';

class ApiService {
  final String baseUrl = 'http://170.64.181.18:3000'; // Replace with your API URL

  // Modify this function to accept a Report object and the image path
  Future<void> submitReportWithImage(Report report, String imagePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/reports'),
    );

    // Use the Report object properties
    request.fields['description'] = report.description;
    request.fields['latitude'] = report.latitude.toString();
    request.fields['longitude'] = report.longitude.toString();
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to submit report');
    }
  }

  Future<List<CollectionSchedule>> fetchCollectionSchedule() async {
    final response = await http.get(Uri.parse('$baseUrl/collection-schedule'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CollectionSchedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load collection schedule');
    }
  }
}
