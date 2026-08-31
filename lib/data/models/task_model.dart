import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;

  final String programmeId;
  final String phaseId;
  final String sessionId;

  final String title;
  final String description;
  final String category;

  final DateTime dueDate;

  final String status;

  final bool autoVerify;
  final bool coachReviewRequired;

  final String createdBy;
  final String assignedTo;

  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.status,
    required this.autoVerify,
    required this.coachReviewRequired,
    required this.createdBy,
    required this.assignedTo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'programmeId': programmeId,
      'phaseId': phaseId,
      'sessionId': sessionId,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'autoVerify': autoVerify,
      'coachReviewRequired': coachReviewRequired,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TaskModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return TaskModel(
      id: id,
      programmeId: map['programmeId'] ?? '',
      phaseId: map['phaseId'] ?? '',
      sessionId: map['sessionId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'Pending',
      autoVerify: map['autoVerify'] ?? false,
      coachReviewRequired:
          map['coachReviewRequired'] ?? false,
      createdBy: map['createdBy'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? status,
    bool? autoVerify,
    bool? coachReviewRequired,
    String? assignedTo,
  }) {
    return TaskModel(
      id: id,
      programmeId: programmeId,
      phaseId: phaseId,
      sessionId: sessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      autoVerify: autoVerify ?? this.autoVerify,
      coachReviewRequired:
          coachReviewRequired ?? this.coachReviewRequired,
      createdBy: createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
    );
  }
}