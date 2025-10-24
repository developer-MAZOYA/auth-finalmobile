import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/region_service.dart';
import '../models/region_model.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import 'app_drawer.dart';

class ProjectRegistrationScreen extends StatefulWidget {
  const ProjectRegistrationScreen({super.key});

  @override
  State<ProjectRegistrationScreen> createState() =>
      _ProjectRegistrationScreenState();
}

class _ProjectRegistrationScreenState extends State<ProjectRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showForm = false;

  // Form controllers
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _startDateController = TextEditingController();

  // Dropdown values
  String? _selectedRegion;
  String? _selectedCouncil;

  // Filtered councils based on selected region
  List<Council> _filteredCouncils = [];

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Registration'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Show form or list based on _showForm state
          if (_showForm) _buildRegistrationForm(),
          if (!_showForm) _buildProjectsList(projects),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showForm = !_showForm;
            if (!_showForm) {
              // Reset form when hiding it
              _resetForm();
            }
          });
        },
        backgroundColor: const Color(0xFF6786ee),
        child: Icon(
          _showForm ? Icons.close : Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Register New Project',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Region Dropdown
                      _buildRegionDropdown(),
                      const SizedBox(height: 12),

                      // Council Dropdown (only shown when region is selected)
                      if (_selectedRegion != null) _buildCouncilDropdown(),
                      if (_selectedRegion != null) const SizedBox(height: 12),

                      _buildTextField('Project Name', _projectNameController),
                      const SizedBox(height: 12),

                      _buildTextField(
                          'Project Description', _projectDescriptionController,
                          maxLines: 3),
                      const SizedBox(height: 12),

                      _buildTextField('Specific Location', _locationController),
                      const SizedBox(height: 12),

                      _buildTextField('Start Date', _startDateController,
                          isDate: true),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _showForm = false;
                                  _resetForm();
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text('Register Project'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList(List<Project> projects) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registered Projects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (projects.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No projects registered yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to add your first project',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6786ee).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.work,
                            color: const Color(0xFF6786ee),
                          ),
                        ),
                        title: Text(
                          project.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Region: ${project.region}'),
                            Text('Council: ${project.council}'),
                            Text('Start Date: ${project.startDate}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () {
                            _showDeleteDialog(context, project);
                          },
                        ),
                        onTap: () {
                          // You can add project details view here
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRegion,
      decoration: const InputDecoration(
        labelText: 'Select Region',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.map),
      ),
      items: RegionService.regions.map((region) {
        return DropdownMenuItem<String>(
          value: region.name,
          child: Text(region.name),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRegion = newValue;
          _selectedCouncil = null;
          if (newValue != null) {
            _filteredCouncils = RegionService.getCouncilsByRegionName(newValue);
          } else {
            _filteredCouncils = [];
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a region';
        }
        return null;
      },
    );
  }

  Widget _buildCouncilDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCouncil,
      decoration: const InputDecoration(
        labelText: 'Select Council',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_city),
      ),
      items: _filteredCouncils.map((council) {
        return DropdownMenuItem<String>(
          value: council.name,
          child: Text(council.name),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCouncil = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a council';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isDate = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: isDate
            ? IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);

      final newProject = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _projectNameController.text,
        description: _projectDescriptionController.text,
        region: _selectedRegion!,
        council: _selectedCouncil!,
        location: _locationController.text,
        startDate: _startDateController.text,
        createdAt: DateTime.now(),
      );

      projectProvider.addProject(newProject);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form and show list
      setState(() {
        _showForm = false;
        _resetForm();
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _projectNameController.clear();
    _projectDescriptionController.clear();
    _locationController.clear();
    _startDateController.clear();
    setState(() {
      _selectedRegion = null;
      _selectedCouncil = null;
      _filteredCouncils = [];
    });
  }

  void _showDeleteDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final projectProvider =
                  Provider.of<ProjectProvider>(context, listen: false);
              projectProvider.removeProject(project.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${project.name}" deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    super.dispose();
  }
}
