import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/draft_provider.dart';
import 'app_drawer.dart';

class DraftReportsScreen extends StatelessWidget {
  const DraftReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draft Reports'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        actions: [
          Consumer<DraftProvider>(
            builder: (context, draftProvider, child) {
              if (draftProvider.draftCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () => _syncAllDrafts(context),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const DraftReportsList(),
    );
  }

  void _syncAllDrafts(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync All Drafts'),
        content: Text(
            'Sync ${draftProvider.draftCount} draft report${draftProvider.draftCount != 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performSync(context, draftProvider, syncAll: true);
            },
            child: const Text('Sync All'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSync(BuildContext context, DraftProvider draftProvider,
      {bool syncAll = false, String? draftId}) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(syncAll ? 'Syncing all drafts...' : 'Syncing draft...'),
          ],
        ),
      ),
    );

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context); // Close progress dialog

    if (syncAll) {
      await draftProvider.syncAllDrafts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All drafts synced successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (draftId != null) {
      await draftProvider.syncDraft(draftId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft synced successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class DraftReportsList extends StatelessWidget {
  const DraftReportsList({super.key});

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final drafts = draftProvider.drafts;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Draft Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${draftProvider.draftCount}'),
                backgroundColor: Colors.orange[100],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reports waiting to be uploaded to server',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Drafts List
          Expanded(
            child: drafts.isEmpty
                ? const EmptyDraftsState()
                : ListView.builder(
                    itemCount: drafts.length,
                    itemBuilder: (context, index) {
                      final draft = drafts[index];
                      return DraftReportCard(draft: draft);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DraftReportCard extends StatelessWidget {
  final DraftReport draft;

  const DraftReportCard({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    draft.projectName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'DRAFT',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              draft.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                _buildDetailItem(
                  Icons.calendar_today,
                  _formatDate(draft.createdDate),
                ),
                const SizedBox(width: 16),
                _buildDetailItem(
                  Icons.access_time,
                  _formatTime(draft.createdDate),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.remove_red_eye, size: 16),
                    label: const Text('View Details'),
                    onPressed: () {
                      _showDraftDetails(context, draft);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('Sync Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await _syncSingleDraft(context, draftProvider, draft.id);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDraftDetails(BuildContext context, DraftReport draft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(draft.projectName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Report Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Project:', draft.projectName),
              _buildDetailRow('Description:', draft.description),
              _buildDetailRow('Created:',
                  '${_formatDate(draft.createdDate)} at ${_formatTime(draft.createdDate)}'),
              _buildDetailRow('Status:', 'Draft - Not Synced'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'This report contains unsynced data including location, photos, and observations. Sync to upload to server.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final draftProvider =
                  Provider.of<DraftProvider>(context, listen: false);
              await _syncSingleDraft(context, draftProvider, draft.id);
            },
            child: const Text('Sync This Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncSingleDraft(
      BuildContext context, DraftProvider draftProvider, String draftId) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Syncing draft report...'),
          ],
        ),
      ),
    );

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context); // Close progress dialog

    await draftProvider.syncDraft(draftId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft report synced successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class EmptyDraftsState extends StatelessWidget {
  const EmptyDraftsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.drafts,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Draft Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All your reports are synced with the server',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.track_changes),
            label: const Text('Create Daily Report'),
            onPressed: () {
              Navigator.pushNamed(context, '/daily-track');
            },
          ),
        ],
      ),
    );
  }
}
