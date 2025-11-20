import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_model.dart';
import '../models/evidence_model.dart';
import '../providers/evidence_provider.dart';
import '../services/evidence_api_service.dart';
import 'evidence_capture_screen.dart';

class EvidenceListScreen extends StatefulWidget {
  final Activity activity;
  final int observationId;
  final String observationName;
  final int userId;

  const EvidenceListScreen({
    super.key,
    required this.activity,
    required this.observationId,
    required this.observationName,
    required this.userId,
  });

  @override
  State<EvidenceListScreen> createState() => _EvidenceListScreenState();
}

class _EvidenceListScreenState extends State<EvidenceListScreen> {
  List<Evidence> _evidenceList = [];
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _complianceData;

  @override
  void initState() {
    super.initState();
    _loadEvidence();
    _loadCompliance();
  }

  Future<void> _loadEvidence() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final evidence = await EvidenceApiService.getEvidencesForObservation(
        widget.userId,
        widget.activity.activityId,
        widget.observationId,
      );

      setState(() {
        _evidenceList = evidence;
        _isLoading = false;
      });

      final evidenceProvider =
          Provider.of<EvidenceProvider>(context, listen: false);
      evidenceProvider.setEvidence(evidence);
    } catch (e) {
      setState(() {
        _error = 'Failed to load evidence: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCompliance() async {
    try {
      final compliance = await EvidenceApiService.validateCompliance(
        widget.userId,
        widget.activity.activityId,
        widget.observationId,
      );
      setState(() {
        _complianceData = compliance['compliance'];
      });
    } catch (e) {
      print('Failed to load compliance: $e');
    }
  }

  Future<void> _deleteEvidence(String evidenceId) async {
    try {
      await EvidenceApiService.deleteEvidence(
        widget.userId,
        widget.activity.activityId,
        widget.observationId,
        int.parse(evidenceId),
      );

      // Remove from local list
      setState(() {
        _evidenceList
            .removeWhere((evidence) => evidence.evidenceId == evidenceId);
      });

      // Update provider
      final evidenceProvider =
          Provider.of<EvidenceProvider>(context, listen: false);
      evidenceProvider.removeEvidence(evidenceId);

      // Reload compliance
      _loadCompliance();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidence deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete evidence: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(String evidenceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Evidence'),
        content: const Text('Are you sure you want to delete this evidence?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvidence(evidenceId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evidence - ${widget.activity.activityTitle}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvidence,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEvidenceCapture,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Header Card
          _buildHeaderCard(),

          // Evidence List
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _error.isNotEmpty
                    ? _buildErrorWidget()
                    : _evidenceList.isEmpty
                        ? _buildEmptyState()
                        : _buildEvidenceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.activity.activityTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Observation: ${widget.observationName}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Evidence Count: ${_evidenceList.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (_complianceData != null) _buildComplianceStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceStatus() {
    final isCompliant = _complianceData!['isCompliant'] ?? false;
    final message = _complianceData!['message'] ?? '';
    final totalImages = _complianceData!['totalImages'] ?? 0;
    final hasMinimumImages = _complianceData!['hasMinimumImages'] ?? false;
    final hasMaximumImages = _complianceData!['hasMaximumImages'] ?? false;
    final hasValidLocations = _complianceData!['hasValidLocations'] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompliant ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompliant ? Colors.green : Colors.orange,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompliant ? Icons.check_circle : Icons.warning,
                color: isCompliant ? Colors.green : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isCompliant ? 'Compliant' : 'Not Compliant',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompliant ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: isCompliant ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Images: $totalImages/5 | Min: ${hasMinimumImages ? '✓' : '✗'} | Max: ${hasMaximumImages ? '✓' : '✗'} | Location: ${hasValidLocations ? '✓' : '✗'}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading evidence...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadEvidence,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Evidence Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first evidence',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToEvidenceCapture,
            icon: const Icon(Icons.add),
            label: const Text('Add First Evidence'),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceList() {
    // Group evidence by date
    final Map<String, List<Evidence>> evidenceByDate = {};

    for (final evidence in _evidenceList) {
      final date = _formatDate(evidence.timestamp);
      if (!evidenceByDate.containsKey(date)) {
        evidenceByDate[date] = [];
      }
      evidenceByDate[date]!.add(evidence);
    }

    // Sort dates in descending order
    final sortedDates = evidenceByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadEvidence,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dailyEvidence = evidenceByDate[date]!;
          return _buildDateSection(date, dailyEvidence);
        },
      ),
    );
  }

  Widget _buildDateSection(String date, List<Evidence> dailyEvidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...dailyEvidence.map((evidence) => _buildEvidenceItem(evidence)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEvidenceItem(Evidence evidence) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: evidence.hasImages
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    evidence.imagePaths.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.photo, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.photo, color: Colors.grey),
        ),
        title: Text(
          _formatTime(evidence.timestamp),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Images: ${evidence.imageCount}'),
            Text('Location: ${evidence.address}'),
            Text('Accuracy: ${evidence.accuracy.toStringAsFixed(2)}m'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(evidence.evidenceId);
            } else if (value == 'view') {
              _showEvidenceDetails(evidence);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showEvidenceDetails(evidence),
      ),
    );
  }

  void _navigateToEvidenceCapture() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvidenceCaptureScreen(
          activity: widget.activity,
          observationId: widget.observationId,
          observationName: widget.observationName,
          userId: widget.userId,
        ),
      ),
    ).then((_) {
      _loadEvidence();
      _loadCompliance();
    });
  }

  void _showEvidenceDetails(Evidence evidence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Evidence Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${_formatDateTime(evidence.timestamp)}'),
              const SizedBox(height: 8),
              Text('Images: ${evidence.imageCount}'),
              const SizedBox(height: 8),
              Text('Address: ${evidence.address}'),
              const SizedBox(height: 8),
              Text('Latitude: ${evidence.latitude.toStringAsFixed(6)}'),
              const SizedBox(height: 8),
              Text('Longitude: ${evidence.longitude.toStringAsFixed(6)}'),
              const SizedBox(height: 8),
              Text('Accuracy: ${evidence.accuracy.toStringAsFixed(2)}m'),
              if (evidence.altitude != null) ...[
                const SizedBox(height: 8),
                Text('Altitude: ${evidence.altitude!.toStringAsFixed(2)}m'),
              ],
              if (evidence.observationText != null) ...[
                const SizedBox(height: 8),
                Text('Observation: ${evidence.observationText}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }
}
