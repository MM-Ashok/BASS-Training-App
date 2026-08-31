import 'package:cloud_firestore/cloud_firestore.dart';

class ExperienceModel {
  final String id;

  /// Trainee
  final String traineeId;
  final String traineeName;

  /// Programme hierarchy
  final String programmeId;
  final String phaseId;
  final String sessionId;
  final String sessionTitle;

  /// Coach
  final String coachId;
  final String coachName;

  /// Experience details
  final DateTime date;

  /// Hours completed
  final double hours;

  /// Training location
  final String location;

  /// Coach notes
  final String notes;

  /// Pending / Approved / Rejected
  final String status;

  /// Created timestamp
  final DateTime createdAt;

  const ExperienceModel({
    required this.id,
    required this.traineeId,
    required this.traineeName,
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
    required this.sessionTitle,
    required this.coachId,
    required this.coachName,
    required this.date,
    required this.hours,
    required this.location,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map, String id) {
    return ExperienceModel(
      id: id,
      traineeId: map['traineeId'] ?? '',
      traineeName: map['traineeName'] ?? '',
      programmeId: map['programmeId'] ?? '',
      phaseId: map['phaseId'] ?? '',
      sessionId: map['sessionId'] ?? '',
      sessionTitle: map['sessionTitle'] ?? '',
      coachId: map['coachId'] ?? '',
      coachName: map['coachName'] ?? '',
      date: map['date'] != null
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      hours: (map['hours'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'traineeId': traineeId,
      'traineeName': traineeName,
      'programmeId': programmeId,
      'phaseId': phaseId,
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      'coachId': coachId,
      'coachName': coachName,
      'date': date,
      'hours': hours,
      'location': location,
      'notes': notes,
      'status': status,
      'createdAt': createdAt,
    };
  }

  ExperienceModel copyWith({
    String? traineeName,
    String? sessionTitle,
    String? coachName,
    DateTime? date,
    double? hours,
    String? location,
    String? notes,
    String? status,
    DateTime? createdAt,
  }) {
    return ExperienceModel(
      id: id,
      traineeId: traineeId,
      traineeName: traineeName ?? this.traineeName,
      programmeId: programmeId,
      phaseId: phaseId,
      sessionId: sessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      coachId: coachId,
      coachName: coachName ?? this.coachName,
      date: date ?? this.date,
      hours: hours ?? this.hours,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
