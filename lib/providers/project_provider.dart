import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectProvider with ChangeNotifier {
  final List<Project> _projects = [];

  List<Project> get projects => _projects;

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void removeProject(String projectId) {
    _projects.removeWhere((project) => project.id == projectId);
    notifyListeners();
  }

  void updateProject(Project updatedProject) {
    final index =
        _projects.indexWhere((project) => project.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      notifyListeners();
    }
  }
}
