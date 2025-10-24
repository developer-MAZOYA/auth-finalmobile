class Project {
  final String id;
  final String name;
  final String description;
  final String region;
  final String council;
  final String location;
  final String startDate;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.region,
    required this.council,
    required this.location,
    required this.startDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'region': region,
      'council': council,
      'location': location,
      'startDate': startDate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      region: map['region'] ?? '',
      council: map['council'] ?? '',
      location: map['location'] ?? '',
      startDate: map['startDate'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
