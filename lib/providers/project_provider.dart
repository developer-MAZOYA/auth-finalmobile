import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [
    Project(
      id: '1',
      name: 'Road Construction - Phase 1',
      description: 'Main highway construction project',
      region: 'Dodoma',
      council: 'Chemba Council',
      startDate: '2024-01-01',
      endDate: '2024-12-31',
      createdAt: DateTime.now(),
      observations: [
        'Bridge',
        'Curlvert',
      ],
    ),
    Project(
      id: '2',
      name: 'Bridge Construction',
      description: 'Bridge building renovation',
      region: 'Kilimanjaro',
      council: 'Municipal Council ',
      startDate: '2024-02-01',
      endDate: '2024-08-31',
      createdAt: DateTime.now(),
      observations: [
        'bridge',
      ],
    ),
    Project(
      id: '3',
      name: 'Curvert construction',
      description: 'Clear curvert distribution network',
      region: 'Mbeya',
      council: 'Isyesye council',
      startDate: '2025-03-01',
      endDate: '2025-12-30',
      createdAt: DateTime.now(),
      observations: [],
    ),
  ];

  List<Project> get projects => _projects;

  // Get project by ID
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new project
  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
    _saveToDatabase();
  }

  // Update existing project
  void updateProject(String projectId, Project updatedProject) {
    final index = _projects.indexWhere((project) => project.id == projectId);
    if (index != -1) {
      _projects[index] = updatedProject;
      notifyListeners();
      _saveToDatabase();
    }
  }

  // Delete project
  void deleteProject(String projectId) {
    _projects.removeWhere((project) => project.id == projectId);
    notifyListeners();
    _saveToDatabase();
  }

  // Add observations to a project
  void addObservationsToProject(String projectId, List<String> observations) {
    final index = _projects.indexWhere((project) => project.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updatedProject = project.addObservations(observations);
      _projects[index] = updatedProject;
      notifyListeners();
      _saveToDatabase();
    }
  }

  // Remove observation from a project
  void removeObservationFromProject(String projectId, int observationIndex) {
    final index = _projects.indexWhere((project) => project.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updatedProject = project.removeObservation(observationIndex);
      _projects[index] = updatedProject;
      notifyListeners();
      _saveToDatabase();
    }
  }

  // Clear all observations from a project
  void clearProjectObservations(String projectId) {
    final index = _projects.indexWhere((project) => project.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updatedProject = project.clearObservations();
      _projects[index] = updatedProject;
      notifyListeners();
      _saveToDatabase();
    }
  }

  // Private method to save to database (simulated)
  void _saveToDatabase() {
    // In a real app, this would save to SQLite, Hive, SharedPreferences, or API
    print('Saving projects to database...');
    for (var project in _projects) {
      print(
          'Project: ${project.name}, Observations: ${project.observationCount}');
    }
  }

  // Load from database (simulated)
  void loadFromDatabase() {
    // In a real app, this would load from your database
    // For now, we're using the sample data above
    notifyListeners();
  }
}
