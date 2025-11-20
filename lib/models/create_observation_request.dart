// models/create_observation_request.dart
class CreateObservationRequest {
  final List<String> observationName;

  CreateObservationRequest({
    required this.observationName,
  });

  Map<String, dynamic> toJson() {
    return {
      'observationName': observationName,
    };
  }
}
