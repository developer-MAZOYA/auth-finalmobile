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
  final String observationText;

  const EvidenceCaptureScreen({
    super.key,
    required this.activity,
    required this.observationText,
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

  @override
  Widget build(BuildContext context) {
    final evidenceProvider = Provider.of<EvidenceProvider>(context);
    final existingEvidenceCount =
        evidenceProvider.getEvidenceCountForObservation(widget.observationText);

    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Evidence - ${widget.activity.activityTitle}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Observation Info Card
            _buildObservationInfoCard(existingEvidenceCount),
            const SizedBox(height: 20),

            // Location Section
            _buildLocationSection(),
            const SizedBox(height: 20),

            // Image Capture Section
            _buildImageCaptureSection(),
            const SizedBox(height: 20),

            // Captured Images Gallery
            if (_capturedImages.isNotEmpty) _buildImageGallery(),
            const SizedBox(height: 20),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationInfoCard(int existingEvidenceCount) {
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
              child: Text(
                'Observation: ${widget.observationText}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Images in this evidence: ${_capturedImages.length}/$_maxImages',
              style: TextStyle(
                fontSize: 14,
                color: _capturedImages.length >= _minImages
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
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

  Widget _buildImageCaptureSection() {
    final remainingImages = _maxImages - _capturedImages.length;
    final canTakeMoreImages = remainingImages > 0;
    final hasLocation =
        _currentLocation.isNotEmpty && _currentLocation['success'] == true;

    return Card(
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
                  'Evidence Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Capture $_minImages-$_maxImages photos for this evidence (${_capturedImages.length}/$_maxImages)',
              style: TextStyle(
                fontSize: 14,
                color: _capturedImages.length >= _minImages
                    ? Colors.green
                    : Colors.grey,
                fontWeight: _capturedImages.length >= _minImages
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),

            // Single Photo Button
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
                onPressed:
                    (hasLocation && canTakeMoreImages && !_isCapturingImage)
                        ? _takePhoto
                        : null,
              ),
            ),

            const SizedBox(height: 8),

            // Multiple Photos Button
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
                onPressed:
                    (hasLocation && canTakeMoreImages && !_isCapturingImage)
                        ? _takeMultiplePhotos
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
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Maximum of $_maxImages photos reached for this evidence.',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!hasLocation) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please capture location first before taking photos.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
                  'Evidence Photos',
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
              '${_capturedImages.length} photos ready for submission in one evidence record',
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

  Widget _buildSubmitButton() {
    final hasMinimumImages = _capturedImages.length >= _minImages;
    final hasLocation =
        _currentLocation.isNotEmpty && _currentLocation['success'] == true;
    final hasImages = _capturedImages.isNotEmpty;

    if (!hasImages) {
      return Container();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (hasLocation && hasMinimumImages && !_isSubmitting)
            ? _submitEvidence
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: hasMinimumImages ? Colors.green : Colors.orange,
        ),
        child: _isSubmitting
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
                  const Icon(Icons.cloud_upload, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Submit Evidence with ${_capturedImages.length} Images',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
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

  Future<void> _takePhoto() async {
    if (_currentLocation.isEmpty || _currentLocation['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture location first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
    if (_currentLocation.isEmpty || _currentLocation['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture location first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

    try {
      final evidenceProvider =
          Provider.of<EvidenceProvider>(context, listen: false);

      // Create ONE evidence record with MULTIPLE images
      final evidenceRequest = EvidenceRequest(
        activityId: widget.activity.activityTitle,
        observationId: widget.observationText,
        imagePaths: _capturedImages
            .map((file) => file.path)
            .toList(), // All images in one request
        latitude: _currentLocation['latitude'],
        longitude: _currentLocation['longitude'],
        address: _currentLocation['address'],
        accuracy: _currentLocation['accuracy']?.toDouble() ?? 0.0,
        altitude: _currentLocation['altitude']?.toDouble(),
        altitudeAccuracy: _currentLocation['speedAccuracy']?.toDouble(),
      );

      final evidence = await EvidenceApiService.createEvidence(evidenceRequest);

      // Add to provider
      evidenceProvider.addEvidence(evidence);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Successfully submitted evidence with ${_capturedImages.length} images'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to evidence list
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to submit evidence: $e'),
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

  @override
  void dispose() {
    super.dispose();
  }
}
