import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/attendance_model.dart';
import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';

import '../providers/attendance_provider.dart';

class EditAttendanceScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;
  final AttendanceModel attendance;

  const EditAttendanceScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    required this.attendance,
  });

  @override
  ConsumerState<EditAttendanceScreen> createState() =>
      _EditAttendanceScreenState();
}

class _EditAttendanceScreenState
    extends ConsumerState<EditAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _traineeController;
  late TextEditingController _notesController;

  late String _status;

  bool _loading = false;

  final List<String> _statuses = const [
    "Present",
    "Absent",
    "Late",
    "Excused",
  ];

  @override
  void initState() {
    super.initState();

    _traineeController =
        TextEditingController(text: widget.attendance.traineeName);

    _notesController =
        TextEditingController(text: widget.attendance.notes);

    _status = widget.attendance.status;
  }

  @override
  void dispose() {
    _traineeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateAttendance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final updatedAttendance = widget.attendance.copyWith(
        traineeName: _traineeController.text.trim(),
        status: _status,
        notes: _notesController.text.trim(),
        markedAt: DateTime.now(),
      );

      await ref
          .read(attendanceServiceProvider)
          .updateAttendance(updatedAttendance);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance updated successfully."),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Attendance"),
      ),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter trainee name";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
              items: _statuses
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: _loading ? null : _updateAttendance,
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
              label: Text(
                _loading ? "Updating..." : "Update Attendance",
              ),
            ),
          ],
        ),
      ),
    );
  }
}