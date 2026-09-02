/// Top-level training programme (e.g. "2026 Instructor Season", "Race Coach Pathway").
/// A programme owns a phased season structure -> sessions -> tasks.
class Programme {
  final String id;
  final String organisationId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String headCoachId;
  final List<String> coachIds;
  final List<String> traineeIds;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Programme({
    required this.id,
    required this.organisationId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.headCoachId,
    this.coachIds = const [],
    this.traineeIds = const [],
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Programme.fromMap(String id, Map<String, dynamic> map) {
    return Programme(
      id: id,
      organisationId: map['organisationId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now(),
      headCoachId: map['headCoachId'] ?? '',
      coachIds: List<String>.from(map['coachIds'] ?? const []),
      traineeIds: List<String>.from(map['traineeIds'] ?? const []),
      isArchived: map['isArchived'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organisationId': organisationId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'headCoachId': headCoachId,
      'coachIds': coachIds,
      'traineeIds': traineeIds,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Programme copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? coachIds,
    List<String>? traineeIds,
    bool? isArchived,
  }) {
    return Programme(
      id: id,
      organisationId: organisationId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      headCoachId: headCoachId,
      coachIds: coachIds ?? this.coachIds,
      traineeIds: traineeIds ?? this.traineeIds,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// A phase is a chunk of the season (e.g. "Pre-season", "Phase 1: Fundamentals").
/// Phases give the programme its structure and hold ordered sessions.
class Phase {
  final String id;
  final String programmeId;
  final String title;
  final String description;
  final int orderIndex; // for drag-reorder in the phase timeline
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Phase({
    required this.id,
    required this.programmeId,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Phase.fromMap(String id, Map<String, dynamic> map) {
    return Phase(
      id: id,
      programmeId: map['programmeId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      orderIndex: map['orderIndex'] ?? 0,
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'programmeId': programmeId,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Phase copyWith({
    String? title,
    String? description,
    int? orderIndex,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Phase(
      id: id,
      programmeId: programmeId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
