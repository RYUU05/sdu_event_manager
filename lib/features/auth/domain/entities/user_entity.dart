// Три роли: обычный студент, администратор клуба (после одобрения заявки),
// и суперадмин SDULife (проставляется вручную в Firestore Console).
enum UserRole { student, club_admin, super_admin }

class UserEntity {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  /// Теги интересов для POST /recommend
  final List<String> interests;

  /// ID клуба, которым управляет club_admin (null для student / super_admin)
  final String? managedClubId;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.interests = const [],
    this.managedClubId,
  });

  // ─── Helpers ────────────────────────────────────────────────────────────────

  static List<String> interestsFromFirestore(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  static UserRole roleFromString(String? raw) {
    switch (raw) {
      case 'club_admin':
        return UserRole.club_admin;
      case 'super_admin':
        return UserRole.super_admin;
      default:
        return UserRole.student;
    }
  }

  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.club_admin:
        return 'club_admin';
      case UserRole.super_admin:
        return 'super_admin';
      case UserRole.student:
        return 'student';
    }
  }

  // ─── Serialization ──────────────────────────────────────────────────────────

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? json['email'] as String,
      role: roleFromString(json['role'] as String?),
      interests: interestsFromFirestore(json['interests']),
      managedClubId: json['managedClubId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': roleToString(role),
      'interests': interests,
      if (managedClubId != null) 'managedClubId': managedClubId,
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    List<String>? interests,
    String? managedClubId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      interests: interests ?? this.interests,
      managedClubId: managedClubId ?? this.managedClubId,
    );
  }
}

// ─── Permissions extension ───────────────────────────────────────────────────

extension UserPermissions on UserEntity {
  bool get isStudent => role == UserRole.student;
  bool get isClubAdmin => role == UserRole.club_admin;
  bool get isSuperAdmin => role == UserRole.super_admin;

  /// Создавать события может только club_admin
  bool get canCreateEvent => role == UserRole.club_admin;

  /// Видеть панель модератора
  bool get canModerate => role == UserRole.super_admin;
}
