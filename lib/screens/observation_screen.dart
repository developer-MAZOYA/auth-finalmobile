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
  final _formKey = GlobalKey<FormState>();
  String? _selectedProjectId;
  List<TextEditingController> _observationControllers = [
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Observations'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Project to Observe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter an observation';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_observationControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _observationControllers.removeAt(index);
                                });
                              },
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

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveObservations,
                  child: const Text('Save Observations'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveObservations() {
    if (_formKey.currentState!.validate()) {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);
      final selectedProject = projectProvider.projects.firstWhere(
        (p) => p.id == _selectedProjectId,
      );

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

      // Here you can save to local DB or API
      print('Observations for ${selectedProject.name}: $observations');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Observations saved for ${selectedProject.name}'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      setState(() {
        _selectedProjectId = null;
        _observationControllers = [TextEditingController()];
      });
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
