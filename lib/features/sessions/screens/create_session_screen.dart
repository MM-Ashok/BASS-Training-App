import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';
import '../providers/session_provider.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;

  const CreateSessionScreen({
    super.key,
    required this.programme,
    required this.phase,
  });

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState
    extends ConsumerState<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coachController = TextEditingController();

  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  String _status = "Draft";

  bool _loading = false;

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

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final session = SessionModel(
      id: const Uuid().v4(),
      programmeId: widget.programme.id,
      phaseId: widget.phase.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _date,
      startTime: _combine(_date, _startTime),
      endTime: _combine(_date, _endTime),
      coachId: "",
      coachName: _coachController.text.trim(),
      status: _status,
    );

    try {
      await ref
          .read(sessionServiceProvider)
          .createSession(session);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session created successfully."),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Session"),
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
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
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

              ListTile(
                title: Text(
                  "Date : ${_date.day}/${_date.month}/${_date.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              ListTile(
                title: Text(
                  "Start Time : ${_startTime.format(context)}",
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickStartTime,
              ),

              ListTile(
                title: Text(
                  "End Time : ${_endTime.format(context)}",
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickEndTime,
              ),

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
                  setState(() => _status = value!);
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _saveSession,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text("Create Session"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}