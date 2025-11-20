import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../models/activity_observations_response.dart';
import '../services/api_service.dart';
import 'evidence_list_screen.dart';

class DailyTrackScreen extends StatefulWidget {
  const DailyTrackScreen({super.key});

  @override
  State<DailyTrackScreen> createState() => _DailyTrackScreenState();
}

class _DailyTrackScreenState extends State<DailyTrackScreen> {
  List<Activity> _activities = [];
  bool _isLoading = true;
  String _error = '';
  Activity? _selectedActivity;
  List<String> _selectedActivityObservations = [];
  bool _isLoadingObservations = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final activities = await ApiService.getActivities();

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load activities';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadObservationsForActivity(String activityId) async {
    try {
      setState(() {
        _isLoadingObservations = true;
      });

      final observationsResponse =
          await ApiService.getActivityObservations(activityId);

      setState(() {
        _selectedActivityObservations = observationsResponse.observations;
        _isLoadingObservations = false;
      });
    } catch (e) {
      setState(() {
        _selectedActivityObservations = [];
        _isLoadingObservations = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedActivity != null
            ? Text(_selectedActivity!.activityTitle)
            : const Text('Activities'),
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
    if (_isLoading) {
      return _buildLoadingIndicator('Loading activities...');
    }

    if (_error.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_activities.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          activity.activityTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectActivity(activity),
      ),
    );
  }

  Widget _buildObservationsScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Observations for ${_selectedActivity!.activityTitle}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoadingObservations
                ? _buildLoadingIndicator('Loading observations...')
                : _selectedActivityObservations.isEmpty
                    ? _buildNoObservationsState()
                    : ListView.builder(
                        itemCount: _selectedActivityObservations.length,
                        itemBuilder: (context, index) {
                          final observation =
                              _selectedActivityObservations[index];
                          return _buildObservationCard(observation, index);
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
      child: ListTile(
        title: Text(observation),
        subtitle: Text('Observation ${index + 1}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showEvidenceListScreen(observation),
      ),
    );
  }

  Widget _buildNoObservationsState() {
    return const Center(
      child: Text(
        'No observations available',
        style: TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadActivities,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No activities available',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  void _selectActivity(Activity activity) async {
    setState(() {
      _selectedActivity = activity;
    });
    await _loadObservationsForActivity(activity.activityTitle);
  }

  void _goBack() {
    setState(() {
      _selectedActivity = null;
      _selectedActivityObservations = [];
    });
  }

  void _showEvidenceListScreen(String observationText) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvidenceListScreen(
          activity: _selectedActivity!,
          observationText: observationText,
        ),
      ),
    );
  }
}
