import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class TaskLibraryScreen extends StatefulWidget {
  const TaskLibraryScreen({super.key});

  @override
  State<TaskLibraryScreen> createState() => _TaskLibraryScreenState();
}

class _TaskLibraryScreenState extends State<TaskLibraryScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final orgId = auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    final taskProvider = context.read<TaskProvider>();
    taskProvider.init(orgId);
    if (auth.currentUser != null) {
      taskProvider.watchTraineeCompletions(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final canManage = auth.role?.canManageProgrammes ?? false;
    final isTrainee = auth.role == UserRole.trainee;

    return Scaffold(
      appBar: AppBar(title: const Text('Task Library')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateTaskSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
            )
          : null,
      body: taskProvider.library.isEmpty
          ? Center(
              child: Text('No tasks in the library yet', style: TextStyle(color: Colors.grey[600])))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: taskProvider.library.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final task = taskProvider.library[i];
                final isAuto = task.verificationType == VerificationType.autoVerified;
                final myCompletion = taskProvider.myCompletions
                    .where((c) => c.taskDefinitionId == task.id)
                    .toList();
                final status =
                    myCompletion.isNotEmpty ? myCompletion.first.status : TaskCompletionStatus.notStarted;

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: (isAuto ? AppTheme.success : AppTheme.accent).withOpacity(0.12),
                      child: Icon(
                        isAuto ? Icons.bolt : Icons.person_search,
                        color: isAuto ? AppTheme.success : AppTheme.accent,
                        size: 20,
                      ),
                    ),
                    title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(task.description),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            Chip(
                              label: Text(isAuto ? 'Auto-verified' : 'Coach-reviewed',
                                  style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  (isAuto ? AppTheme.success : AppTheme.accent).withOpacity(0.1),
                            ),
                            if (isTrainee)
                              Chip(
                                label: Text(_statusLabel(status), style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                              ),
                            ...task.skillTags.map((t) => Chip(
                                  label: Text(t, style: const TextStyle(fontSize: 11)),
                                  visualDensity: VisualDensity.compact,
                                )),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: isTrainee
                        ? IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            tooltip: 'Mark complete',
                            onPressed: status == TaskCompletionStatus.notStarted
                                ? () => _submitCompletion(context, task)
                                : null,
                          )
                        : (canManage
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    context.read<TaskProvider>().deleteTaskDefinition(task.id),
                              )
                            : null),
                  ),
                );
              },
            ),
    );
  }

  String _statusLabel(TaskCompletionStatus status) {
    switch (status) {
      case TaskCompletionStatus.notStarted:
        return 'Not started';
      case TaskCompletionStatus.submitted:
        return 'Awaiting review';
      case TaskCompletionStatus.approved:
        return 'Completed';
      case TaskCompletionStatus.rejected:
        return 'Needs resubmission';
    }
  }

  Future<void> _submitCompletion(BuildContext context, TaskDefinition task) async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;
    await context.read<TaskProvider>().submitCompletion(
          task: task,
          traineeId: auth.currentUser!.id,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          task.verificationType == VerificationType.autoVerified
              ? 'Task marked complete!'
              : 'Submitted for coach review',
        ),
      ));
    }
  }

  void _showCreateTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final tagsController = TextEditingController();
    VerificationType type = VerificationType.autoVerified;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Task', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Skill tags (comma separated)',
                  hintText: 'e.g. Edge Control, Client Communication',
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<VerificationType>(
                segments: const [
                  ButtonSegment(
                    value: VerificationType.autoVerified,
                    label: Text('Auto-verified'),
                    icon: Icon(Icons.bolt),
                  ),
                  ButtonSegment(
                    value: VerificationType.coachReviewed,
                    label: Text('Coach-reviewed'),
                    icon: Icon(Icons.person_search),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (s) => setSheetState(() => type = s.first),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  await context.read<TaskProvider>().createTaskDefinition(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        verificationType: type,
                        skillTags: tagsController.text
                            .split(',')
                            .map((t) => t.trim())
                            .where((t) => t.isNotEmpty)
                            .toList(),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Add to Library'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
