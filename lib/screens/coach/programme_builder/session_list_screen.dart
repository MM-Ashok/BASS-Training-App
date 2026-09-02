import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/programme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/programme_model.dart';
import '../../../models/session_model.dart';
import '../../../utils/theme.dart';
import 'session_form_dialog.dart';
import '../../shared/attendance_screen.dart';
import '../../shared/feedback_journal_screen.dart';

class SessionListScreen extends StatelessWidget {
  final Programme programme;
  final Phase phase;
  const SessionListScreen({super.key, required this.programme, required this.phase});

  Color _statusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return AppTheme.primary;
      case SessionStatus.inProgress:
        return AppTheme.warning;
      case SessionStatus.completed:
        return AppTheme.success;
      case SessionStatus.cancelled:
        return AppTheme.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgrammeProvider>();
    final sessions = provider.sessionsForPhase(phase.id);
    final dateFmt = DateFormat('EEE MMM d · HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(phase.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => SessionFormDialog(programmeId: programme.id, phaseId: phase.id),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Session'),
      ),
      body: sessions.isEmpty
          ? Center(
              child: Text('No sessions scheduled in this phase yet',
                  style: TextStyle(color: Colors.grey[600])),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final session = sessions[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(session.status).withOpacity(0.12),
                      child: Icon(Icons.event, color: _statusColor(session.status), size: 20),
                    ),
                    title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${dateFmt.format(session.startTime)}\n${session.location.isEmpty ? "No location set" : session.location}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.fact_check_outlined),
                          tooltip: 'Attendance',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AttendanceScreen(
                                programme: programme,
                                sessionId: session.id,
                                sessionTitle: session.title,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note),
                          tooltip: 'Feedback journal',
                          onPressed: () {
                            // Feedback is per-trainee; for the scaffold we
                            // jump in with a placeholder trainee id — in
                            // the full build this opens a roster picker
                            // first when a session has multiple trainees.
                            final traineeId = programme.traineeIds.isNotEmpty
                                ? programme.traineeIds.first
                                : 'demo-trainee-1';
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FeedbackJournalScreen(
                                  programmeId: programme.id,
                                  sessionId: session.id,
                                  traineeId: traineeId,
                                  traineeName: traineeId,
                                ),
                              ),
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              showDialog(
                                context: context,
                                builder: (_) => SessionFormDialog(
                                  programmeId: programme.id,
                                  phaseId: phase.id,
                                  existing: session,
                                ),
                              );
                            } else if (value == 'delete') {
                              await context
                                  .read<ProgrammeProvider>()
                                  .deleteSession(programme.id, session.id);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
