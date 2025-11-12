import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import 'app_drawer.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      drawer: const AppDrawer(),
      body: const ProjectsList(),
    );
  }
}

class ProjectsList extends StatelessWidget {
  const ProjectsList({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    // In a real app, you would filter projects by the current user
    // For now, we'll show all projects as assigned to the user
    final userProjects = projects; // You can filter here based on user ID

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Assigned Projects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${userProjects.length} project${userProjects.length != 1 ? 's' : ''} assigned to you',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: userProjects.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No projects assigned',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          'You will see your projects here once assigned',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: userProjects.length,
                    itemBuilder: (context, index) {
                      final project = userProjects[index];
                      return _buildProjectCard(project);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Chip(
                  backgroundColor: _getStatusColor(project),
                  label: Text(
                    _getStatusText(project),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Project Description
            if (project.description.isNotEmpty) ...[
              Text(
                project.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Project Details
            Row(
              children: [
                _buildDetailItem(Icons.location_on, project.region),
                const SizedBox(width: 16),
                _buildDetailItem(Icons.account_balance, project.council),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                _buildDetailItem(Icons.calendar_today,
                    'Start: ${_formatDate(project.startDate)}'),
                const SizedBox(width: 16),
                _buildDetailItem(Icons.calendar_today,
                    'End: ${_formatDate(project.endDate)}'),
              ],
            ),
            const SizedBox(height: 12),

            // Observations Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //  const Icon(Icons.observation, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${project.observationCount} observations',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text.isNotEmpty ? text : 'Not specified',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(Project project) {
    // Simple status determination based on dates
    final now = DateTime.now();
    final endDate = DateTime.tryParse(project.endDate);

    if (endDate == null) return Colors.blue;

    if (now.isAfter(endDate)) {
      return Colors.green; // Completed
    } else {
      return Colors.orange; // In Progress
    }
  }

  String _getStatusText(Project project) {
    final now = DateTime.now();
    final endDate = DateTime.tryParse(project.endDate);

    if (endDate == null) return 'Active';

    if (now.isAfter(endDate)) {
      return 'Completed';
    } else {
      return 'In Progress';
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
