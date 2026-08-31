import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';
import '../providers/session_provider.dart';

class EditSessionScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  const EditSessionScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
  });

  @override
  ConsumerState<EditSessionScreen> createState() =>
      _EditSessionScreenState();
}

class _EditSessionScreenState
    extends ConsumerState<EditSessionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _coachController;

  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  late String _status;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.session.title);

    _descriptionController =
        TextEditingController(text: widget.session.description);

    _coachController =
        TextEditingController(text: widget.session.coachName);

    _date = widget.session.date;

    _startTime = TimeOfDay(
      hour: widget.session.startTime.hour,
      minute: widget.session.startTime.minute,
    );

    _endTime = TimeOfDay(
      hour: widget.session.endTime.hour,
      minute: widget.session.endTime.minute,
    );

    _status = widget.session.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coachController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _updateSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final updated = SessionModel(
      id: widget.session.id,
      programmeId: widget.programme.id,
      phaseId: widget.phase.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _date,
      startTime: _combine(_date, _startTime),
      endTime: _combine(_date, _endTime),
      coachId: widget.session.coachId,
      coachName: _coachController.text.trim(),
      status: _status,
    );

    try {
      await ref
          .read(sessionServiceProvider)
          .updateSession(updated);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session updated successfully."),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _buildDateTile() {
    return ListTile(
      title: Text(
        "Date : ${_date.day}/${_date.month}/${_date.year}",
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: _pickDate,
    );
  }

  Widget _buildStartTile() {
    return ListTile(
      title: Text(
        "Start Time : ${_startTime.format(context)}",
      ),
      trailing: const Icon(Icons.access_time),
      onTap: _pickStartTime,
    );
  }

  Widget _buildEndTile() {
    return ListTile(
      title: Text(
        "End Time : ${_endTime.format(context)}",
      ),
      trailing: const Icon(Icons.access_time),
      onTap: _pickEndTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Session"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Session Title",
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Required"
                        : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _coachController,
                decoration: const InputDecoration(
                  labelText: "Coach Name",
                ),
              ),

              const SizedBox(height: 20),

              _buildDateTile(),

              _buildStartTile(),

              _buildEndTile(),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: "Status",
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Draft",
                    child: Text("Draft"),
                  ),
                  DropdownMenuItem(
                    value: "Scheduled",
                    child: Text("Scheduled"),
                  ),
                  DropdownMenuItem(
                    value: "Completed",
                    child: Text("Completed"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _loading ? null : _updateSession,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text("Update Session"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}