import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import 'app_drawer.dart';

class ObservationScreen extends StatefulWidget {
  const ObservationScreen({super.key});

  @override
  State<ObservationScreen> createState() => _ObservationScreenState();
}

class _ObservationScreenState extends State<ObservationScreen> {
  bool _showObservationForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Observations'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        actions: [
          if (!_showObservationForm)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _showObservationForm = true;
                });
              },
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _showObservationForm
          ? AddObservationForm(
              onSave: () {
                setState(() {
                  _showObservationForm = false;
                });
              },
              onCancel: () {
                setState(() {
                  _showObservationForm = false;
                });
              },
            )
          : const ProjectsObservationList(),
    );
  }
}

class ProjectsObservationList extends StatelessWidget {
  const ProjectsObservationList({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Observations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: projects.isEmpty
                ? const Center(
                    child: Text(
                      'No projects available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
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
                  backgroundColor: project.hasObservations
                      ? Colors.green[50]
                      : Colors.grey[200],
                  label: Text(
                    '${project.observationCount} observations',
                    style: TextStyle(
                      color:
                          project.hasObservations ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Project Details
            _buildDetailRow('Region:', project.region),
            const SizedBox(height: 6),
            _buildDetailRow('Council:', project.council),
            const SizedBox(height: 6),
            _buildDetailRow('Duration:',
                '${_formatDate(project.startDate)} - ${_formatDate(project.endDate)}'),

            // Description
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildDetailRow('Description:', project.description),
            ],

            // Observations List
            if (project.hasObservations)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Observations:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...project.observations
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.circle,
                                    size: 8, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${entry.key + 1}. ${entry.value}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Not specified',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Not specified';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class AddObservationForm extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const AddObservationForm({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddObservationForm> createState() => _AddObservationFormState();
}

class _AddObservationFormState extends State<AddObservationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProjectId;
  Project? _selectedProject;
  List<TextEditingController> _observationControllers = [
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onCancel,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add New Observations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Project Dropdown
            DropdownButtonFormField<String>(
              value: _selectedProjectId,
              decoration: const InputDecoration(
                labelText: 'Select Project',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              items: projects.map((project) {
                return DropdownMenuItem<String>(
                  value: project.id,
                  child: Text(project.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value;
                  _selectedProject = projects.firstWhere(
                    (p) => p.id == value,
                    orElse: () => Project(
                      id: '',
                      name: '',
                      description: '',
                      region: '',
                      council: '',
                      startDate: '',
                      endDate: '',
                      createdAt: DateTime.now(),
                    ),
                  );
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a project';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Project Details Card - Only shows when a project is selected
            if (_selectedProject != null && _selectedProjectId != null)
              _buildProjectDetailsCard(),

            const SizedBox(height: 20),

            // Observation fields
            const Text(
              'Observation Issues',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _observationControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _observationControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Observation ${index + 1}',
                              border: const OutlineInputBorder(),
                              suffixIcon: _observationControllers.length > 1
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _observationControllers
                                              .removeAt(index);
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter an observation';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Add issue button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _observationControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Another Observation'),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveObservations,
                    child: const Text('Save Observations'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetailsCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            // Project Name
            _buildDetailRow('Project Name:', _selectedProject!.name),
            const SizedBox(height: 8),

            // Description
            if (_selectedProject!.description.isNotEmpty)
              Column(
                children: [
                  _buildDetailRow(
                      'Description:', _selectedProject!.description),
                  const SizedBox(height: 8),
                ],
              ),

            // Region and Council in a row
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow('Region:', _selectedProject!.region),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailRow('Council:', _selectedProject!.council),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Start and End Date in a row
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                      'Start Date:', _formatDate(_selectedProject!.startDate)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailRow(
                      'End Date:', _formatDate(_selectedProject!.endDate)),
                ),
              ],
            ),

            // Existing observations count
            if (_selectedProject!.hasObservations) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Current Observations:',
                  '${_selectedProject!.observationCount} observations'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : 'Not specified',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Not specified';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _saveObservations() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a project first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final observations = _observationControllers
          .map((controller) => controller.text.trim())
          .where((obs) => obs.isNotEmpty)
          .toList();

      if (observations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter at least one observation.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Save observations using the provider
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);
      projectProvider.addObservationsToProject(
          _selectedProject!.id, observations);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${observations.length} observations saved for ${_selectedProject!.name}'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onSave();
    }
  }

  @override
  void dispose() {
    for (var controller in _observationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
