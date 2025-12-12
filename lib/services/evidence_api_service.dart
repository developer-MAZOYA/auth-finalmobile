import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/evidence_model.dart';
import 'image_picker_service.dart';

class EvidenceApiService {
  static const String baseUrl = 'http://192.168.1.190:8080/api';

  // ============ MAIN EVIDENCE CREATION METHOD ============

  // Use this method from EvidenceCaptureScreen - it handles file upload properly
  static Future<Evidence> createEvidenceWithImageUpload({
    required int userId,
    required int activityId,
    required int observationId,
    required List<File> imageFiles,
    required double latitude,
    required double longitude,
    required String address,
    double? accuracy,
    double? altitude,
    double? altitudeAccuracy,
    String? observationText,
  }) async {
    try {
      print('🎯 CREATING EVIDENCE WITH IMAGE UPLOAD');
      print(
          '👤 User: $userId, Activity: $activityId, Observation: $observationId');
      print('📍 Location: $latitude, $longitude, $address');
      print('🖼️  Image files: ${imageFiles.length}');
      print('📝 Observation text: ${observationText?.length ?? 0} characters');

      // Verify and prepare files
      List<File> verifiedFiles = await _verifyAndPrepareFiles(imageFiles);

      if (verifiedFiles.isEmpty) {
        throw Exception('No valid image files to upload after verification');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/upload'),
      );

      // Add image files (MUST be called 'images' to match backend @RequestParam("images"))
      for (int i = 0; i < verifiedFiles.length; i++) {
        var file = verifiedFiles[i];
        print('📎 Attaching file ${i + 1}: ${file.path}');

        var multipartFile = await http.MultipartFile.fromPath(
          'images', // CRITICAL: Must match @RequestParam("images") in backend
          file.path,
          filename: 'evidence_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          contentType: MediaType('image', 'jpg'),
        );
        request.files.add(multipartFile);
      }

      // Add other parameters (MUST match backend parameter names exactly)
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['address'] = address;

      if (accuracy != null) {
        request.fields['accuracy'] = accuracy.toString();
      }

      if (altitude != null) {
        request.fields['altitude'] = altitude.toString();
      }

      if (altitudeAccuracy != null) {
        request.fields['altitudeAccuracy'] = altitudeAccuracy.toString();
      }

      // Add observation text if provided
      if (observationText != null && observationText.isNotEmpty) {
        request.fields['observationText'] = observationText;
      }

      print('📤 Sending evidence creation request');
      print(
          '📊 Files: ${request.files.length}, Fields: ${request.fields.length}');
      print('🌐 URL: ${request.url}');

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      print('📥 Evidence creation response: ${response.statusCode}');
      print('📦 Response body: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse['success'] == true) {
          // The evidence is directly in the response, not nested
          Evidence evidence = Evidence.fromJson(jsonResponse);
          print('✅ Evidence created successfully: ID ${evidence.evidenceId}');
          print('✅ Images saved: ${evidence.imagePaths.length}');
          return evidence;
        } else {
          throw Exception(
              'Evidence creation failed: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: $responseData');
      }
    } catch (e) {
      print('❌ Evidence creation error: $e');
      rethrow;
    }
  }

  // ============ HELPER METHODS ============

  // Verify and prepare files before upload
  static Future<List<File>> _verifyAndPrepareFiles(
      List<File> imageFiles) async {
    List<File> validFiles = [];

    for (int i = 0; i < imageFiles.length; i++) {
      File file = imageFiles[i];

      try {
        // Check if file exists
        bool exists = await file.exists();
        if (!exists) {
          print('⚠️  File does not exist: ${file.path}');
          continue;
        }

        // Check file size
        final stat = await file.stat();
        if (stat.size == 0) {
          print('⚠️  File is empty: ${file.path}');
          continue;
        }

        // Try to read file to verify it's accessible
        await file.readAsBytes();
        validFiles.add(file);
        print('✅ File ${i + 1} verified: ${file.path} (${stat.size} bytes)');
      } catch (e) {
        print('⚠️  File verification failed for ${file.path}: $e');
      }
    }

    print(
        '📋 File verification: ${imageFiles.length} original, ${validFiles.length} valid');
    return validFiles;
  }

