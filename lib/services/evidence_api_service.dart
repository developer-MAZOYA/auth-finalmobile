import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/evidence_model.dart';

class EvidenceApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // Get user's assigned activities with observations
  static Future<List<dynamic>> getUserAssignedActivities(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/evidence/user/$userId/assigned-activities'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData['assignedActivities'];
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to load assigned activities: ${response.statusCode} - ${response.body}');
    }
  }

  // Get observations for specific assigned activity
  static Future<Map<String, dynamic>> getObservationsForActivity(
      int userId, int activityId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observations'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to load observations: ${response.statusCode} - ${response.body}');
    }
  }

  // Create evidence for observation
  static Future<Evidence> createEvidence(int userId, int activityId,
      int observationId, EvidenceRequest request) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return Evidence.fromJson(responseData);
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to create evidence: ${response.statusCode} - ${response.body}');
    }
  }

  // Get evidences for observation
  static Future<List<Evidence>> getEvidencesForObservation(
      int userId, int activityId, int observationId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/evidences'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['evidences'];
        return data.map((item) => Evidence.fromJson(item)).toList();
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to load evidences: ${response.statusCode} - ${response.body}');
    }
  }

  // Get user evidence summary
  static Future<Map<String, dynamic>> getUserEvidenceSummary(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/evidence/user/$userId/summary'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to load evidence summary: ${response.statusCode} - ${response.body}');
    }
  }

  // Validate compliance
  static Future<Map<String, dynamic>> validateCompliance(
      int userId, int activityId, int observationId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/compliance'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to validate compliance: ${response.statusCode} - ${response.body}');
    }
  }

  // Delete evidence
  static Future<void> deleteEvidence(
      int userId, int activityId, int observationId, int evidenceId) async {
    final response = await http.delete(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/evidence/$evidenceId'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to delete evidence: ${response.statusCode} - ${response.body}');
    }
  }

  // Update evidence
  static Future<Evidence> updateEvidence(int userId, int activityId,
      int observationId, int evidenceId, EvidenceRequest request) async {
    final response = await http.put(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/evidence/$evidenceId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return Evidence.fromJson(responseData);
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to update evidence: ${response.statusCode} - ${response.body}');
    }
  }
}
