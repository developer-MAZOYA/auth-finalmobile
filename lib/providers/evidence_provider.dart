import 'dart:math' as Math;

import 'package:flutter/foundation.dart';
import '../models/evidence_model.dart';

class EvidenceProvider with ChangeNotifier {
  List<Evidence> _evidenceList = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Evidence> get evidenceList => _evidenceList;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get totalEvidenceCount => _evidenceList.length;

  // Get evidence by observation
  List<Evidence> getEvidenceByObservation(String observationId) {
    return _evidenceList
        .where((evidence) => evidence.observationId == observationId)
        .toList();
  }

  // Get evidence by activity
  List<Evidence> getEvidenceByActivity(String activityId) {
    return _evidenceList
        .where((evidence) => evidence.activityId == activityId)
        .toList();
  }

  // Group evidence by date
  Map<String, List<Evidence>> getEvidenceGroupedByDate() {
    final Map<String, List<Evidence>> groupedEvidence = {};

    for (final evidence in _evidenceList) {
      final date = _formatDate(evidence.timestamp);
      if (!groupedEvidence.containsKey(date)) {
        groupedEvidence[date] = [];
      }
      groupedEvidence[date]!.add(evidence);
    }

    // Sort each day's evidence by timestamp (newest first)
    groupedEvidence.forEach((date, evidences) {
      evidences.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });

    return groupedEvidence;
  }

  // Set evidence list
  void setEvidence(List<Evidence> evidence) {
    _evidenceList = evidence;
    _sortEvidenceByDate();
    _error = '';
    notifyListeners();
  }

  // Add single evidence
  void addEvidence(Evidence evidence) {
    _evidenceList.add(evidence);
    _sortEvidenceByDate();
    notifyListeners();
  }

  // Add multiple evidence
  void addMultipleEvidence(List<Evidence> evidenceList) {
    _evidenceList.addAll(evidenceList);
    _sortEvidenceByDate();
    notifyListeners();
  }

  // Remove evidence
  void removeEvidence(String evidenceId) {
    _evidenceList.removeWhere((evidence) => evidence.evidenceId == evidenceId);
    notifyListeners();
  }

  // Update evidence
  void updateEvidence(Evidence updatedEvidence) {
    final index = _evidenceList.indexWhere(
      (evidence) => evidence.evidenceId == updatedEvidence.evidenceId,
    );
    if (index != -1) {
      _evidenceList[index] = updatedEvidence;
      _sortEvidenceByDate();
      notifyListeners();
    }
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  // Clear evidence
  void clearEvidence() {
    _evidenceList.clear();
    _error = '';
    notifyListeners();
  }

  // Check if observation has minimum evidence (3 images)
  bool hasMinimumEvidenceForObservation(String observationId) {
    final observationEvidence = getEvidenceByObservation(observationId);
    return observationEvidence.length >= 3;
  }

  // Check if observation has reached maximum evidence (5 images)
  bool hasMaximumEvidenceForObservation(String observationId) {
    final observationEvidence = getEvidenceByObservation(observationId);
    return observationEvidence.length >= 5;
  }

  // Get evidence count for observation
  int getEvidenceCountForObservation(String observationId) {
    return getEvidenceByObservation(observationId).length;
  }

  // Validate location compliance for observation (all within 3 meters)
  bool isLocationCompliantForObservation(String observationId) {
    final observationEvidence = getEvidenceByObservation(observationId);

    if (observationEvidence.length <= 1) return true;

    final firstEvidence = observationEvidence.first;
    for (final evidence in observationEvidence) {
      final distance = _calculateDistance(
        firstEvidence.latitude,
        firstEvidence.longitude,
        evidence.latitude,
        evidence.longitude,
      );
      if (distance > 3.0) {
        return false;
      }
    }
    return true;
  }

  // Get compliance status for observation
  Map<String, dynamic> getComplianceStatus(String observationId) {
    final evidenceCount = getEvidenceCountForObservation(observationId);
    final hasMinImages = evidenceCount >= 3;
    final hasMaxImages = evidenceCount <= 5;
    final hasValidLocations = isLocationCompliantForObservation(observationId);
    final isCompliant = hasMinImages && hasMaxImages && hasValidLocations;

    return {
      'observationId': observationId,
      'evidenceCount': evidenceCount,
      'hasMinimumImages': hasMinImages,
      'hasMaximumImages': hasMaxImages,
      'hasValidLocations': hasValidLocations,
      'isCompliant': isCompliant,
      'message': _generateComplianceMessage(
          hasMinImages, hasMaxImages, hasValidLocations),
    };
  }

  // Private methods
  void _sortEvidenceByDate() {
    _evidenceList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    // Haversine formula for distance calculation
    const double earthRadius = 6371000; // meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);

    final double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_toRadians(lat1)) *
            Math.cos(_toRadians(lat2)) *
            Math.sin(dLng / 2) *
            Math.sin(dLng / 2);

    final double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * Math.pi / 180;
  }

  String _generateComplianceMessage(
      bool minImages, bool maxImages, bool validLocations) {
    if (minImages && maxImages && validLocations) {
      return 'Evidence collection is fully compliant';
    }

    final issues = <String>[];
    if (!minImages) issues.add('minimum 3 images required');
    if (!maxImages) issues.add('maximum 5 images exceeded');
    if (!validLocations) issues.add('location variance too high');

    return 'Compliance issues: ${issues.join(', ')}';
  }
}
