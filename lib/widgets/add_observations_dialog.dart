// widgets/add_observations_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/observation_provider.dart';

class AddObservationsDialog extends StatefulWidget {
  final int activityId;
  final VoidCallback onObservationsAdded;

  const AddObservationsDialog({
    super.key,
    required this.activityId,
    required this.onObservationsAdded,
  });

  @override
  State<AddObservationsDialog> createState() => _AddObservationsDialogState();
}

class _AddObservationsDialogState extends State<AddObservationsDialog> {
  final List<TextEditingController> _controllers = [];
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addNewField(); // Start with one empty field
  }

  void _addNewField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  Future<void> _saveObservations() async {
    if (!_formKey.currentState!.validate()) return;

    final observationNames = _controllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (observationNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one observation')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await Provider.of<ObservationProvider>(context, listen: false)
          .addObservations(widget.activityId, observationNames);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onObservationsAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ ${observationNames.length} observation(s) added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add observations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Observations'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter observation details (you can add multiple):',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ..._controllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Observation ${index + 1}',
                            border: const OutlineInputBorder(),
                            suffixIcon: _controllers.length > 1
                                ? IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.red),
                                    onPressed: () => _removeField(index),
                                  )
                                : null,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter observation';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addNewField,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Another Field'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _saveObservations,
          child: _isSubmitting
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Adding...'),
                  ],
                )
              : const Text('Save Observations'),
        ),
      ],
    );
  }
}
