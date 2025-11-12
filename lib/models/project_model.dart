import 'package:flutter/foundation.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String region;
  final String council;
  final String startDate;
  final String endDate;
  final DateTime createdAt;
  final List<String> observations;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.region,
    required this.council,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    List<String>? observations,
  }) : observations = observations ?? [];

  // Convert from JSON (API response) to Dart object
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      council: json['council']?.toString() ?? '',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      observations: json['observations'] != null
          ? List<String>.from(json['observations'])
          : null,
    );
  }

  // Convert to JSON (if needed for sending data back)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'region': region,
      'council': council,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt.toIso8601String(),
      'observations': observations,
    };
  }

  // Copy with method to update observations
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? region,
    String? council,
    String? startDate,
    String? endDate,
    DateTime? createdAt,
    List<String>? observations,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      region: region ?? this.region,
      council: council ?? this.council,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      observations: observations ?? this.observations,
    );
  }

  // Add a single observation
  Project addObservation(String observation) {
    final updatedObservations = List<String>.from(observations)
      ..add(observation);
    return copyWith(observations: updatedObservations);
  }

  // Add multiple observations
  Project addObservations(List<String> newObservations) {
    final updatedObservations = List<String>.from(observations)
      ..addAll(newObservations);
    return copyWith(observations: updatedObservations);
  }

  // Remove an observation by index
  Project removeObservation(int index) {
    if (index >= 0 && index < observations.length) {
      final updatedObservations = List<String>.from(observations)
        ..removeAt(index);
      return copyWith(observations: updatedObservations);
    }
    return this;
  }

  // Clear all observations
  Project clearObservations() {
    return copyWith(observations: []);
  }

  // Get observation count
  int get observationCount => observations.length;

  // Check if project has observations
  bool get hasObservations => observations.isNotEmpty;

  // For displaying in UI or debugging
  @override
  String toString() {
    return 'Project: $name (Region: $region, Council: $council, Observations: ${observations.length})';
  }

  // Equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.region == region &&
        other.council == council &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.createdAt == createdAt &&
        listEquals(other.observations, observations);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      region,
      council,
      startDate,
      endDate,
      createdAt,
      Object.hashAll(observations),
    );
  }
}
