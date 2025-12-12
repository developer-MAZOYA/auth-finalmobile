class Evidence {
  final String evidenceId;
  final String activityId;
  final String observationId;
  final List<String> imagePaths;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final double accuracy;
  final double? altitude;
  final double? altitudeAccuracy;
  final String? observationText;

  Evidence({
    required this.evidenceId,
    required this.activityId,
    required this.observationId,
    required this.imagePaths,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    required this.accuracy,
    this.altitude,
    this.altitudeAccuracy,
    this.observationText,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'evidenceId': evidenceId,
      'activityId': activityId,
      'observationId': observationId,
      'imagePaths': imagePaths,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
    };

    if (altitude != null) {
      json['altitude'] = altitude;
    }

    if (altitudeAccuracy != null) {
      json['altitudeAccuracy'] = altitudeAccuracy;
    }

    if (observationText != null) {
      json['observationText'] = observationText;
    }

    return json;
  }

  factory Evidence.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different JSON structures from backend
      // The evidence might be at the root or in a 'data' field
      Map<String, dynamic> evidenceData = json;

      // If the evidence is in a 'data' field
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        evidenceData = json['data'];
      }

      // If evidence is directly in the response
      return Evidence(
        evidenceId: evidenceData['evidenceId']?.toString() ?? '',
        activityId: evidenceData['activityId']?.toString() ?? '',
        observationId: evidenceData['observationId']?.toString() ?? '',
        imagePaths: List<String>.from(evidenceData['imagePaths'] ?? []),
        latitude: (evidenceData['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (evidenceData['longitude'] as num?)?.toDouble() ?? 0.0,
        address: evidenceData['address'] ?? '',
        timestamp: DateTime.parse(evidenceData['timestamp'] ??
            evidenceData['createdAt'] ??
            DateTime.now().toIso8601String()),
        accuracy: (evidenceData['accuracy'] as num?)?.toDouble() ?? 0.0,
        altitude: (evidenceData['altitude'] as num?)?.toDouble(),
        altitudeAccuracy:
            (evidenceData['altitudeAccuracy'] as num?)?.toDouble(),
        observationText: evidenceData['observationText'],
      );
    } catch (e) {
      print('Error parsing Evidence from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  int get imageCount => imagePaths.length;
  bool get hasImages => imagePaths.isNotEmpty;

  @override
  String toString() {
    return 'Evidence(id: $evidenceId, activity: $activityId, observation: $observationId, images: $imageCount)';
  }
}

class EvidenceRequest {
  final String activityId;
  final String observationId;
  final List<String> imagePaths;
  final double latitude;
  final double longitude;
  final String address;
  final double accuracy;
  final double? altitude;
  final double? altitudeAccuracy;
  final String? observationText;

  EvidenceRequest({
    required this.activityId,
    required this.observationId,
    required this.imagePaths,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.accuracy,
    this.altitude,
    this.altitudeAccuracy,
    this.observationText,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'activityId': activityId,
      'observationId': observationId,
      'imagePaths': imagePaths,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,
    };

    if (altitude != null) {
      json['altitude'] = altitude;
    }

    if (altitudeAccuracy != null) {
      json['altitudeAccuracy'] = altitudeAccuracy;
    }

    if (observationText != null) {
      json['observationText'] = observationText;
    }

    return json;
  }

  // Helper method to create from captured data
  factory EvidenceRequest.fromCaptureData({
    required String activityId,
    required String observationId,
    required double latitude,
    required double longitude,
    required String address,
    required double accuracy,
    List<String>? imagePaths,
    double? altitude,
    double? altitudeAccuracy,
    String? observationText,
  }) {
    return EvidenceRequest(
      activityId: activityId,
      observationId: observationId,
      imagePaths: imagePaths ?? [],
      latitude: latitude,
      longitude: longitude,
      address: address,
      accuracy: accuracy,
      altitude: altitude,
      altitudeAccuracy: altitudeAccuracy,
      observationText: observationText,
    );
  }

  @override
  String toString() {
    return 'EvidenceRequest(activity: $activityId, observation: $observationId, images: ${imagePaths.length})';
  }
}
