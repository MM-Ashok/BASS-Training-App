/// A single logged block of on-hill teaching/shadowing experience.
/// Different activity types carry different weight towards the 70-hour target,
/// e.g. lead-teaching counts fully, shadowing counts partially.
class SkiHoursEntry {
  final String id;
  final String traineeId;
  final String? sessionId;
  final DateTime date;
  final double rawHours;
  final SkiActivityType activityType;
  final String? note;
  final bool coachVerified;
  final String? verifiedByCoachId;
  final DateTime createdAt;

  SkiHoursEntry({
    required this.id,
    required this.traineeId,
    this.sessionId,
    required this.date,
    required this.rawHours,
    required this.activityType,
    this.note,
    this.coachVerified = false,
    this.verifiedByCoachId,
    required this.createdAt,
  });

  /// Hours actually counted towards the 70-hour target after applying
  /// the activity's weighting factor. See [SkiActivityTypeX.weight].
  double get weightedHours => rawHours * activityType.weight;

  factory SkiHoursEntry.fromMap(String id, Map<String, dynamic> map) {
    return SkiHoursEntry(
      id: id,
      traineeId: map['traineeId'] ?? '',
      sessionId: map['sessionId'],
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      rawHours: (map['rawHours'] ?? 0).toDouble(),
      activityType: SkiActivityTypeX.fromString(map['activityType'] ?? 'leadTeaching'),
      note: map['note'],
      coachVerified: map['coachVerified'] ?? false,
      verifiedByCoachId: map['verifiedByCoachId'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'traineeId': traineeId,
      'sessionId': sessionId,
      'date': date.toIso8601String(),
      'rawHours': rawHours,
      'activityType': activityType.name,
      'note': note,
      'coachVerified': coachVerified,
      'verifiedByCoachId': verifiedByCoachId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Activity types recognised by the Ski School Experience tracker.
/// Weights are the "weighted pace calculation" referenced in the brief:
/// not all hours on snow are equal, so each type contributes differently
/// towards the 70-hour qualifying target.
enum SkiActivityType { leadTeaching, coTeaching, shadowing, clinic, selfPractice }

extension SkiActivityTypeX on SkiActivityType {
  /// Fraction of raw hours that counts towards the 70-hour target.
  /// These defaults are placeholders — confirm real weighting with the
  /// governing body / BASS syllabus before going live.
  double get weight {
    switch (this) {
      case SkiActivityType.leadTeaching:
        return 1.0;
      case SkiActivityType.coTeaching:
        return 0.75;
      case SkiActivityType.shadowing:
        return 0.5;
      case SkiActivityType.clinic:
        return 0.5;
      case SkiActivityType.selfPractice:
        return 0.25;
    }
  }

  String get label {
    switch (this) {
      case SkiActivityType.leadTeaching:
        return 'Lead Teaching';
      case SkiActivityType.coTeaching:
        return 'Co-Teaching';
      case SkiActivityType.shadowing:
        return 'Shadowing';
      case SkiActivityType.clinic:
        return 'Clinic / Workshop';
      case SkiActivityType.selfPractice:
        return 'Self Practice';
    }
  }

  static SkiActivityType fromString(String value) {
    return SkiActivityType.values.firstWhere(
      (a) => a.name == value,
      orElse: () => SkiActivityType.leadTeaching,
    );
  }
}
