import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/image_picker_service.dart';
import '../models/evidence_model.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import 'app_drawer.dart';

class DailyTrackScreen extends StatefulWidget {
  const DailyTrackScreen({super.key});

  @override
  State<DailyTrackScreen> createState() => _DailyTrackScreenState();
}

class _DailyTrackScreenState extends State<DailyTrackScreen> {
  Project? _selectedProject;
  bool _showObservationForm = false;
  String? _selectedObservation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showObservationForm
            ? Text(
                'Observation Details - ${_selectedProject?.name ?? "Project"}')
            : _selectedProject != null
                ? Text('Observations - ${_selectedProject?.name ?? "Project"}')
                : const Text('Select Project'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        leading: _showObservationForm || _selectedProject != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              )
            : null,
      ),
      drawer: const AppDrawer(),
      body: _showObservationForm && _selectedProject != null
          ? ObservationForm(
              selectedProject: _selectedProject!,
              observationText: _selectedObservation!,
            )
          : _selectedProject != null
              ? ProjectObservationsList(
                  selectedProject: _selectedProject!,
                  onObservationSelected: _showObservationFormForProject,
                )
              : const ProjectSelectionList(),
    );
  }

  void _goBack() {
    setState(() {
      if (_showObservationForm) {
        _showObservationForm = false;
        _selectedObservation = null;
      } else if (_selectedProject != null) {
        _selectedProject = null;
      }
    });
  }

  void selectProject(Project project) {
    setState(() {
      _selectedProject = project;
    });
  }

  void _showObservationFormForProject(String observationText) {
    setState(() {
      _selectedObservation = observationText;
      _showObservationForm = true;
    });
  }
}

class ProjectSelectionList extends StatelessWidget {
  const ProjectSelectionList({super.key});

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
            'Select Project',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a project to view its observations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
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
                        Text(
                          'Please add projects first',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
          child: const Icon(Icons.work, color: Colors.blue),
        ),
        title: Text(
          project.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              project.region.isNotEmpty
                  ? project.region
                  : 'No region specified',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              '${project.observationCount} observations',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          final state =
              context.findAncestorStateOfType<_DailyTrackScreenState>();
          state?.selectProject(project);
        },
      ),
    );
  }
}

class ProjectObservationsList extends StatelessWidget {
  final Project selectedProject;
  final Function(String) onObservationSelected;

  const ProjectObservationsList({
    super.key,
    required this.selectedProject,
    required this.onObservationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Info Card
          Card(
            elevation: 4,
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Project',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedProject.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (selectedProject.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      selectedProject.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildProjectDetail('Region', selectedProject.region),
                      const SizedBox(width: 16),
                      _buildProjectDetail('Council', selectedProject.council),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Observations Header
          Row(
            children: [
              const Text(
                'Project Observations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${selectedProject.observationCount}'),
                backgroundColor: Colors.blue[100],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Click on an observation to view and add details',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Observations List
          Expanded(
            child: selectedProject.hasObservations
                ? ListView.builder(
                    itemCount: selectedProject.observations.length,
                    itemBuilder: (context, index) {
                      final observation = selectedProject.observations[index];
                      return _buildObservationCard(observation, index);
                    },
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_off,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No observations yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          'Add observations to this project',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),

          // Add New Observation Button
          if (selectedProject.hasObservations) const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add New Observation'),
              onPressed: () {
                // This would navigate to a form to create a new observation
                _showAddNewObservationDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard(String observation, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getColorForIndex(index),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconForIndex(index),
            color: Colors.white,
          ),
        ),
        title: Text(
          observation.length > 100
              ? '${observation.substring(0, 100)}...'
              : observation,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Observation ${index + 1}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => onObservationSelected(observation),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  IconData _getIconForIndex(int index) {
    final icons = [
      Icons.assignment,
      Icons.description,
      Icons.note,
      Icons.list_alt,
      Icons.fact_check,
      Icons.checklist,
    ];
    return icons[index % icons.length];
  }

  Widget _buildProjectDetail(String label, String value) {
    return Expanded(
      child: Column(
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
      ),
    );
  }

  void _showAddNewObservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Observation'),
        content: const Text(
            'This feature will allow you to create new observations for this project.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ObservationForm extends StatefulWidget {
  final Project selectedProject;
  final String observationText;

  const ObservationForm({
    super.key,
    required this.selectedProject,
    required this.observationText,
  });

  @override
  State<ObservationForm> createState() => _ObservationFormState();
}

class _ObservationFormState extends State<ObservationForm> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _timeSpentController = TextEditingController();

  bool _isGettingLocation = false;
  bool _isCapturingImages = false;
  Map<String, dynamic> _currentLocation = {};
  String _locationError = '';

  List<Evidence> _capturedEvidence = [];
  final int _maxImages = 5;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the existing observation text
    _detailsController.text = widget.observationText;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Observation Header Card
            Card(
              elevation: 4,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Observation Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.selectedProject.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        widget.observationText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Details Form
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add More Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You can add additional details, evidence, and location information to this observation.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      'Additional Details & Findings',
                      _detailsController,
                      maxLines: 4,
                      hintText: 'Add more details about this observation...',
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      'Time Spent (hours)',
                      _timeSpentController,
                      hintText: 'e.g., 2.5, 4, 8',
                    ),
                    const SizedBox(height: 12),

                    // Location Section
                    _buildLocationSection(),
                    const SizedBox(height: 12),

                    // Image Capture Section
                    _buildImageCaptureSection(),
                    const SizedBox(height: 12),

                    // Captured Images Gallery
                    if (_capturedEvidence.isNotEmpty) _buildEvidenceGallery(),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Update Observation with Details',
                          style: TextStyle(fontSize: 16),
                        ),
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

  // All helper methods remain the same as before...
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isGettingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.location_on),
            label: Text(_isGettingLocation
                ? 'Getting Location...'
                : 'Capture Current Location'),
            onPressed: _isGettingLocation ? null : _getCurrentLocation,
          ),
        ),
        const SizedBox(height: 8),
        if (_currentLocation.isNotEmpty && _currentLocation['success'] == true)
          _buildLocationInfo(),
        if (_locationError.isNotEmpty) _buildLocationError(),
      ],
    );
  }

