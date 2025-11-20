// screens/observation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_observations_response.dart';
import '../providers/observation_provider.dart';
import '../widgets/add_observations_dialog.dart';

class ObservationScreen extends StatefulWidget {
  final int activityId;
  final String activityTitle;

  const ObservationScreen({
    super.key,
    required this.activityId,
    required this.activityTitle,
  });

  @override
  State<ObservationScreen> createState() => _ObservationScreenState();
}

class _ObservationScreenState extends State<ObservationScreen> {
  @override
  void initState() {
    super.initState();
    print('🟢 OBSERVATION SCREEN INIT for activity: ${widget.activityId}');
    _loadObservations();
  }

  void _loadObservations() {
    print('🔄 LOADING OBSERVATIONS...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObservationProvider>(context, listen: false)
          .fetchObservations(widget.activityId);
    });
  }

  void _showAddObservationsDialog() {
    print('➕ SHOWING ADD OBSERVATIONS DIALOG');
    showDialog(
      context: context,
      builder: (context) => AddObservationsDialog(
        activityId: widget.activityId,
        onObservationsAdded: _loadObservations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Observations - ${widget.activityTitle}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadObservations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<ObservationProvider>(
        builder: (context, observationProvider, child) {
          print(
              '🔄 BUILDING OBSERVATION SCREEN - Loading: ${observationProvider.isLoading}');

          // Loading State
          if (observationProvider.isLoading &&
              observationProvider.observations == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading observations...'),
                ],
              ),
            );
          }

          // Error State
          if (observationProvider.errorMessage.isNotEmpty) {
            return _buildErrorWidget(observationProvider);
          }

          final observations = observationProvider.observations;

          // Empty State (no data loaded yet)
          if (observations == null) {
            return _buildEmptyState();
          }

          // Success State
          return _buildObservationsList(observations);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddObservationsDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget(ObservationProvider provider) {
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
              'Failed to Load Observations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadObservations,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Observations Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the + button below to add observations for "${widget.activityTitle}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsList(ActivityObservationsResponse observations) {
    return Column(
      children: [
        // Header Card
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  observations.activityTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${observations.observations.length} observation(s)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Observations List
        Expanded(
          child: observations.observations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: observations.observations.length,
                  itemBuilder: (context, index) {
                    return _buildObservationItem(
                      observations.observations[index],
                      index + 1,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildObservationItem(String observation, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: Text(
            number.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          observation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
