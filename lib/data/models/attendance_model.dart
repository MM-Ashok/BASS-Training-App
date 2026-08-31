import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;

  final String programmeId;
  final String phaseId;
  final String sessionId;

  final String traineeId;
  final String traineeName;

  final String status;

  final DateTime? checkInTime;

  final String notes;

  final String markedBy;

  final DateTime markedAt;

  const AttendanceModel({
    required this.id,
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
    required this.traineeId,
    required this.traineeName,
    required this.status,
    required this.checkInTime,
    required this.notes,
    required this.markedBy,
    required this.markedAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      programmeId: map['programmeId'] ?? '',
      phaseId: map['phaseId'] ?? '',
      sessionId: map['sessionId'] ?? '',
      traineeId: map['traineeId'] ?? '',
      traineeName: map['traineeName'] ?? '',
      status: map['status'] ?? 'Absent',
      checkInTime: map['checkInTime'] != null
          ? (map['checkInTime'] as Timestamp).toDate()
          : null,
      notes: map['notes'] ?? '',
      markedBy: map['markedBy'] ?? '',
      markedAt: map['markedAt'] != null
          ? (map['markedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'programmeId': programmeId,
      'phaseId': phaseId,
      'sessionId': sessionId,
      'traineeId': traineeId,
      'traineeName': traineeName,
      'status': status,
      'checkInTime': checkInTime,
      'notes': notes,
      'markedBy': markedBy,
      'markedAt': markedAt,
    };
  }

  AttendanceModel copyWith({
    String? traineeName,
    String? status,
    DateTime? checkInTime,
    String? notes,
    String? markedBy,
    DateTime? markedAt,
  }) {
    return AttendanceModel(
      id: id,
      programmeId: programmeId,
      phaseId: phaseId,
      sessionId: sessionId,
      traineeId: traineeId,
      traineeName: traineeName ?? this.traineeName,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      notes: notes ?? this.notes,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
    );
  }
}
