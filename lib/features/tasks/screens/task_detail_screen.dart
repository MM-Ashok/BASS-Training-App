import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/task_model.dart';

import '../providers/task_provider.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;
  final TaskModel task;

  final bool canEdit;
  final bool canDelete;

  const TaskDetailScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    required this.task,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(
      taskProvider(
        TaskDetailParams(
          programmeId: programme.id,
          phaseId: phase.id,
          sessionId: session.id,
          taskId: task.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final currentTask = taskAsync.value;
                if (currentTask == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTaskScreen(
                      programme: programme,
                      phase: phase,
                      session: session,
                      task: currentTask,
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
                    title: const Text("Delete Task"),
                    content: const Text(
                      "Are you sure you want to delete this task?",
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

                await ref.read(taskServiceProvider).deleteTask(
                      programme.id,
                      phase.id,
                      session.id,
                      task.id,
                    );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Task deleted successfully"),
                  ),
                );

                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (updatedTask) {
          if (updatedTask == null) {
            return const Center(
              child: Text("Task not found"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              _infoTile("Programme", programme.name),

              _infoTile("Phase", phase.title),

              _infoTile("Session", session.title),

              _infoTile("Task", updatedTask.title),

              _infoTile("Description", updatedTask.description),

              _infoTile("Category", updatedTask.category),

              _infoTile("Status", updatedTask.status),

              _infoTile(
                "Due Date",
                "${updatedTask.dueDate.day}/${updatedTask.dueDate.month}/${updatedTask.dueDate.year}",
              ),

              _infoTile(
                "Auto Verify",
                updatedTask.autoVerify ? "Yes" : "No",
              ),

              _infoTile(
                "Coach Review Required",
                updatedTask.coachReviewRequired ? "Yes" : "No",
              ),

              _infoTile(
                "Assigned To",
                updatedTask.assignedTo.isEmpty
                    ? "Not Assigned"
                    : updatedTask.assignedTo,
              ),

              _infoTile(
                "Created By",
                updatedTask.createdBy,
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

            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}