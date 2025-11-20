import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_model.dart';
import '../models/evidence_model.dart';
import '../providers/evidence_provider.dart';
import '../services/evidence_api_service.dart';
import 'evidence_capture_screen.dart';

class EvidenceListScreen extends StatefulWidget {
  final Activity activity;
  final String observationText;

  const EvidenceListScreen({
    super.key,
    required this.activity,
    required this.observationText,
  });

  @override
  State<EvidenceListScreen> createState() => _EvidenceListScreenState();
}

class _EvidenceListScreenState extends State<EvidenceListScreen> {
  List<Evidence> _evidenceList = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadEvidence();
  }

  Future<void> _loadEvidence() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Load evidence for this observation
      final evidence = await EvidenceApiService.getEvidenceByObservation(
          widget.observationText);

      setState(() {
        _evidenceList = evidence;
        _isLoading = false;
      });

      // Update provider
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evidence - ${widget.activity.activityTitle}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
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
              'Observation: ${widget.observationText}',
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
          ],
        ),
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
        // Date Header
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

        // Evidence Items for this date
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
          child: const Icon(Icons.photo, color: Colors.grey),
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
            Text('Location: ${evidence.address}'),
            Text(
                'Coordinates: ${evidence.latitude.toStringAsFixed(6)}, ${evidence.longitude.toStringAsFixed(6)}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Show evidence details
          _showEvidenceDetails(evidence);
        },
      ),
    );
  }

  void _navigateToEvidenceCapture() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvidenceCaptureScreen(
          activity: widget.activity,
          observationText: widget.observationText,
        ),
      ),
    ).then((_) {
      // Refresh evidence list when returning from capture screen
      _loadEvidence();
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
              Text('Address: ${evidence.address}'),
              Text('Latitude: ${evidence.latitude.toStringAsFixed(6)}'),
              Text('Longitude: ${evidence.longitude.toStringAsFixed(6)}'),
              Text('Accuracy: ${evidence.accuracy.toStringAsFixed(2)}m'),
              if (evidence.altitude != null)
                Text('Altitude: ${evidence.altitude!.toStringAsFixed(2)}m'),
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
