import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';

import '../providers/attendance_provider.dart';
import 'attendance_detail_screen.dart';
import 'mark_attendance_screen.dart';

class AttendanceScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  final bool canEdit;
  final bool canDelete;

  const AttendanceScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    this.canEdit = false,
    this.canDelete = false,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return Colors.green;

      case "late":
        return Colors.orange;

      case "excused":
        return Colors.blue;

      case "absent":
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(
      attendanceProvider(
        AttendanceParams(
          programmeId: programme.id,
          phaseId: phase.id,
          sessionId: session.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text("${session.title} Attendance")),

      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Mark Attendance"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MarkAttendanceScreen(
                      programme: programme,
                      phase: phase,
                      session: session,
                    ),
                  ),
                );
              },
            )
          : null,

      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) {
  debugPrint("===== ATTENDANCE ERROR =====");
  debugPrint(e.toString());
  debugPrintStack(stackTrace: s);

  return Center(
    child: Text(e.toString()),
  );
},

        data: (attendance) {
          if (attendance.isEmpty) {
            return const Center(
              child: Text(
                "No attendance records found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                attendanceProvider(
                  AttendanceParams(
                    programmeId: programme.id,
                    phaseId: phase.id,
                    sessionId: session.id,
                  ),
                ),
              );
            },
            child: ListView.builder(
              itemCount: attendance.length,
              itemBuilder: (_, index) {
                final record = attendance[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(record.status),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),

                    title: Text(record.traineeName),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.status),

                        Text(
                          "${record.markedAt.day}/${record.markedAt.month}/${record.markedAt.year}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    trailing: const Icon(Icons.chevron_right),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceDetailScreen(
                            programme: programme,
                            phase: phase,
                            session: session,
                            attendance: record,
                            canEdit: canEdit,
                            canDelete: canDelete,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
