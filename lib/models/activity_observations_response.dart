// models/activity_observations_response.dart
class ActivityObservationsResponse {
  final String activityTitle;
  final List<String> observations;

  ActivityObservationsResponse({
    required this.activityTitle,
    required this.observations,
  });

  factory ActivityObservationsResponse.fromJson(Map<String, dynamic> json) {
    return ActivityObservationsResponse(
      activityTitle: json['activityTitle'] ?? '',
      observations: List<String>.from(json['observations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityTitle': activityTitle,
      'observations': observations,
    };
  }
}
