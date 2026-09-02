/// Defines the four BASS platform roles.
/// Ordering matters for permission comparisons (index = seniority rank).
enum UserRole { trainee, coach, headCoach, superAdmin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.headCoach:
        return 'Head Coach';
      case UserRole.coach:
        return 'Coach';
      case UserRole.trainee:
        return 'Trainee';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.trainee,
    );
  }

  /// Whether this role can manage (create/edit/delete) programmes.
  bool get canManageProgrammes =>
      this == UserRole.superAdmin || this == UserRole.headCoach || this == UserRole.coach;

  /// Whether this role can review/verify coach-reviewed tasks.
  bool get canReviewTasks =>
      this == UserRole.superAdmin || this == UserRole.headCoach || this == UserRole.coach;

  /// Whether this role has org-wide (white-label tenant) admin rights.
  bool get isOrgAdmin => this == UserRole.superAdmin;
}

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? organisationId; // supports white-label multi-tenant architecture
  final String? programmeId; // primary programme assignment (trainee/coach)
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.organisationId,
    this.programmeId,
    this.avatarUrl,
    required this.createdAt,
    this.isActive = true,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: UserRoleX.fromString(map['role'] ?? 'trainee'),
      organisationId: map['organisationId'],
      programmeId: map['programmeId'],
      avatarUrl: map['avatarUrl'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'organisationId': organisationId,
      'programmeId': programmeId,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  AppUser copyWith({
    String? displayName,
    UserRole? role,
    String? programmeId,
    String? avatarUrl,
    bool? isActive,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      organisationId: organisationId,
      programmeId: programmeId ?? this.programmeId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
