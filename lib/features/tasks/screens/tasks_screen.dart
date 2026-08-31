import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/task_model.dart';

import '../providers/task_provider.dart';

import 'create_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  final bool canEdit;
  final bool canDelete;

  const TasksScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    this.canEdit = false,
    this.canDelete = false,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;

      case "in progress":
        return Colors.orange;

      case "pending":
        return Colors.red;

      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(
      tasksProvider(
        TaskParams(
          programmeId: programme.id,
          phaseId: phase.id,
          sessionId: session.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(session.title),
      ),

      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text("Task"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateTaskScreen(
                      programme: programme,
                      phase: phase,
                      session: session,
                    ),
                  ),
                );
              },
            )
          : null,

      body: tasks.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (taskList) {
          if (taskList.isEmpty) {
            return const Center(
              child: Text(
                "No Tasks Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: taskList.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final TaskModel task = taskList[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(task.status),
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 4),

                      Text(task.category),

                      const SizedBox(height: 4),

                      Text(
                        "Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}",
                      ),
                    ],
                  ),

                  trailing: Chip(
                    label: Text(task.status),
                    backgroundColor:
                        _statusColor(task.status).withOpacity(.15),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(
                          programme: programme,
                          phase: phase,
                          session: session,
                          task: task,
                          canEdit: canEdit,
                          canDelete: canDelete,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}