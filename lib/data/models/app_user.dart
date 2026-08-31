import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool active;
  final String programmeId;

  final String phone;
  final String gender;
  final DateTime? dob;
  final String photoUrl;
  final String assignedHeadCoachId;
  final String assignedCoachId;
  final Timestamp? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    required this.programmeId,

    this.phone = '',
    this.gender = '',
    this.dob,
    this.photoUrl = '',
    this.assignedHeadCoachId = '',
    this.assignedCoachId = '',
    this.createdAt,
  });

  // factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
  //   return AppUser(
  //     uid: uid,
  //     name: map['name'] ?? '',
  //     email: map['email'] ?? '',
  //     role: map['role'] ?? '',
  //     active: map['active'] ?? true,
  //     programmeId: map['programmeId'] ?? '',
  //   );
  // }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'name': name,
  //     'email': email,
  //     'role': role,
  //     'active': active,
  //     'programmeId': programmeId,
  //   };
  // }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      active: map['active'] ?? true,
      programmeId: map['programmeId'] ?? '',

      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] != null ? (map['dob'] as Timestamp).toDate() : null,
      photoUrl: map['photoUrl'] ?? '',
      assignedHeadCoachId: map['assignedHeadCoachId'] ?? '',
      assignedCoachId: map['assignedCoachId'] ?? '',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'active': active,
      'programmeId': programmeId,

      'phone': phone,
      'gender': gender,
      'dob': dob == null ? null : Timestamp.fromDate(dob!),
      'photoUrl': photoUrl,
      'assignedHeadCoachId': assignedHeadCoachId,
      'assignedCoachId': assignedCoachId,
      'createdAt': createdAt,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? role,
    bool? active,
    String? programmeId,
    String? phone,
    String? gender,
    DateTime? dob,
    String? photoUrl,
    String? assignedHeadCoachId,
    String? assignedCoachId,
    Timestamp? createdAt,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
      programmeId: programmeId ?? this.programmeId,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      photoUrl: photoUrl ?? this.photoUrl,
      assignedHeadCoachId: assignedHeadCoachId ?? this.assignedHeadCoachId,
      assignedCoachId: assignedCoachId ?? this.assignedCoachId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