  Widget _buildImageCaptureSection() {
    final remainingImages = _maxImages - _capturedEvidence.length;
    final canTakeMoreImages = remainingImages > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Capture Evidence Images',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Take $remainingImages more photos (Max: $_maxImages)',
          style: TextStyle(
            color: canTakeMoreImages ? Colors.grey : Colors.orange,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isCapturingImages
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt),
            label: Text(
              _isCapturingImages
                  ? 'Capturing Photos...'
                  : canTakeMoreImages
                      ? 'Take $remainingImages Photos'
                      : 'Maximum Photos Reached',
            ),
            onPressed: (canTakeMoreImages && !_isCapturingImages)
                ? _captureMultipleImages
                : null,
          ),
        ),
        if (!canTakeMoreImages) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maximum of $_maxImages photos reached. Remove some to add more.',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEvidenceGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Captured Evidence Photos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = 3;
            final itemHeight = 120.0;
            final rowCount = (_capturedEvidence.length / crossAxisCount).ceil();
            final totalHeight = (rowCount * itemHeight) + ((rowCount - 1) * 8);

            return SizedBox(
              height: totalHeight,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: _capturedEvidence.length,
                itemBuilder: (context, index) {
                  final evidence = _capturedEvidence[index];
                  return _buildEvidenceItem(evidence, index);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEvidenceItem(Evidence evidence, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.file(
                    File(evidence.imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                width: double.infinity,
                color: Colors.grey[50],
                child: Text(
                  'Photo ${index + 1}',
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.white),
              onPressed: () => _removeEvidence(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text(
                'Location Captured',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Address: ${_currentLocation['address']}'),
          Text(
              'Time: ${DateTime.fromMillisecondsSinceEpoch(_currentLocation['timestamp']).toString()}'),
          Text(
              'Coordinates: ${_currentLocation['latitude']?.toStringAsFixed(6)}, ${_currentLocation['longitude']?.toStringAsFixed(6)}'),
        ],
      ),
    );
  }

  Widget _buildLocationError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _locationError,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, String? hintText}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = '';
    });

    try {
      final locationData = await LocationService.getCompleteLocation();

      setState(() {
        _currentLocation = locationData;
        _isGettingLocation = false;

        if (!locationData['success']) {
          _locationError = locationData['error'];
        }
      });
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
        _locationError = 'Failed to get location: $e';
      });
    }
  }

  Future<void> _captureMultipleImages() async {
    if (_currentLocation.isEmpty || _currentLocation['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture location first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final remainingImages = _maxImages - _capturedEvidence.length;
    if (remainingImages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum number of photos reached'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCapturingImages = true;
    });

    try {
      final List<File> capturedImages =
          await ImagePickerService.takeMultiplePictures(remainingImages);

      if (capturedImages.isNotEmpty) {
        final List<Evidence> newEvidence = [];

        for (int i = 0; i < capturedImages.length; i++) {
          final evidence = Evidence(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            imagePath: capturedImages[i].path,
            latitude: _currentLocation['latitude'],
            longitude: _currentLocation['longitude'],
            address: _currentLocation['address'],
            timestamp: DateTime.fromMillisecondsSinceEpoch(
                _currentLocation['timestamp']),
            description:
                '${widget.selectedProject.name} - ${widget.observationText} - Photo ${_capturedEvidence.length + i + 1}',
          );
          newEvidence.add(evidence);
        }

        setState(() {
          _capturedEvidence.addAll(newEvidence);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${capturedImages.length} photos captured with location and timestamp'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No photos were captured'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCapturingImages = false;
      });
    }
  }

  void _removeEvidence(int index) {
    setState(() {
      _capturedEvidence.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _submitForm() {
    // Prepare observation data
    final observationData = {
      'project': {
        'id': widget.selectedProject.id,
        'name': widget.selectedProject.name,
      },
      'originalObservation': widget.observationText,
      'additionalDetails': _detailsController.text,
      'timeSpent': _timeSpentController.text,
      'location': _currentLocation,
      'evidence': _capturedEvidence.map((e) => e.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Observation Updated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Observation details updated successfully!'),
            const SizedBox(height: 16),
            Text('Project: ${widget.selectedProject.name}'),
            Text('Observation: ${widget.observationText}'),
            if (_detailsController.text.isNotEmpty)
              Text('Additional Details: ${_detailsController.text}'),
            if (_timeSpentController.text.isNotEmpty)
              Text('Time Spent: ${_timeSpentController.text} hours'),
            if (_currentLocation.isNotEmpty)
              Text('Location: ${_currentLocation['address']}'),
            Text('Evidence Photos: ${_capturedEvidence.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Here you would typically send the data to your backend
    print('Observation Data: $observationData');
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _detailsController.clear();
    _timeSpentController.clear();
    setState(() {
      _currentLocation = {};
      _locationError = '';
      _capturedEvidence.clear();
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _timeSpentController.dispose();
    super.dispose();
  }
}
