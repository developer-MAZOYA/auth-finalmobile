import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/activity_model.dart';

class ActivityProvider with ChangeNotifier {
  final List<Activity> _assignedActivities = [];
  final String baseUrl = 'http://192.168.1.190:8080/api/site-monitoring';

  // Hardcoded values as requested
  final int userId = 2;
  final int activityId = 1;
  final int councilId = 1;

  List<Activity> get assignedActivities => _assignedActivities;

  // 1. Get User's Assigned Activities (Titles only)
  Future<List<Activity>> fetchUserAssignedActivities() async {
    try {
      if (kDebugMode) {
        print('Fetching assigned activities for user ID: $userId');
        print('URL: $baseUrl/user-activities?userId=$userId');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user-activities?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> activitiesData = responseData['data'];

          _assignedActivities.clear();

          for (var activityData in activitiesData) {
            // Create a basic activity object with just id and title
            final Activity activity = Activity(
              activityId: activityData['id'],
              activityTitle: activityData['title'],
              // Other fields will be null until we fetch details
            );
            _assignedActivities.add(activity);
          }

          notifyListeners();

          if (kDebugMode) {
            print(
                'Successfully fetched ${_assignedActivities.length} assigned activities');
          }

          return _assignedActivities;
        } else {
          if (kDebugMode) {
            print('API returned success: false');
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch assigned activities: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching assigned activities: $e');
      }
      return [];
    }
  }

  // 2. Get Activity Details (User-Specific)
  Future<Activity?> fetchActivityDetails() async {
    try {
      if (kDebugMode) {
        print(
            'Fetching activity details for activity ID: $activityId and user ID: $userId');
        print('URL: $baseUrl/activities/$activityId/details?userId=$userId');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/activities/$activityId/details?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final Map<String, dynamic> activityData = responseData['data'];

          // Create Activity object from the detailed response
          final Activity activity = Activity(
            activityId: activityData['id'],
            activityTitle: activityData['title'],
            description: activityData['description'] ?? '',
            region: activityData['region'] ?? '',
            assignedCouncil: activityData['assignedCouncil'] != null
                ? Council.fromJson(activityData['assignedCouncil'])
                : null,
            startDate: activityData['startDate'] ?? '',
            endDate: activityData['endDate'] ?? '',
          );

          // Update the activity in the list if it exists
          final existingIndex = _assignedActivities
              .indexWhere((a) => a.activityId == activity.activityId);
          if (existingIndex != -1) {
            _assignedActivities[existingIndex] = activity;
          } else {
            _assignedActivities.add(activity);
          }

          notifyListeners();
          return activity;
        } else {
          if (kDebugMode) {
            print('API returned success: false');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch activity details: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching activity details: $e');
      }
      return null;
    }
  }

  // 3. Assign Activity to User
  Future<bool> assignActivity() async {
    try {
      if (kDebugMode) {
        print(
            'Assigning activity ID: $activityId to user ID: $userId for council ID: $councilId');
        print(
            'URL: $baseUrl/assign?userId=$userId&activityId=$activityId&councilId=$councilId');
      }

      final response = await http.post(
        Uri.parse(
            '$baseUrl/assign?userId=$userId&activityId=$activityId&councilId=$councilId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          if (kDebugMode) {
            print('Activity assigned successfully');
          }
          return true;
        } else {
          if (kDebugMode) {
            print('Assignment failed: ${responseData['message']}');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print('Failed to assign activity: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error assigning activity: $e');
      }
      return false;
    }
  }

  // 4. Unassign Activity
  Future<bool> unassignActivity() async {
    try {
      if (kDebugMode) {
        print(
            'Unassigning activity ID: $activityId from user ID: $userId for council ID: $councilId');
        print(
            'URL: $baseUrl/unassign?userId=$userId&activityId=$activityId&councilId=$councilId');
      }

      final response = await http.delete(
        Uri.parse(
            '$baseUrl/unassign?userId=$userId&activityId=$activityId&councilId=$councilId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          if (kDebugMode) {
            print('Activity unassigned successfully');
          }

          // Remove from local list
          _assignedActivities.removeWhere((a) => a.activityId == activityId);
          notifyListeners();

          return true;
        } else {
          if (kDebugMode) {
            print('Unassignment failed: ${responseData['message']}');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print('Failed to unassign activity: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unassigning activity: $e');
      }
      return false;
    }
  }

  // Get specific assigned activity by ID
  Activity? getAssignedActivityById(int id) {
    try {
      return _assignedActivities
          .firstWhere((activity) => activity.activityId == id);
    } catch (e) {
      return null;
    }
  }

  // Get the hardcoded activity (ID 1)
  Activity? getHardcodedActivity() {
    return getAssignedActivityById(activityId);
  }

  // Check if activity is assigned
  bool isActivityAssigned(int id) {
    return _assignedActivities.any((activity) => activity.activityId == id);
  }

  // Clear all assigned activities
  void clearAssignedActivities() {
    _assignedActivities.clear();
    notifyListeners();
  }

  // Get assignment statistics
  Map<String, int> getAssignmentStatistics() {
    return {
      'totalAssigned': _assignedActivities.length,
      'hasDetails': _assignedActivities
          .where((a) => a.description != null && a.description!.isNotEmpty)
          .length,
    };
  }
}
