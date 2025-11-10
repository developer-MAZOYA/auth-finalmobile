import 'dart:io';
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/image_picker_service.dart';
import '../models/evidence_model.dart';
import 'app_drawer.dart';

class DailyTrackScreen extends StatefulWidget {
  const DailyTrackScreen({super.key});

  @override
  State<DailyTrackScreen> createState() => _DailyTrackScreenState();
}

class _DailyTrackScreenState extends State<DailyTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityDescriptionController = TextEditingController();
  final _timeSpentController = TextEditingController();

  bool _isGettingLocation = false;
  bool _isCapturingImages = false;
  Map<String, dynamic> _currentLocation = {};
  String _locationError = '';

  List<Evidence> _capturedEvidence = [];
  final int _maxImages = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Track Report'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
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
                        'Daily Activity Report',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                          'Activity Description & Resource Available',
                          _activityDescriptionController,
                          maxLines: 3),
                      const SizedBox(height: 12),

                      _buildTextField(
                          'Time Spent (hours)', _timeSpentController),
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
                          child: const Text('Submit Report'),
                        ),
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
          // ADDED LayoutBuilder
          builder: (context, constraints) {
            final crossAxisCount = 3;
            final itemHeight = 120.0; // Fixed height for each item
            final rowCount = (_capturedEvidence.length / crossAxisCount).ceil();
            final totalHeight = (rowCount * itemHeight) + ((rowCount - 1) * 8);

            return SizedBox(
              height: totalHeight, // FIXED: Set explicit height
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
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
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
      // Take multiple pictures sequentially
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
                'Activity evidence - Photo ${_capturedEvidence.length + i + 1}',
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
    if (_formKey.currentState!.validate()) {
      if (_capturedEvidence.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please capture at least one evidence photo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Prepare report data
      final reportData = {
        'activityDescription': _activityDescriptionController.text,
        'timeSpent': _timeSpentController.text,
        'location': _currentLocation,
        'evidence': _capturedEvidence.map((e) => e.toMap()).toList(),
        'submittedAt': DateTime.now().toIso8601String(),
      };

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Submitted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily track report submitted successfully!'),
              const SizedBox(height: 16),
              Text('Activity: ${_activityDescriptionController.text}'),
              Text('Time Spent: ${_timeSpentController.text} hours'),
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
      print('Report Data: $reportData');
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _activityDescriptionController.clear();
    _timeSpentController.clear();
    setState(() {
      _currentLocation = {};
      _locationError = '';
      _capturedEvidence.clear();
    });
  }
}
