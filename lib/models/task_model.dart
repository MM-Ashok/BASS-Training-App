/// How a task's completion is confirmed.
enum VerificationType {
  /// Trainee self-reports and it's accepted immediately (e.g. "watched video", logged hours)
  autoVerified,

  /// Requires a coach to review and approve before it counts as complete
  coachReviewed,
}

enum TaskCompletionStatus { notStarted, submitted, approved, rejected }

/// A reusable definition living in the Task Library (org or programme scoped).
class TaskDefinition {
  final String id;
  final String organisationId;
  final String? programmeId; // null = library-wide, reusable across programmes
  final String title;
  final String description;
  final VerificationType verificationType;
  final List<String> skillTags; // links to skills framework, used for cross-reference
  final int estimatedMinutes;
  final DateTime createdAt;

  TaskDefinition({
    required this.id,
    required this.organisationId,
    this.programmeId,
    required this.title,
    required this.description,
    required this.verificationType,
    this.skillTags = const [],
    this.estimatedMinutes = 0,
    required this.createdAt,
  });

  factory TaskDefinition.fromMap(String id, Map<String, dynamic> map) {
    return TaskDefinition(
      id: id,
      organisationId: map['organisationId'] ?? '',
      programmeId: map['programmeId'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      verificationType: VerificationType.values.firstWhere(
        (v) => v.name == map['verificationType'],
        orElse: () => VerificationType.autoVerified,
      ),
      skillTags: List<String>.from(map['skillTags'] ?? const []),
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organisationId': organisationId,
      'programmeId': programmeId,
      'title': title,
      'description': description,
      'verificationType': verificationType.name,
      'skillTags': skillTags,
      'estimatedMinutes': estimatedMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// A trainee's completion record against a [TaskDefinition].
/// Kept separate from the definition so the library stays reusable
/// while completions are per-trainee, per-session.
class TaskCompletion {
  final String id;
  final String taskDefinitionId;
  final String traineeId;
  final String? sessionId;
  final TaskCompletionStatus status;
  final String? traineeNote;
  final String? coachFeedback;
  final String? reviewedByCoachId;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  TaskCompletion({
    required this.id,
    required this.taskDefinitionId,
    required this.traineeId,
    this.sessionId,
    this.status = TaskCompletionStatus.notStarted,
    this.traineeNote,
    this.coachFeedback,
    this.reviewedByCoachId,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory TaskCompletion.fromMap(String id, Map<String, dynamic> map) {
    return TaskCompletion(
      id: id,
      taskDefinitionId: map['taskDefinitionId'] ?? '',
      traineeId: map['traineeId'] ?? '',
      sessionId: map['sessionId'],
      status: TaskCompletionStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => TaskCompletionStatus.notStarted,
      ),
      traineeNote: map['traineeNote'],
      coachFeedback: map['coachFeedback'],
      reviewedByCoachId: map['reviewedByCoachId'],
      submittedAt: DateTime.tryParse(map['submittedAt'] ?? '') ?? DateTime.now(),
      reviewedAt: map['reviewedAt'] != null ? DateTime.tryParse(map['reviewedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskDefinitionId': taskDefinitionId,
      'traineeId': traineeId,
      'sessionId': sessionId,
      'status': status.name,
      'traineeNote': traineeNote,
      'coachFeedback': coachFeedback,
      'reviewedByCoachId': reviewedByCoachId,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  TaskCompletion copyWith({
    TaskCompletionStatus? status,
    String? traineeNote,
    String? coachFeedback,
    String? reviewedByCoachId,
    DateTime? reviewedAt,
  }) {
    return TaskCompletion(
      id: id,
      taskDefinitionId: taskDefinitionId,
      traineeId: traineeId,
      sessionId: sessionId,
      status: status ?? this.status,
      traineeNote: traineeNote ?? this.traineeNote,
      coachFeedback: coachFeedback ?? this.coachFeedback,
      reviewedByCoachId: reviewedByCoachId ?? this.reviewedByCoachId,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
