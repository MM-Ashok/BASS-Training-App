enum AttendanceStatus { present, late, absent, excused }

class AttendanceRecord {
  final String id;
  final String sessionId;
  final String traineeId;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final String? recordedByCoachId;
  final DateTime createdAt;

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.traineeId,
    required this.status,
    this.checkInTime,
    this.recordedByCoachId,
    required this.createdAt,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      id: id,
      sessionId: map['sessionId'] ?? '',
      traineeId: map['traineeId'] ?? '',
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      checkInTime: map['checkInTime'] != null ? DateTime.tryParse(map['checkInTime']) : null,
      recordedByCoachId: map['recordedByCoachId'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'traineeId': traineeId,
      'status': status.name,
      'checkInTime': checkInTime?.toIso8601String(),
      'recordedByCoachId': recordedByCoachId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Rolled-up engagement metrics for a trainee across a programme.
/// This is a *derived/computed* model (see EngagementService) rather
/// than something written directly by users.
class EngagementSummary {
  final String traineeId;
  final double attendanceRate; // 0-1
  final double taskCompletionRate; // 0-1
  final double avgCoachResponseHours; // coach responsiveness metric
  final int feedbackEntriesCount;
  final double engagementScore; // 0-100 composite score

  EngagementSummary({
    required this.traineeId,
    required this.attendanceRate,
    required this.taskCompletionRate,
    required this.avgCoachResponseHours,
    required this.feedbackEntriesCount,
    required this.engagementScore,
  });
}
