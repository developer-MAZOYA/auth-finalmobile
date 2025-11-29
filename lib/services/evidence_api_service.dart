import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/evidence_model.dart';
import 'image_picker_service.dart';

class EvidenceApiService {
  static const String baseUrl = 'http://192.168.1.190:8080/api';

  // ============ FILE UPLOAD METHODS ============

  // Upload images and get stored file paths
  static Future<List<String>> uploadImages(List<File> imageFiles) async {
    try {
      print('📤 UPLOADING ${imageFiles.length} IMAGES');

      // Verify all files before upload
      List<File> verifiedFiles = await _verifyAndPrepareFiles(imageFiles);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/evidence/upload-images'),
      );

      // Add all image files
      for (int i = 0; i < verifiedFiles.length; i++) {
        var file = verifiedFiles[i];
        print('➕ Adding file ${i + 1}: ${file.path}');

        var multipartFile = await http.MultipartFile.fromPath(
          'images',
          file.path,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          contentType: MediaType('image', 'jpg'),
        );
        request.files.add(multipartFile);
      }

      print('🚀 Sending upload request with ${request.files.length} files');

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      print('📥 Upload response: ${response.statusCode}');
      print('📦 Response data: $responseData');

      if (response.statusCode == 200) {
        if (jsonResponse['success'] == true) {
          List<String> storedPaths =
              List<String>.from(jsonResponse['storedImagePaths']);
          print('✅ Images uploaded successfully: ${storedPaths.length} paths');
          return storedPaths;
        } else {
          throw Exception('Upload failed: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: $responseData');
      }
    } catch (e) {
      print('❌ Image upload error: $e');
      rethrow;
    }
  }

  // Create evidence with file upload (RECOMMENDED - saves files to disk)
  static Future<Evidence> createEvidenceWithUpload({
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
  }) async {
    try {
      print('🎯 CREATING EVIDENCE WITH UPLOAD');
      print(
          '👤 User: $userId, Activity: $activityId, Observation: $observationId');
      print('📍 Location: $latitude, $longitude, $address');
      print('🖼️  Original image files: ${imageFiles.length}');

      // Verify and prepare files
      List<File> verifiedFiles = await _verifyAndPrepareFiles(imageFiles);

      if (verifiedFiles.isEmpty) {
        throw Exception('No valid image files to upload after verification');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '$baseUrl/evidence/user/$userId/activity/$activityId/observation/$observationId/upload'),
      );

      // Add image files
      for (int i = 0; i < verifiedFiles.length; i++) {
        var file = verifiedFiles[i];
        print('📎 Attaching file ${i + 1}: ${file.path}');

        var multipartFile = await http.MultipartFile.fromPath(
          'images',
          file.path,
          filename: 'evidence_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          contentType: MediaType('image', 'jpg'),
        );
        request.files.add(multipartFile);
      }

      // Add other parameters
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['address'] = address;
      if (accuracy != null) request.fields['accuracy'] = accuracy.toString();
      if (altitude != null) request.fields['altitude'] = altitude.toString();
      if (altitudeAccuracy != null)
        request.fields['altitudeAccuracy'] = altitudeAccuracy.toString();

      print('📤 Sending evidence creation request');
      print(
          '📊 Files: ${request.files.length}, Fields: ${request.fields.length}');

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      print('📥 Evidence creation response: ${response.statusCode}');
      print('📦 Response body: $responseData');

      if (response.statusCode == 200) {
        if (jsonResponse['success'] == true) {
          Evidence evidence = Evidence.fromJson(jsonResponse);
          print('✅ Evidence created successfully: ID ${evidence.evidenceId}');
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

  // Quick evidence creation with camera pictures
  static Future<Evidence> createEvidenceWithCamera({
    required int userId,
    required int activityId,
    required int observationId,
    required double latitude,
    required double longitude,
    required String address,
    int imageCount = 1,
    double? accuracy,
    double? altitude,
    double? altitudeAccuracy,
  }) async {
    print('📸 CREATING EVIDENCE WITH CAMERA');
    print('🖼️  Requesting $imageCount pictures');

    // Take pictures using camera
    List<File> imageFiles =
        await ImagePickerService.takeMultiplePictures(imageCount);

    if (imageFiles.isEmpty) {
      throw Exception('No images were taken or user canceled');
    }

    print('✅ Captured ${imageFiles.length} images');

    // Create evidence with uploaded images
    Evidence evidence = await createEvidenceWithUpload(
      userId: userId,
      activityId: activityId,
      observationId: observationId,
      imageFiles: imageFiles,
      latitude: latitude,
      longitude: longitude,
      address: address,
      accuracy: accuracy,
      altitude: altitude,
      altitudeAccuracy: altitudeAccuracy,
    );

    // Clean up temporary files after successful upload
    await ImagePickerService.cleanupTemporaryFiles();

    return evidence;
  }

  // ============ HELPER METHODS ============

  // Verify and prepare files before upload
  static Future<List<File>> _verifyAndPrepareFiles(
      List<File> imageFiles) async {
    List<File> validFiles = [];

    for (int i = 0; i < imageFiles.length; i++) {
      File file = imageFiles[i];

      // Verify file exists and is readable
      bool isValid = await ImagePickerService.verifyFile(file);
      if (isValid) {
        validFiles.add(file);
      } else {
        print('⚠️  Skipping invalid file ${i + 1}: ${file.path}');
      }
    }

    print(
        '📋 File verification: ${imageFiles.length} original, ${validFiles.length} valid');
    return validFiles;
  }

  // ============ EXISTING METHODS ============

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

  // Create evidence for observation (JSON only - requires pre-uploaded images)
  static Future<Evidence> createEvidence(
    int userId,
    int activityId,
    int observationId,
    EvidenceRequest request,
  ) async {
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
  static Future<Evidence> updateEvidence(
    int userId,
    int activityId,
    int observationId,
    int evidenceId,
    EvidenceRequest request,
  ) async {
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

  // ============ DEBUG METHODS ============

  // Check storage status (for debugging)
  static Future<Map<String, dynamic>> debugStorage() async {
    final response = await http.get(
      Uri.parse('$baseUrl/evidence/debug-storage'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to check storage: ${response.statusCode} - ${response.body}');
    }
  }

  // Test file upload (for debugging)
  static Future<Map<String, dynamic>> debugUpload(File imageFile) async {
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
      return jsonDecode(responseData);
    } else {
      throw Exception(
          'Debug upload failed: ${response.statusCode} - $responseData');
    }
  }
}
