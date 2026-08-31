import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tasks Collection
  CollectionReference<Map<String, dynamic>> _taskCollection(
    String programmeId,
    String phaseId,
    String sessionId,
  ) {
    return _firestore
        .collection('programmes')
        .doc(programmeId)
        .collection('phases')
        .doc(phaseId)
        .collection('sessions')
        .doc(sessionId)
        .collection('tasks');
  }

  /// Create Task
  Future<void> createTask(TaskModel task) async {
    await _taskCollection(
      task.programmeId,
      task.phaseId,
      task.sessionId,
    ).doc(task.id).set(task.toMap());
  }

  /// Get All Tasks
  Stream<List<TaskModel>> getTasks(
    String programmeId,
    String phaseId,
    String sessionId,
  ) {
    return _taskCollection(
      programmeId,
      phaseId,
      sessionId,
    )
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TaskModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get Single Task
  Stream<TaskModel?> getTask(
    String programmeId,
    String phaseId,
    String sessionId,
    String taskId,
  ) {
    return _taskCollection(
      programmeId,
      phaseId,
      sessionId,
    ).doc(taskId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return TaskModel.fromMap(
        doc.data()!,
        doc.id,
      );
    });
  }

  /// Update Task
  Future<void> updateTask(TaskModel task) async {
    await _taskCollection(
      task.programmeId,
      task.phaseId,
      task.sessionId,
    ).doc(task.id).update(task.toMap());
  }

  /// Delete Task
  Future<void> deleteTask(
    String programmeId,
    String phaseId,
    String sessionId,
    String taskId,
  ) async {
    await _taskCollection(
      programmeId,
      phaseId,
      sessionId,
    ).doc(taskId).delete();
  }
}