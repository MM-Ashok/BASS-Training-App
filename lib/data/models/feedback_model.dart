import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;

  final String programmeId;
  final String phaseId;
  final String sessionId;

  final String traineeId;
  final String traineeName;

  final String coachId;
  final String coachName;

  final String title;

  final String feedback;

  /// Overall rating (1–5)
  final int rating;

  /// Skills tagged in this feedback
  final List<String> skills;

  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
    required this.traineeId,
    required this.traineeName,
    required this.coachId,
    required this.coachName,
    required this.title,
    required this.feedback,
    required this.rating,
    required this.skills,
    required this.createdAt,
  });

  factory FeedbackModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return FeedbackModel(
      id: id,
      programmeId: map['programmeId'] ?? '',
      phaseId: map['phaseId'] ?? '',
      sessionId: map['sessionId'] ?? '',
      traineeId: map['traineeId'] ?? '',
      traineeName: map['traineeName'] ?? '',
      coachId: map['coachId'] ?? '',
      coachName: map['coachName'] ?? '',
      title: map['title'] ?? '',
      feedback: map['feedback'] ?? '',
      rating: map['rating'] ?? 0,
      skills: List<String>.from(map['skills'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
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
      'coachId': coachId,
      'coachName': coachName,
      'title': title,
      'feedback': feedback,
      'rating': rating,
      'skills': skills,
      'createdAt': createdAt,
    };
  }

  FeedbackModel copyWith({
    String? traineeName,
    String? coachName,
    String? title,
    String? feedback,
    int? rating,
    List<String>? skills,
    DateTime? createdAt,
  }) {
    return FeedbackModel(
      id: id,
      programmeId: programmeId,
      phaseId: phaseId,
      sessionId: sessionId,
      traineeId: traineeId,
      traineeName: traineeName ?? this.traineeName,
      coachId: coachId,
      coachName: coachName ?? this.coachName,
      title: title ?? this.title,
      feedback: feedback ?? this.feedback,
      rating: rating ?? this.rating,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}