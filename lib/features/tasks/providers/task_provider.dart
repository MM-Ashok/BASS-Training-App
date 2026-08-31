import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/task_model.dart';
import '../services/task_service.dart';

/// Task Service Provider
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

/// Parameters for Task List
class TaskParams {
  final String programmeId;
  final String phaseId;
  final String sessionId;

  TaskParams({
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskParams &&
          runtimeType == other.runtimeType &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId &&
          sessionId == other.sessionId;

  @override
  int get hashCode =>
      programmeId.hashCode ^
      phaseId.hashCode ^
      sessionId.hashCode;
}

/// Stream of Tasks
final tasksProvider =
    StreamProvider.family<List<TaskModel>, TaskParams>(
  (ref, params) {
    return ref.read(taskServiceProvider).getTasks(
          params.programmeId,
          params.phaseId,
          params.sessionId,
        );
  },
);

/// Parameters for Single Task
class TaskDetailParams {
  final String programmeId;
  final String phaseId;
  final String sessionId;
  final String taskId;

  TaskDetailParams({
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
    required this.taskId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDetailParams &&
          runtimeType == other.runtimeType &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId &&
          sessionId == other.sessionId &&
          taskId == other.taskId;

  @override
  int get hashCode =>
      programmeId.hashCode ^
      phaseId.hashCode ^
      sessionId.hashCode ^
      taskId.hashCode;
}

/// Single Task Provider
final taskProvider =
    StreamProvider.family<TaskModel?, TaskDetailParams>(
  (ref, params) {
    return ref.read(taskServiceProvider).getTask(
          params.programmeId,
          params.phaseId,
          params.sessionId,
          params.taskId,
        );
  },
);