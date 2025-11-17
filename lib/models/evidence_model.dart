class Evidence {
  final String id;
  final String imagePath;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final String? description;
  final double? accuracy;
  final double? altitude;
  final double? altitudeAccuracy;
  final String? projectId;

  Evidence({
    required this.id,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    this.description,
    this.accuracy,
    this.altitude,
    this.altitudeAccuracy,
    this.projectId,
  });

  // Convert to GraphQL input format
  Map<String, dynamic> toGraphQLInput() {
    return {
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'accuracy': accuracy,
      'altitude': altitude,
      'altitudeAccuracy': altitudeAccuracy,
      'projectId': projectId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'accuracy': accuracy,
      'altitude': altitude,
      'altitudeAccuracy': altitudeAccuracy,
      'projectId': projectId,
    };
  }

  factory Evidence.fromMap(Map<String, dynamic> map) {
    return Evidence(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      address: map['address'] ?? '',
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      description: map['description'],
      accuracy: map['accuracy'],
      altitude: map['altitude'],
      altitudeAccuracy: map['altitudeAccuracy'],
      projectId: map['projectId'],
    );
  }
}
