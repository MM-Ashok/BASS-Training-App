import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/programme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/session_model.dart';

class SessionFormDialog extends StatefulWidget {
  final String programmeId;
  final String phaseId;
  final TrainingSession? existing;

  const SessionFormDialog({
    super.key,
    required this.programmeId,
    required this.phaseId,
    this.existing,
  });

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  DateTime _startTime = DateTime.now().add(const Duration(days: 1, hours: 9));
  DateTime _endTime = DateTime.now().add(const Duration(days: 1, hours: 12));
  SessionStatus _status = SessionStatus.scheduled;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _titleController = TextEditingController(text: s?.title ?? '');
    _locationController = TextEditingController(text: s?.location ?? '');
    if (s != null) {
      _startTime = s.startTime;
      _endTime = s.endTime;
      _status = s.status;
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final base = isStart ? _startTime : _endTime;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base));
    if (time == null) return;
    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => isStart ? _startTime = combined : _endTime = combined);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endTime.isBefore(_startTime)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('End time must be after start time')));
      return;
    }
    final provider = context.read<ProgrammeProvider>();
    final coachId = context.read<AuthProvider>().currentUser?.id ?? 'demo-coach';

    if (_isEditing) {
      await provider.updateSession(widget.existing!.copyWith(
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        status: _status,
      ));
    } else {
      await provider.createSession(
        programmeId: widget.programmeId,
        phaseId: widget.phaseId,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        leadCoachId: coachId,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, HH:mm');
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Session' : 'Add Session'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Session Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _pickDateTime(isStart: true),
                child: Text('Start: ${fmt.format(_startTime)}'),
              ),
              TextButton(
                onPressed: () => _pickDateTime(isStart: false),
                child: Text('End: ${fmt.format(_endTime)}'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SessionStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: SessionStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? _status),
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
