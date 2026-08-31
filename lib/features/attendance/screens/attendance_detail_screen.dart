import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/attendance_model.dart';
import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';

import '../providers/attendance_provider.dart';
import 'edit_attendance_screen.dart';

class AttendanceDetailScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;
  final AttendanceModel attendance;

  final bool canEdit;
  final bool canDelete;

  const AttendanceDetailScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    required this.attendance,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(
      attendanceRecordProvider(
        AttendanceRecordParams(
          programmeId: programme.id,
          phaseId: phase.id,
          sessionId: session.id,
          attendanceId: attendance.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Details"),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                attendanceAsync.whenData((record) {
                  if (record == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditAttendanceScreen(
                        programme: programme,
                        phase: phase,
                        session: session,
                        attendance: record,
                      ),
                    ),
                  );
                });
              },
            ),

          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Attendance"),
                    content: const Text(
                      "Are you sure you want to delete this attendance record?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                await ref
                    .read(attendanceServiceProvider)
                    .deleteAttendance(
                      programme.id,
                      phase.id,
                      session.id,
                      attendance.id,
                    );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Attendance deleted.")),
                );

                Navigator.pop(context);
              },
            ),
        ],
      ),

      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (record) {
          if (record == null) {
            return const Center(child: Text("Attendance record not found."));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _infoTile("Programme", programme.name),

              _infoTile("Phase", phase.title),

              _infoTile("Session", session.title),

              _infoTile("Trainee", record.traineeName),

              _infoTile("Status", record.status),

              _infoTile("Notes", record.notes.isEmpty ? "-" : record.notes),

              _infoTile("Marked At", _formatDate(record.markedAt)),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
