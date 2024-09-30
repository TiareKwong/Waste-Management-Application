import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://170.64.181.18:3000'; // Your Droplet's IP address and Node.js port

  // Fetch all reports
  Future<List<dynamic>> fetchReports() async {
    final response = await http.get(Uri.parse('$baseUrl/reports'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reports');
    }
  }

  // Submit a new report
  Future<void> submitReportWithImage(String description, double latitude, double longitude, String imagePath) async {
    var uri = Uri.parse('$baseUrl/reports');

    var request = http.MultipartRequest('POST', uri)
      ..fields['description'] = description
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString();

    if (imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Report submitted successfully!');
    } else {
      throw Exception('Failed to submit report');
    }
  }
}
