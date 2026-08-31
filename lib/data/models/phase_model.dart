import 'package:cloud_firestore/cloud_firestore.dart';

class PhaseModel {
  final String id;
  final String programmeId;

  final String title;
  final String description;

  final int order;

  final DateTime startDate;
  final DateTime endDate;

  final String status;

  final DateTime createdAt;

  PhaseModel({
    required this.id,
    required this.programmeId,
    required this.title,
    required this.description,
    required this.order,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  factory PhaseModel.fromMap(Map<String, dynamic> map, String id) {
    return PhaseModel(
      id: id,
      programmeId: map['programmeId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      order: map['order'] ?? 1,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'Draft',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'programmeId': programmeId,
      'title': title,
      'description': description,
      'order': order,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PhaseModel copyWith({
    String? id,
    String? programmeId,
    String? title,
    String? description,
    int? order,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
  }) {
    return PhaseModel(
      id: id ?? this.id,
      programmeId: programmeId ?? this.programmeId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}