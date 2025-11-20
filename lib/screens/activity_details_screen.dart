// screens/activity_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import 'observation_screen.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final int activityId;

  const ActivityDetailsScreen({super.key, required this.activityId});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  bool _isLoading = false;
  Activity? _activity;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadActivityDetails();
  }

  Future<void> _loadActivityDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final activityProvider =
          Provider.of<ActivityProvider>(context, listen: false);
      final activity = await activityProvider.fetchActivityDetails();

      if (mounted) {
        setState(() {
          _activity = activity;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _viewObservations() {
    // Navigate to actual observations page
    if (_activity != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ObservationScreen(
            activityId: widget.activityId,
            activityTitle: _activity!.activityTitle,
          ),
        ),
      );
    } else {
      // Show error if activity data is not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity data not loaded yet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_activity?.activityTitle ?? 'Activity Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadActivityDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activity == null
              ? _buildErrorWidget()
              : _buildActivityDetails(_activity!),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load activity details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Activity not found or not assigned to you',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadActivityDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetails(Activity activity) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          _buildHeaderSection(activity),
          const SizedBox(height: 24),

          // View Observations Button
          _buildViewObservationsButton(),
          const SizedBox(height: 24),

          // Basic Information - Full width card
          _buildBasicInfoCard(activity),
          const SizedBox(height: 16),

          // Location Information - Full width card
          _buildLocationInfoCard(activity),
          const SizedBox(height: 16),

          // Timeline - Full width card
          _buildTimelineCard(activity),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(Activity activity) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            _buildCardTitle('Basic Information'),
            const SizedBox(height: 16),

            // Title
            _buildInfoRow('Title', activity.activityTitle),
            const SizedBox(height: 16),

            // Description
            _buildInfoRow('Description',
                activity.description ?? 'No description available'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard(Activity activity) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            _buildCardTitle('Location Information'),
            const SizedBox(height: 16),

            // Region
            _buildInfoRow('Region', activity.region ?? 'Not assigned'),

            // Assigned Council
            if (activity.assignedCouncil != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow('Assigned Council', activity.assignedCouncil!.name),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(Activity activity) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            _buildCardTitle('Timeline'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                      'Start Date', _formatDate(activity.startDate)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child:
                      _buildInfoRow('End Date', _formatDate(activity.endDate)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? 'Not specified' : value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildViewObservationsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _viewObservations,
        icon: const Icon(Icons.visibility, size: 20),
        label: const Text(
          'View Observations',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Activity activity) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.activityTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (activity.assignedCouncil != null)
                    Text(
                      'Council: ${activity.assignedCouncil!.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (activity.region != null)
                    Text(
                      'Region: ${activity.region!}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not set';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }
}
