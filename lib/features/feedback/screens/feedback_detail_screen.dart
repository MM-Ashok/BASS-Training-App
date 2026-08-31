import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/feedback_model.dart';
import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';

import '../providers/feedback_provider.dart';
import 'edit_feedback_screen.dart';

class FeedbackDetailScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;
  final FeedbackModel feedback;

  final bool canEdit;
  final bool canDelete;

  const FeedbackDetailScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    required this.feedback,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(
      feedbackRecordProvider(
        FeedbackRecordParams(
          programmeId: programme.id,
          phaseId: phase.id,
          sessionId: session.id,
          feedbackId: feedback.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback Details"),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditFeedbackScreen(
                      programme: programme,
                      phase: phase,
                      session: session,
                      feedback: feedback,
                    ),
                  ),
                );
              },
            ),

          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Feedback"),
                    content: const Text(
                      "Are you sure you want to delete this feedback?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                await ref
                    .read(feedbackServiceProvider)
                    .deleteFeedback(
                      programme.id,
                      phase.id,
                      session.id,
                      feedback.id,
                    );

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Feedback deleted."),
                    ),
                  );
                }
              },
            ),
        ],
      ),

      body: feedbackAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (record) {
          if (record == null) {
            return const Center(
              child: Text("Feedback not found."),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(record.traineeName),
                  subtitle: const Text("Trainee"),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.sports),
                  title: Text(record.coachName),
                  subtitle: const Text("Coach"),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                record.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < record.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),

              const SizedBox(height: 20),

              const Text(
                "Feedback",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    record.feedback,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Skills",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: record.skills
                    .map(
                      (skill) => Chip(
                        label: Text(skill),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    "${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}",
                  ),
                  subtitle: const Text("Created At"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}