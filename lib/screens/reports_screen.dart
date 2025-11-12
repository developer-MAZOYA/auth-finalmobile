import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_drawer.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? _selectedDateRange;
  ReportType _selectedReportType = ReportType.daily;
  bool _isGenerating = false;
  bool _isUploading = false;

  final List<Map<String, dynamic>> _sampleReports = [
    {
      'id': '1',
      'title': 'Daily Site Report',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'Daily',
      'project': 'Road Construction - Phase 1',
      'status': 'Generated',
      'fileSize': '2.4 MB',
    },
    {
      'id': '2',
      'title': 'Weekly Progress Report',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'type': 'Weekly',
      'project': 'All Projects',
      'status': 'Generated',
      'fileSize': '5.1 MB',
    },
    {
      'id': '3',
      'title': 'Monthly Summary',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'type': 'Monthly',
      'project': 'All Projects',
      'status': 'Generated',
      'fileSize': '12.8 MB',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Filters Card
          _buildFiltersCard(),

          // Reports List
          Expanded(
            child: _buildReportsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Report Type Selection
            _buildReportTypeSelector(),
            const SizedBox(height: 16),

            // Date Range Selection
            _buildDateRangeSelector(),
            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Type',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReportType.values.map((type) {
            return FilterChip(
              label: Text(_getReportTypeLabel(type)),
              selected: _selectedReportType == type,
              onSelected: (selected) {
                setState(() {
                  _selectedReportType = type;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _selectedDateRange == null
                      ? 'Select Date Range'
                      : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                ),
                onPressed: _selectDateRange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.analytics, size: 16),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
            onPressed: _isGenerating ? null : _generateReport,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Upload Report'),
            onPressed: _uploadReport,
          ),
        ),
      ],
    );
  }

  Widget _buildReportsList() {
    final filteredReports = _getFilteredReports();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generated Reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${filteredReports.length} report${filteredReports.length != 1 ? 's' : ''} found',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredReports.isEmpty
                ? const EmptyReportsState()
                : ListView.builder(
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportCard(report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
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
                    report['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReportTypeColor(report['type']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report['type'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Project and Date
            Text(
              '${report['project']} • ${DateFormat('dd/MM/yyyy').format(report['date'])}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Details and Actions
            Row(
              children: [
                _buildReportDetail('Status', report['status']),
                const SizedBox(width: 16),
                _buildReportDetail('Size', report['fileSize']),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.download, size: 20),
                  onPressed: () => _downloadReport(report),
                  tooltip: 'Download',
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  onPressed: () => _shareReport(report),
                  tooltip: 'Share',
                ),
                IconButton(
                  icon: const Icon(Icons.upload, size: 20),
                  onPressed: () => _uploadSpecificReport(report),
                  tooltip: 'Upload',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      saveText: 'Select',
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isGenerating = false;
    });

    // Add new report to the list
    final newReport = {
      'id': '${DateTime.now().millisecondsSinceEpoch}',
      'title':
          '${_getReportTypeLabel(_selectedReportType)} Report - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
      'date': DateTime.now(),
      'type': _getReportTypeLabel(_selectedReportType),
      'project': 'All Projects',
      'status': 'Generated',
      'fileSize':
          '${(2 + DateTime.now().millisecond % 10).toStringAsFixed(1)} MB',
    };

    setState(() {
      _sampleReports.insert(0, newReport);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_getReportTypeLabel(_selectedReportType)} report generated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _uploadReport() async {
    if (_sampleReports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reports available to upload'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Show upload dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Upload Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Uploading reports to server...'),
            const SizedBox(height: 8),
            Text(
              '${_sampleReports.length} report${_sampleReports.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate upload process
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context); // Close progress dialog
    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_sampleReports.length} report${_sampleReports.length != 1 ? 's' : ''} uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _uploadSpecificReport(Map<String, dynamic> report) async {
    setState(() {
      _isUploading = true;
    });

    // Show upload dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Uploading report...'),
            const SizedBox(height: 8),
            Text(
              report['title'],
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate upload process
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context); // Close progress dialog
    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${report['title']} uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _downloadReport(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${report['title']}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _shareReport(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${report['title']}...'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredReports() {
    if (_selectedDateRange == null) {
      return _sampleReports;
    }

    return _sampleReports.where((report) {
      final reportDate = report['date'] as DateTime;
      return (reportDate.isAfter(_selectedDateRange!.start) ||
              reportDate.isAtSameMomentAs(_selectedDateRange!.start)) &&
          (reportDate.isBefore(_selectedDateRange!.end) ||
              reportDate.isAtSameMomentAs(_selectedDateRange!.end));
    }).toList();
  }

  String _getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.daily:
        return 'Daily';
      case ReportType.weekly:
        return 'Weekly';
      case ReportType.monthly:
        return 'Monthly';
      case ReportType.yearly:
        return 'Yearly';
    }
  }

  Color _getReportTypeColor(String type) {
    switch (type) {
      case 'Daily':
        return Colors.blue;
      case 'Weekly':
        return Colors.green;
      case 'Monthly':
        return Colors.orange;
      case 'Yearly':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class EmptyReportsState extends StatelessWidget {
  const EmptyReportsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Reports Generated',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate your first report by selecting a date range\nand report type above',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum ReportType {
  daily,
  weekly,
  monthly,
  yearly,
}
