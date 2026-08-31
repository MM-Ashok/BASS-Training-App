import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String programmeId;
  final String phaseId;

  final String title;
  final String description;

  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  final String coachId;
  final String coachName;

  final String status;

  SessionModel({
    required this.id,
    required this.programmeId,
    required this.phaseId,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.coachId,
    required this.coachName,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'programmeId': programmeId,
      'phaseId': phaseId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'coachId': coachId,
      'coachName': coachName,
      'status': status,
    };
  }

  factory SessionModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return SessionModel(
      id: id,
      programmeId: map['programmeId'] ?? '',
      phaseId: map['phaseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      coachId: map['coachId'] ?? '',
      coachName: map['coachName'] ?? '',
      status: map['status'] ?? 'Draft',
    );
  }
}