import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// Coach-reviewed task queue — coaches approve/reject trainee submissions.
class PendingReviewsScreen extends StatefulWidget {
  const PendingReviewsScreen({super.key});

  @override
  State<PendingReviewsScreen> createState() => _PendingReviewsScreenState();
}

class _PendingReviewsScreenState extends State<PendingReviewsScreen> {
  @override
  void initState() {
    super.initState();
    final orgId =
        context.read<AuthProvider>().currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    final provider = context.read<TaskProvider>();
    provider.init(orgId);
    provider.watchPendingReviews();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final auth = context.watch<AuthProvider>();
    final dateFmt = DateFormat('MMM d, HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Reviews')),
      body: provider.pendingReviews.isEmpty
          ? Center(
              child: Text('Nothing waiting for review 🎉',
                  style: TextStyle(color: Colors.grey[600])))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingReviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final completion = provider.pendingReviews[i];
                final task = provider.library.where((t) => t.id == completion.taskDefinitionId);
                final title = task.isNotEmpty ? task.first.title : 'Task';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Trainee: ${completion.traineeId}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        Text('Submitted: ${dateFmt.format(completion.submittedAt)}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        if (completion.traineeNote != null && completion.traineeNote!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('"${completion.traineeNote}"',
                              style: const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _review(context, completion, false, auth),
                                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _review(context, completion, true, auth),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                                child: const Text('Approve'),
                              ),
                            ),
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

  Future<void> _review(
      BuildContext context, TaskCompletion completion, bool approve, AuthProvider auth) async {
    await context.read<TaskProvider>().reviewCompletion(
          completion: completion,
          approve: approve,
          coachId: auth.currentUser?.id ?? 'demo-coach',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(approve ? 'Approved' : 'Rejected')));
    }
  }
}
