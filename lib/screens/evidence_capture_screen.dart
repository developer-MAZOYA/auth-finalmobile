import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/image_picker_service.dart';
import '../services/evidence_api_service.dart';
import '../models/evidence_model.dart';
import '../models/activity_model.dart';
import '../providers/evidence_provider.dart';

class EvidenceCaptureScreen extends StatefulWidget {
  final Activity activity;
  final int observationId;
  final String observationName;
  final int userId;

  const EvidenceCaptureScreen({
    super.key,
    required this.activity,
    required this.observationId,
    required this.observationName,
    required this.userId,
  });

  @override
  State<EvidenceCaptureScreen> createState() => _EvidenceCaptureScreenState();
}

class _EvidenceCaptureScreenState extends State<EvidenceCaptureScreen> {
  final int _minImages = 3;
  final int _maxImages = 5;

  bool _isGettingLocation = false;
  bool _isSubmitting = false;
  bool _isCapturingImage = false;
  Map<String, dynamic> _currentLocation = {};
  String _locationError = '';

  List<File> _capturedImages = [];
  final TextEditingController _observationTextController =
      TextEditingController();

  // Step management
  int _currentStep = 1;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _observationTextController.text = widget.observationName;
  }

  @override
  void dispose() {
    _observationTextController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Evidence - ${widget.activity.activityTitle}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Location and Description
                _buildLocationStep(),

                // Step 2: Image Capture
                _buildImageCaptureStep(),

                // Step 3: Review and Submit
                _buildReviewStep(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepCircle(1, 'Location'),
              Expanded(
                child: Container(
                  height: 2,
                  color: _currentStep > 1 ? Colors.blue : Colors.grey[300],
                ),
              ),
              _buildStepCircle(2, 'Photos'),
              Expanded(
                child: Container(
                  height: 2,
                  color: _currentStep > 2 ? Colors.blue : Colors.grey[300],
                ),
              ),
              _buildStepCircle(3, 'Submit'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStepTitle(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber, String label) {
    final bool isActive = _currentStep == stepNumber;
    final bool isCompleted = _currentStep > stepNumber;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isActive
                    ? Colors.blue
                    : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Step 1: Capture Location & Add Details';
      case 2:
        return 'Step 2: Capture Evidence Photos';
      case 3:
        return 'Step 3: Review & Submit Evidence';
      default:
        return '';
    }
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Observation Info Card
          _buildObservationInfoCard(),
          const SizedBox(height: 20),

          // Location Section
          _buildLocationSection(),
          const SizedBox(height: 20),

          // Observation Text Field
          _buildObservationTextField(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildImageCaptureStep() {
    final remainingImages = _maxImages - _capturedImages.length;
    final canTakeMoreImages = remainingImages > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Summary
          if (_currentLocation.isNotEmpty &&
              _currentLocation['success'] == true)
            _buildLocationSummary(),
          const SizedBox(height: 20),

          // Image Capture Section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.camera_alt, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Evidence Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capture $_minImages-$_maxImages photos for this evidence',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: _capturedImages.length >= _minImages
                              ? Colors.green
                              : Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_capturedImages.length}/$_maxImages photos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _capturedImages.length >= _minImages
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: _capturedImages.length / _maxImages,
                                backgroundColor: Colors.grey[200],
                                color: _capturedImages.length >= _minImages
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Capture buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isCapturingImage
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_a_photo),
                      label: const Text('Take Single Photo'),
                      onPressed: (canTakeMoreImages && !_isCapturingImage)
                          ? _takePhoto
                          : null,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isCapturingImage
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_library),
                      label: Text(
                          'Take ${remainingImages > 1 ? remainingImages : 1} Photos'),
                      onPressed: (canTakeMoreImages && !_isCapturingImage)
                          ? _takeMultiplePhotos
                          : null,
                    ),
                  ),

                  if (!canTakeMoreImages) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Maximum of $_maxImages photos reached.',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Captured Images Gallery
                  if (_capturedImages.isNotEmpty) _buildImageGallery(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final hasLocation =
        _currentLocation.isNotEmpty && _currentLocation['success'] == true;
    final hasMinimumImages = _capturedImages.length >= _minImages;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review Summary Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.task, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ready to Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildReviewItem(
                    Icons.check_circle,
                    'Location Captured',
                    hasLocation ? 'Completed' : 'Missing',
                    hasLocation ? Colors.green : Colors.red,
                  ),
                  _buildReviewItem(
                    Icons.description,
                    'Observation Details',
                    '${_observationTextController.text.length} characters',
                    Colors.blue,
                  ),
                  _buildReviewItem(
                    Icons.photo_library,
                    'Evidence Photos',
                    '${_capturedImages.length}/$_minImages min',
                    hasMinimumImages ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Location Review
          if (hasLocation) _buildLocationSummary(),
          const SizedBox(height: 20),

          // Observation Text Review
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Observation Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _observationTextController.text.isNotEmpty
                        ? _observationTextController.text
                        : 'No additional details provided',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Images Preview
          if (_capturedImages.isNotEmpty)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_library, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_capturedImages.length} Evidence Photos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasMinimumImages
                                ? Colors.green[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_capturedImages.length}/$_minImages',
                            style: TextStyle(
                              color: hasMinimumImages
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _capturedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _capturedImages[index],
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.red),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
      IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ),
          Icon(
            value == 'Missing' ? Icons.error : Icons.check,
            color: value == 'Missing' ? Colors.red : color,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📍 ${_currentLocation['address']}'),
                  const SizedBox(height: 4),
                  Text(
                      '🌐 ${_currentLocation['latitude']?.toStringAsFixed(6)}, ${_currentLocation['longitude']?.toStringAsFixed(6)}'),
                  if (_currentLocation['accuracy'] != null)
                    Text(
                        '📏 Accuracy: ${_currentLocation['accuracy']?.toStringAsFixed(2)}m'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final hasLocation =
        _currentLocation.isNotEmpty && _currentLocation['success'] == true;
    final hasMinimumImages = _capturedImages.length >= _minImages;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 1) const SizedBox(width: 12),

          // Next/Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                switch (_currentStep) {
                  case 1:
                    if (hasLocation) {
                      _goToNextStep();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please capture location first'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    break;
                  case 2:
                    if (hasMinimumImages) {
                      _goToNextStep();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Minimum $_minImages photos required. You have ${_capturedImages.length}'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    break;
                  case 3:
                    _submitEvidence();
                    break;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == 3 ? Colors.green : Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting && _currentStep == 3
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 3 ? 'Submit Evidence' : 'Continue',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        if (_currentStep != 3) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 20),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationInfoCard() {
    return Card(
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
                  'Evidence Capture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Activity: ${widget.activity.activityTitle}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Observation:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    widget.observationName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.photo_library,
                  size: 16,
                  color: _capturedImages.length >= _minImages
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Images: ${_capturedImages.length}/$_maxImages',
                  style: TextStyle(
                    fontSize: 14,
                    color: _capturedImages.length >= _minImages
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (_capturedImages.length < _minImages) ...[
              const SizedBox(height: 4),
              Text(
                'Minimum $_minImages images required',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 8),
                Text(
                  'Location Capture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture your current location. All evidence images will be tagged with this location.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isGettingLocation
                    ? 'Getting Location...'
                    : 'Capture Current Location'),
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
              ),
            ),
            const SizedBox(height: 8),
            if (_currentLocation.isNotEmpty &&
                _currentLocation['success'] == true)
              _buildLocationInfo(),
            if (_locationError.isNotEmpty) _buildLocationError(),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationTextField() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, size: 20),
                SizedBox(width: 8),
                Text(
                  'Observation Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Add additional details about this observation (optional)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _observationTextController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Observation Text',
                hintText: 'Enter additional details about this observation...',
              ),
            ),
          ],
        ),
      ),
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
                'Location Captured Successfully',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('📍 ${_currentLocation['address']}'),
          Text(
              '🌐 ${_currentLocation['latitude']?.toStringAsFixed(6)}, ${_currentLocation['longitude']?.toStringAsFixed(6)}'),
          Text(
              '📏 Accuracy: ${_currentLocation['accuracy']?.toStringAsFixed(2)}m'),
          if (_currentLocation['altitude'] != null)
            Text(
                '⛰️ Altitude: ${_currentLocation['altitude']?.toStringAsFixed(2)}m'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _locationError,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Captured Photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _capturedImages.length >= _minImages
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _capturedImages.length >= _minImages
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  child: Text(
                    '${_capturedImages.length}/$_minImages min',
                    style: TextStyle(
                      fontSize: 12,
                      color: _capturedImages.length >= _minImages
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_capturedImages.length} photos ready for submission',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: _capturedImages.length,
              itemBuilder: (context, index) {
                return _buildImageItem(_capturedImages[index], index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(File image, int index) {
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
                    image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child:
                            const Icon(Icons.broken_image, color: Colors.red),
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
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _goToNextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
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

  Future<void> _takePhoto() async {
    if (_capturedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum of $_maxImages photos reached'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCapturingImage = true;
    });

    try {
      final File? capturedImage = await ImagePickerService.takePicture();

      if (capturedImage != null) {
        setState(() {
          _capturedImages.add(capturedImage);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCapturingImage = false;
      });
    }
  }

  Future<void> _takeMultiplePhotos() async {
    final remainingImages = _maxImages - _capturedImages.length;
    if (remainingImages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum of $_maxImages photos reached'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCapturingImage = true;
    });

    try {
      final List<File> capturedImages =
          await ImagePickerService.takeMultiplePictures(remainingImages);

      if (capturedImages.isNotEmpty) {
        setState(() {
          _capturedImages.addAll(capturedImages);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${capturedImages.length} photos captured successfully'),
            backgroundColor: Colors.green,
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
        _isCapturingImage = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _submitEvidence() async {
    if (_capturedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No photos to submit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_capturedImages.length < _minImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Minimum $_minImages photos required. You have ${_capturedImages.length}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentLocation.isEmpty || _currentLocation['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture location first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    print('🚀 Starting evidence submission...');
    print('📸 Images to upload: ${_capturedImages.length}');
    print(
        '📍 Location: ${_currentLocation['latitude']}, ${_currentLocation['longitude']}');
    print('🌐 Using endpoint: createEvidenceWithImageUpload');

    try {
      final evidenceProvider =
          Provider.of<EvidenceProvider>(context, listen: false);

      // ✅ CORRECT: Use createEvidenceWithImageUpload (sends files via multipart)
      final evidence = await EvidenceApiService.createEvidenceWithImageUpload(
        userId: widget.userId,
        activityId: int.parse(widget.activity.activityId.toString()),
        observationId: widget.observationId,
        imageFiles: _capturedImages, // Send ALL images at once
        latitude: _currentLocation['latitude'],
        longitude: _currentLocation['longitude'],
        address: _currentLocation['address'],
        accuracy: _currentLocation['accuracy']?.toDouble() ?? 0.0,
        altitude: _currentLocation['altitude']?.toDouble(),
        altitudeAccuracy: _currentLocation['speedAccuracy']?.toDouble(),
        observationText: _observationTextController.text.isNotEmpty
            ? _observationTextController.text
            : widget.observationName,
      );

      // Add to provider
      evidenceProvider.addEvidence(evidence);

      print('✅ Evidence created successfully: ID ${evidence.evidenceId}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Successfully submitted evidence with ${_capturedImages.length} images'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to evidence list
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error details: $e');

      String errorMessage = 'Failed to submit evidence';
      if (e.toString().contains('400')) {
        errorMessage = 'Bad request - server validation failed';
      } else if (e.toString().contains('Evidence must have at least')) {
        errorMessage = 'Server requires minimum 3 images';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error - please try again';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot connect to server';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error - check your connection';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage: ${e.toString().split(':').first}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