  // ============ EXISTING METHODS (KEEP THESE) ============

  // Get user's assigned activities with observations
  static Future<List<dynamic>> getUserAssignedActivities(int userId) async {
    print('📱 Fetching assigned activities for user: $userId');

    final response = await http.get(
      Uri.parse('$baseUrl/evidence/user/$userId/assigned-activities'),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('✅ Activities fetched successfully');
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
    print('📱 Fetching observations for activity: $activityId');

    final response = await http.get(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observations'),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('✅ Observations fetched successfully');
        return responseData;
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to load observations: ${response.statusCode} - ${response.body}');
    }
  }

  // Get evidences for observation
  static Future<List<Evidence>> getEvidencesForObservation(
      int userId, int activityId, int observationId) async {
    print('📱 Fetching evidences for observation: $observationId');

    final response = await http.get(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/evidences'),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('✅ Evidences fetched successfully');
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
    print('📱 Fetching evidence summary for user: $userId');

    final response = await http.get(
      Uri.parse('$baseUrl/evidence/user/$userId/summary'),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('✅ Summary fetched successfully');
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
    print('📱 Validating compliance for observation: $observationId');

    final response = await http.get(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/compliance'),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('✅ Compliance validation completed');
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
    print('🗑️  Deleting evidence: $evidenceId');

    final response = await http.delete(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/evidence/$evidenceId'),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message']);
      } else {
        print('✅ Evidence deleted successfully');
      }
    } else {
      throw Exception(
          'Failed to delete evidence: ${response.statusCode} - ${response.body}');
    }
  }

  // ============ OLD METHODS (DEPRECATED) ============
  // These should NOT be used for new evidence creation with images

  // OLD: Create evidence for observation (JSON only - requires pre-uploaded images)
  // @Deprecated - Use createEvidenceWithImageUpload instead
  static Future<Evidence> createEvidence(
    int userId,
    int activityId,
    int observationId,
    EvidenceRequest request,
  ) async {
    print('⚠️  WARNING: Using deprecated createEvidence method');
    print('⚠️  Use createEvidenceWithImageUpload instead for file uploads');
    print('📤 Sending JSON-only evidence creation request');

    final response = await http.post(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('✅ Evidence created (JSON method)');
        return Evidence.fromJson(responseData);
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to create evidence: ${response.statusCode} - ${response.body}');
    }
  }

  // OLD: Update evidence
  static Future<Evidence> updateEvidence(
    int userId,
    int activityId,
    int observationId,
    int evidenceId,
    EvidenceRequest request,
  ) async {
    print('📝 Updating evidence: $evidenceId');

    final response = await http.put(
      Uri.parse(
          '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/evidence/$evidenceId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('✅ Evidence updated successfully');
        return Evidence.fromJson(responseData);
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception(
          'Failed to update evidence: ${response.statusCode} - ${response.body}');
    }
  }

  // ============ DEBUG METHODS ============

  // Check storage status (for debugging)
  static Future<Map<String, dynamic>> debugStorage() async {
    print('🔍 Debugging storage...');

    final response = await http.get(
      Uri.parse('$baseUrl/evidence/debug-storage'),
    );

    if (response.statusCode == 200) {
      print('✅ Storage debug successful');
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to check storage: ${response.statusCode} - ${response.body}');
    }
  }

  // Test file upload (for debugging)
  static Future<Map<String, dynamic>> debugUpload(File imageFile) async {
    print('🔍 Debug upload with file: ${imageFile.path}');

    // Verify file first
    bool isValid = await ImagePickerService.verifyFile(imageFile);
    if (!isValid) {
      throw Exception('Debug upload failed: File is not valid');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/evidence/debug-upload'),
    );

    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: 'debug_${DateTime.now().millisecondsSinceEpoch}.jpg',
      contentType: MediaType('image', 'jpg'),
    );
    request.files.add(multipartFile);

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('✅ Debug upload successful');
      return jsonDecode(responseData);
    } else {
      throw Exception(
          'Debug upload failed: ${response.statusCode} - $responseData');
    }
  }
}
