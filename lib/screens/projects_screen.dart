import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import 'app_drawer.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _showObservationForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
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
          : const ProjectsList(),
    );
  }
}

class ProjectsList extends StatelessWidget {
  const ProjectsList({super.key});

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
            'Projects',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${projects.length} project${projects.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: projects.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No projects available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return _buildProjectCard(context, project);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.work,
            color: Colors.blue[700],
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${project.observationCount} observations',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(project: project),
            ),
          );
        },
      ),
    );
  }
}

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Details Card
            Card(
              elevation: 4,
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
                    const SizedBox(height: 16),
                    _buildDetailItem('Region:', project.region),
                    _buildDetailItem('Council:', project.council),
                    _buildDetailItem(
                        'Start Date:', _formatDate(project.startDate)),
                    _buildDetailItem('End Date:', _formatDate(project.endDate)),
                    if (project.description.isNotEmpty)
                      _buildDetailItem('Description:', project.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Observations Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Observations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('${project.observationCount}'),
                          backgroundColor: Colors.blue[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (project.hasObservations)
                      ...project.observations.asMap().entries.map((entry) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.visibility_off,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No observations yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add observations to track ${project.name}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
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
      ),
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

// AddObservationForm remains exactly the same as before
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
