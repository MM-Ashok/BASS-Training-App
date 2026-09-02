import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/programme_provider.dart';
import '../../../models/programme_model.dart';

class PhaseFormDialog extends StatefulWidget {
  final String programmeId;
  final Phase? existing;
  const PhaseFormDialog({super.key, required this.programmeId, this.existing});

  @override
  State<PhaseFormDialog> createState() => _PhaseFormDialogState();
}

class _PhaseFormDialogState extends State<PhaseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    if (p != null) {
      _startDate = p.startDate;
      _endDate = p.endDate;
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => isStart ? _startDate = picked : _endDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProgrammeProvider>();
    if (_isEditing) {
      await provider.updatePhase(widget.existing!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
      ));
    } else {
      await provider.createPhase(
        programmeId: widget.programmeId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Phase' : 'Add Phase'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Phase Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _pickDate(isStart: true),
                      child: Text('Start: ${dateFmt.format(_startDate)}'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _pickDate(isStart: false),
                      child: Text('End: ${dateFmt.format(_endDate)}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
