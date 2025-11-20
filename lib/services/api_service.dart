// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_observations_response.dart';
import '../models/create_observation_request.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // GET /api/observations/activity/{activityId}
  Future<ActivityObservationsResponse> getObservationsByActivity(
      int activityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/activity/$activityId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return ActivityObservationsResponse.fromJson(data);
    } else {
      throw Exception(
          'Failed to load observations. Status: ${response.statusCode}');
    }
  }

  // POST /api/observations/activity/{activityId}
  Future<void> createObservations(
      int activityId, CreateObservationRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/activity/$activityId'),
      headers: await _getHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create observations. Status: ${response.statusCode}');
    }
  }

  // DELETE /api/observations/{observationId}
  Future<void> deleteObservation(int observationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$observationId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete observation. Status: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future getActivities() async {}

  static Future getActivityObservations(String activityId) async {}
}
