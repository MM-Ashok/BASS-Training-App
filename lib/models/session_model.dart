/// A scheduled training session within a phase (e.g. a day on-hill or classroom module).
class TrainingSession {
  final String id;
  final String programmeId;
  final String phaseId;
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String leadCoachId;
  final List<String> assistantCoachIds;
  final List<String> taskIds; // tasks attached to this session
  final SessionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrainingSession({
    required this.id,
    required this.programmeId,
    required this.phaseId,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.leadCoachId,
    this.assistantCoachIds = const [],
    this.taskIds = const [],
    this.status = SessionStatus.scheduled,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration get duration => endTime.difference(startTime);

  factory TrainingSession.fromMap(String id, Map<String, dynamic> map) {
    return TrainingSession(
      id: id,
      programmeId: map['programmeId'] ?? '',
      phaseId: map['phaseId'] ?? '',
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime'] ?? '') ?? DateTime.now(),
      leadCoachId: map['leadCoachId'] ?? '',
      assistantCoachIds: List<String>.from(map['assistantCoachIds'] ?? const []),
      taskIds: List<String>.from(map['taskIds'] ?? const []),
      status: SessionStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'programmeId': programmeId,
      'phaseId': phaseId,
      'title': title,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'leadCoachId': leadCoachId,
      'assistantCoachIds': assistantCoachIds,
      'taskIds': taskIds,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TrainingSession copyWith({
    String? title,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? assistantCoachIds,
    List<String>? taskIds,
    SessionStatus? status,
  }) {
    return TrainingSession(
      id: id,
      programmeId: programmeId,
      phaseId: phaseId,
      title: title ?? this.title,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      leadCoachId: leadCoachId,
      assistantCoachIds: assistantCoachIds ?? this.assistantCoachIds,
      taskIds: taskIds ?? this.taskIds,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

enum SessionStatus { scheduled, inProgress, completed, cancelled }
