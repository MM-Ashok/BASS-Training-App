import 'package:cloud_firestore/cloud_firestore.dart';

class ProgrammeModel {
  final String id;
  final String name;
  final String description;
  final String season;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String createdBy;
  final DateTime createdAt;

  const ProgrammeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.season,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory ProgrammeModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ProgrammeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      season: data['season'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Draft',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'season': season,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ProgrammeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? season,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ProgrammeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      season: season ?? this.season,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}