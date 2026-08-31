import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';

import '../providers/feedback_provider.dart';
import 'create_feedback_screen.dart';
import 'feedback_detail_screen.dart';

class FeedbackScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  final bool canEdit;
  final bool canDelete;

  const FeedbackScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    this.canEdit = false,
    this.canDelete = false,
  });

  Color _ratingColor(int rating) {
    if (rating >= 4) {
      return Colors.green;
    } else if (rating == 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(
      feedbackProvider(
        FeedbackParams(
          programmeId: programme.id,
          phaseId: phase.id,
          sessionId: session.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("${session.title} Feedback"),
      ),

      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_comment),
              label: const Text("Add Feedback"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateFeedbackScreen(
                      programme: programme,
                      phase: phase,
                      session: session,
                    ),
                  ),
                );
              },
            )
          : null,

      body: feedbackAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (feedbackList) {
          if (feedbackList.isEmpty) {
            return const Center(
              child: Text(
                "No feedback available.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                feedbackProvider(
                  FeedbackParams(
                    programmeId: programme.id,
                    phaseId: phase.id,
                    sessionId: session.id,
                  ),
                ),
              );
            },
            child: ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (_, index) {
                final feedback = feedbackList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _ratingColor(feedback.rating),
                      child: Text(
                        feedback.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    title: Text(feedback.traineeName),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(feedback.title),

                        const SizedBox(height: 4),

                        Text(
                          feedback.feedback,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "${feedback.createdAt.day}/${feedback.createdAt.month}/${feedback.createdAt.year}",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    trailing:
                        const Icon(Icons.chevron_right),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FeedbackDetailScreen(
                            programme: programme,
                            phase: phase,
                            session: session,
                            feedback: feedback,
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