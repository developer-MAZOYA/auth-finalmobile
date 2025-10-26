class Evidence {
  final String id;
  final String imagePath;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final String? description;

  Evidence({
    required this.id,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
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
    );
  }
}
