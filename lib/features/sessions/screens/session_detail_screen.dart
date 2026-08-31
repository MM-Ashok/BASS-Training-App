import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';

import '../providers/session_provider.dart';
import 'edit_session_screen.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../attendance/screens/attendance_screen.dart';
import '../../feedback/screens/feedback_screen.dart';
import '../../experience/screens/trainee_selection_screen.dart';

class SessionDetailScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  final bool canEdit;
  final bool canDelete;

  const SessionDetailScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(
      sessionProvider(
        SessionDetailParams(
          programmeId: programme.id,
          phaseId: phase.id,
          sessionId: session.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(session.title),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updatedSession = sessionAsync.value;

                if (updatedSession == null) return;

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditSessionScreen(
                      programme: programme,
                      phase: phase,
                      session: updatedSession,
                    ),
                  ),
                );
              },
            ),

          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Session"),
                    content: const Text(
                      "Are you sure you want to delete this session?",
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

                try {
                  await ref
                      .read(sessionServiceProvider)
                      .deleteSession(programme.id, phase.id, session.id);

                  if (!context.mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Session deleted successfully."),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
            ),
        ],
      ),

      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (updatedSession) {
          if (updatedSession == null) {
            return const Center(child: Text("Session not found"));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _infoTile("Programme", programme.name),

              _infoTile("Phase", phase.title),

              _infoTile("Session", updatedSession.title),

              _infoTile("Description", updatedSession.description),

              _infoTile("Coach", updatedSession.coachName),

              _infoTile("Status", updatedSession.status),

              _infoTile("Date", _formatDate(updatedSession.date)),

              _infoTile("Start Time", _formatTime(updatedSession.startTime)),

              _infoTile("End Time", _formatTime(updatedSession.endTime)),
              const SizedBox(height: 30),

              FilledButton.icon(
                icon: const Icon(Icons.assignment),
                label: const Text("Manage Tasks"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TasksScreen(
                        programme: programme,
                        phase: phase,
                        session: updatedSession,
                        canEdit: canEdit,
                        canDelete: canDelete,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
              FilledButton.icon(
                icon: const Icon(Icons.people),
                label: const Text("Manage Attendance"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceScreen(
                        programme: programme,
                        phase: phase,
                        session: updatedSession,
                        canEdit: canEdit,
                        canDelete: canDelete,
                      ),
                    ),
                  );
                },
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.feedback, color: Colors.deepPurple),

                  title: const Text("Feedback Journal"),

                  subtitle: const Text(
                    "Session feedback and skills assessment",
                  ),

                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FeedbackScreen(
                          programme: programme,
                          phase: phase,
                          session: session,

                          canEdit: canEdit,
                          canDelete: canDelete,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.downhill_skiing,
                    color: Colors.indigo,
                  ),
                  title: const Text("70-Hour Experience"),
                  subtitle: const Text("Track trainee ski school experience"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TraineeSelectionScreen(
                          programme: programme,
                          phase: phase,
                          session: updatedSession,
                        ),
                      ),
                    );
                  },
                ),
              ),
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

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
