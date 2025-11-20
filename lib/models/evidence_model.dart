class Evidence {
  final String evidenceId;
  final String activityId;
  final String observationId;
  final List<String> imagePaths; // CHANGED: Now supports multiple images
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final double accuracy;
  final double? altitude;
  final double? altitudeAccuracy;

  Evidence({
    required this.evidenceId,
    required this.activityId,
    required this.observationId,
    required this.imagePaths, // CHANGED
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    required this.accuracy,
    this.altitude,
    this.altitudeAccuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'evidenceId': evidenceId,
      'activityId': activityId,
      'observationId': observationId,
      'imagePaths': imagePaths, // CHANGED
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
      'altitude': altitude,
      'altitudeAccuracy': altitudeAccuracy,
    };
  }

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      evidenceId: json['evidenceId']?.toString() ?? '',
      activityId: json['activityId']?.toString() ?? '',
      observationId: json['observationId']?.toString() ?? '',
      imagePaths: List<String>.from(json['imagePaths'] ?? []), // CHANGED
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble(),
      altitudeAccuracy: (json['altitudeAccuracy'] as num?)?.toDouble(),
    );
  }

  int get imageCount => imagePaths.length;
  bool get hasImages => imagePaths.isNotEmpty;
}

class EvidenceRequest {
  final String activityId;
  final String observationId;
  final List<String> imagePaths; // CHANGED: Now multiple images
  final double latitude;
  final double longitude;
  final String address;
  final double accuracy;
  final double? altitude;
  final double? altitudeAccuracy;

  EvidenceRequest({
    required this.activityId,
    required this.observationId,
    required this.imagePaths, // CHANGED
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.accuracy,
    this.altitude,
    this.altitudeAccuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'observationId': observationId,
      'imagePaths': imagePaths, // CHANGED
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,
      'altitude': altitude,
      'altitudeAccuracy': altitudeAccuracy,
    };
  }
}
