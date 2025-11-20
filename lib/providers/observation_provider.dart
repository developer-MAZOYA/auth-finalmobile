// providers/observation_provider.dart
import 'package:flutter/foundation.dart';
import '../models/activity_observations_response.dart';
import '../models/create_observation_request.dart';
import '../services/api_service.dart';

class ObservationProvider with ChangeNotifier {
  final ApiService apiService;

  ActivityObservationsResponse? _observations;
  bool _isLoading = false;
  String _errorMessage = '';

  ObservationProvider({required this.apiService});

  ActivityObservationsResponse? get observations => _observations;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Clear all data
  void clearData() {
    _observations = null;
    _errorMessage = '';
    notifyListeners();
  }

  // GET endpoint: /api/observations/activity/{activityId}
  Future<void> fetchObservations(int activityId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print('🔵 FETCHING OBSERVATIONS for activity: $activityId');
      _observations = await apiService.getObservationsByActivity(activityId);
      print(
          '✅ OBSERVATIONS LOADED: ${_observations?.observations.length} items');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ ERROR LOADING OBSERVATIONS: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // POST endpoint: /api/observations/activity/{activityId}
  Future<void> addObservations(
      int activityId, List<String> observationNames) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print('🔵 ADDING OBSERVATIONS: $observationNames');
      final request =
          CreateObservationRequest(observationName: observationNames);
      await apiService.createObservations(activityId, request);

      print('✅ OBSERVATIONS ADDED SUCCESSFULLY');
      // Refresh the observations list
      await fetchObservations(activityId);
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ ERROR ADDING OBSERVATIONS: $e');
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // DELETE endpoint: /api/observations/{observationId}
  Future<void> deleteObservation(int observationId) async {
    try {
      print('🔵 DELETING OBSERVATION: $observationId');
      await apiService.deleteObservation(observationId);
      print('✅ OBSERVATION DELETED SUCCESSFULLY');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ ERROR DELETING OBSERVATION: $e');
      notifyListeners();
      rethrow;
    }
  }
}
