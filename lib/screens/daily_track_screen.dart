import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../providers/observation_provider.dart';
import 'evidence_list_screen.dart';

class DailyTrackScreen extends StatefulWidget {
  const DailyTrackScreen({super.key});

  @override
  State<DailyTrackScreen> createState() => _DailyTrackScreenState();
}

class _DailyTrackScreenState extends State<DailyTrackScreen> {
  Activity? _selectedActivity;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserActivities();
  }

  Future<void> _loadUserActivities() async {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    await activityProvider.fetchUserAssignedActivities();

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadObservationsForActivity(Activity activity) async {
    final observationProvider =
        Provider.of<ObservationProvider>(context, listen: false);
    await observationProvider.fetchObservations(activity.activityId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedActivity != null
            ? Text(_selectedActivity!.activityTitle)
            : const Text('My Assigned Activities'),
        leading: _selectedActivity != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              )
            : null,
      ),
      body: _selectedActivity != null
          ? _buildObservationsScreen()
          : _buildActivitiesScreen(),
    );
  }

  Widget _buildActivitiesScreen() {
    if (_isInitialLoading) {
      return _buildLoadingIndicator('Loading your assigned activities...');
    }

    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        if (activityProvider.assignedActivities.isEmpty) {
          return _buildEmptyState('No activities assigned to you');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activityProvider.assignedActivities.length,
          itemBuilder: (context, index) {
            final activity = activityProvider.assignedActivities[index];
            return _buildActivityCard(activity);
          },
        );
      },
    );
  }

  Widget _buildActivityCard(Activity activity) {
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
          activity.activityTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle:
            activity.description != null && activity.description!.isNotEmpty
                ? Text(
                    activity.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectActivity(activity),
      ),
    );
  }

  Widget _buildObservationsScreen() {
    return Consumer<ObservationProvider>(
      builder: (context, observationProvider, child) {
        final observations = observationProvider.observations;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Activity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedActivity!.activityTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedActivity!.description != null &&
                          _selectedActivity!.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _selectedActivity!.description!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                      if (_selectedActivity!.region != null &&
                          _selectedActivity!.region!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Region: ${_selectedActivity!.region!}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Observations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (observations != null)
                    Chip(
                      label: Text('${observations.observations.length}'),
                      backgroundColor: observations.observations.isNotEmpty
                          ? Colors.blue[100]
                          : Colors.orange[100],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (observationProvider.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    observationProvider.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: observationProvider.isLoading
                    ? _buildLoadingIndicator('Loading observations...')
                    : observations == null || observations.observations.isEmpty
                        ? _buildNoObservationsState()
                        : ListView.builder(
                            itemCount: observations.observations.length,
                            itemBuilder: (context, index) {
                              final observation =
                                  observations.observations[index];
                              return _buildObservationCard(observation, index);
                            },
                          ),
              ),
            ],
          ),
        );
      },
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
        onTap: () => _showEvidenceListScreen(observation, index + 1),
      ),
    );
  }

  Widget _buildNoObservationsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility_off, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'No Observations Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This activity has no observations yet.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Activities'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadUserActivities,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _selectActivity(Activity activity) async {
    setState(() {
      _selectedActivity = activity;
    });

    await _loadObservationsForActivity(activity);
  }

  void _goBack() {
    final observationProvider =
        Provider.of<ObservationProvider>(context, listen: false);
    observationProvider.clearData();

    setState(() {
      _selectedActivity = null;
    });
  }

  void _showEvidenceListScreen(String observationText, int observationIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvidenceListScreen(
          activity: _selectedActivity!,
          observationName: observationText,
          observationId:
              observationIndex, // ← HARDCODE HERE: Replace with your observation ID
          userId: 2, // ← HARDCODE HERE: Replace with your user ID
        ),
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
    ];
    return icons[index % icons.length];
  }
}
