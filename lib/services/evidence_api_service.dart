import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/evidence_model.dart';

class EvidenceApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  static Future<Evidence> createEvidence(EvidenceRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/evidence/observation/${request.observationId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Evidence.fromJson(responseData);
    } else {
      throw Exception(
          'Failed to create evidence: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<Evidence>> getEvidenceByObservation(
      String observationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/evidence/observation/$observationId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Evidence.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to load evidence: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<Evidence>> getEvidenceByActivityAndObservation(
    String activityId,
    String observationId,
  ) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/evidence/activity/$activityId/observation/$observationId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Evidence.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to load evidence: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Evidence> updateEvidence(
    String observationId,
    String evidenceId,
    EvidenceRequest request,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/evidence/observation/$observationId/$evidenceId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Evidence.fromJson(responseData);
    } else {
      throw Exception(
          'Failed to update evidence: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> deleteEvidence(
      String observationId, String evidenceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/evidence/observation/$observationId/$evidenceId'),
    );

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete evidence: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> validateCompliance(
      String observationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/evidence/observation/$observationId/compliance'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to validate compliance: ${response.statusCode} - ${response.body}');
    }
  }
}
