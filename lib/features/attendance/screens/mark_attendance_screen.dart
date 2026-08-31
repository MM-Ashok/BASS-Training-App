import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/attendance_model.dart';

import '../providers/attendance_provider.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  const MarkAttendanceScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
  });

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _traineeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _date = DateTime.now();

  String _status = "Present";

  bool _loading = false;

  final List<String> statuses = const ["Present", "Absent", "Late", "Excused"];

  @override
  void dispose() {
    _traineeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveAttendance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final attendance = AttendanceModel(
        id: const Uuid().v4(),
        programmeId: widget.programme.id,
        phaseId: widget.phase.id,
        sessionId: widget.session.id,
        traineeId: "", // Will come from selected trainee later
        traineeName: _traineeController.text.trim(),
        status: _status,
        notes: _notesController.text.trim(),
        markedBy: "Admin", // replace with current user later
        markedAt: DateTime.now(),
        checkInTime: DateTime.now(),
      );

      await ref.read(attendanceServiceProvider).createAttendance(attendance);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance marked successfully.")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _traineeController,
              decoration: const InputDecoration(
                labelText: "Trainee Name",
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? "Enter trainee name"
                  : null,
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: "Attendance Status",
                border: OutlineInputBorder(),
              ),
              items: statuses
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text("${_date.day}/${_date.month}/${_date.year}"),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text("Change"),
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Remarks (Optional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: _loading ? null : _saveAttendance,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_loading ? "Saving..." : "Save Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
