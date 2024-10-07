import 'package:flutter/material.dart';
import '../model/collection_schedule_model.dart';
import '../services/api_service.dart';

class CollectionScheduleViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<CollectionSchedule> _schedules = [];  // List to hold multiple schedules
  bool _isLoading = false;
  bool _isError = false;

  List<CollectionSchedule> get schedules => _schedules;  // Getter for the list of schedules
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  Future<void> fetchCollectionSchedule() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedules = await _apiService.fetchCollectionSchedule();  // Now fetching a list of schedules
      _isError = false;
    } catch (e) {
      _isError = true;
      _schedules = [];  // Reset the list if there's an error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendReminders() async {
    // Logic to send reminders (e.g., via an API)
    // Implement this based on your backend system
  }
}
