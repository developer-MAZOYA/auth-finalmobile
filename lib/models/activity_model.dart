// models/Activity_model.dart
class Activity {
  final int activityId;
  final String activityTitle;
  final String? description;
  final String? region;
  final Council? assignedCouncil;
  final String? startDate;
  final String? endDate;
  // ... other existing fields

  Activity({
    required this.activityId,
    required this.activityTitle,
    this.description,
    this.region,
    this.assignedCouncil,
    this.startDate,
    this.endDate,
    // ... other existing fields
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['id'] ?? json['activityId'] ?? 0,
      activityTitle: json['title'] ?? json['activityTitle'] ?? '',
      description: json['description'],
      region: json['region'],
      assignedCouncil: json['assignedCouncil'] != null
          ? Council.fromJson(json['assignedCouncil'])
          : null,
      startDate: json['startDate'],
      endDate: json['endDate'],
      // ... other existing fields
    );
  }
}

class Council {
  final int id;
  final String name;

  Council({
    required this.id,
    required this.name,
  });

  factory Council.fromJson(Map<String, dynamic> json) {
    return Council(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
