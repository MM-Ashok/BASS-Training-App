import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

/// Manages the Task Library (reusable task definitions) and per-trainee
/// completions, handling the auto-verified vs coach-reviewed split.
class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final _uuid = const Uuid();
  String? _organisationId;

  List<TaskDefinition> library = [];
  List<TaskCompletion> myCompletions = [];
  List<TaskCompletion> pendingReviews = [];

  StreamSubscription? _librarySub;
  StreamSubscription? _completionsSub;
  StreamSubscription? _reviewsSub;

  void init(String organisationId) {
    _organisationId = organisationId;
    _librarySub?.cancel();
    _librarySub = _firestore.watchTaskLibrary(organisationId).listen((data) {
      library = data;
      notifyListeners();
    });
  }

  void watchTraineeCompletions(String traineeId) {
    if (_organisationId == null) return;
    _completionsSub?.cancel();
    _completionsSub =
        _firestore.watchCompletionsForTrainee(_organisationId!, traineeId).listen((data) {
      myCompletions = data;
      notifyListeners();
    });
  }

  void watchPendingReviews() {
    if (_organisationId == null) return;
    _reviewsSub?.cancel();
    _reviewsSub = _firestore.watchPendingReviews(_organisationId!).listen((data) {
      pendingReviews = data;
      notifyListeners();
    });
  }

  Future<void> createTaskDefinition({
    String? programmeId,
    required String title,
    required String description,
    required VerificationType verificationType,
    List<String> skillTags = const [],
    int estimatedMinutes = 0,
  }) async {
    if (_organisationId == null) return;
    final task = TaskDefinition(
      id: _uuid.v4(),
      organisationId: _organisationId!,
      programmeId: programmeId,
      title: title,
      description: description,
      verificationType: verificationType,
      skillTags: skillTags,
      estimatedMinutes: estimatedMinutes,
      createdAt: DateTime.now(),
    );
    await _firestore.createTaskDefinition(_organisationId!, task);
  }

  Future<void> deleteTaskDefinition(String taskId) async {
    if (_organisationId == null) return;
    await _firestore.deleteTaskDefinition(_organisationId!, taskId);
  }

  /// Submits a completion. Auto-verified tasks are immediately marked
  /// approved; coach-reviewed tasks go into the pending-review queue.
  Future<void> submitCompletion({
    required TaskDefinition task,
    required String traineeId,
    String? sessionId,
    String? note,
  }) async {
    if (_organisationId == null) return;
    final isAuto = task.verificationType == VerificationType.autoVerified;
    final completion = TaskCompletion(
      id: _uuid.v4(),
      taskDefinitionId: task.id,
      traineeId: traineeId,
      sessionId: sessionId,
      status: isAuto ? TaskCompletionStatus.approved : TaskCompletionStatus.submitted,
      traineeNote: note,
      submittedAt: DateTime.now(),
      reviewedAt: isAuto ? DateTime.now() : null,
    );
    await _firestore.submitTaskCompletion(_organisationId!, completion);
  }

  Future<void> reviewCompletion({
    required TaskCompletion completion,
    required bool approve,
    required String coachId,
    String? feedback,
  }) async {
    if (_organisationId == null) return;
    final updated = completion.copyWith(
      status: approve ? TaskCompletionStatus.approved : TaskCompletionStatus.rejected,
      reviewedByCoachId: coachId,
      coachFeedback: feedback,
      reviewedAt: DateTime.now(),
    );
    await _firestore.reviewTaskCompletion(_organisationId!, updated);
  }

  @override
  void dispose() {
    _librarySub?.cancel();
    _completionsSub?.cancel();
    _reviewsSub?.cancel();
    super.dispose();
  }
}
