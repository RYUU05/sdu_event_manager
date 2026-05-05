// Три роли: обычный студент, администратор клуба (после одобрения заявки),
// и суперадмин SDULife (проставляется вручную в Firestore Console).
enum UserRole { student, clubAdmin, superAdmin }

class UserEntity {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  /// Теги интересов для POST /recommend
  final List<String> interests;

  /// ID клуба, которым управляет club_admin (null для student / super_admin)
  final String? managedClubId;

  final String avatarUrl;
  final String bannerUrl;
  final String description;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.interests = const [],
    this.managedClubId,
    this.avatarUrl = '',
    this.bannerUrl = '',
    this.description = '',
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
        return UserRole.clubAdmin;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.student;
    }
  }

  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.clubAdmin:
        return 'club_admin';
      case UserRole.superAdmin:
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
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
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
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'description': description,
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    List<String>? interests,
    String? managedClubId,
    String? avatarUrl,
    String? bannerUrl,
    String? description,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      interests: interests ?? this.interests,
      managedClubId: managedClubId ?? this.managedClubId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      description: description ?? this.description,
    );
  }
}

// ─── Permissions extension ───────────────────────────────────────────────────

extension UserPermissions on UserEntity {
  bool get isStudent => role == UserRole.student;
  bool get isClubAdmin => role == UserRole.clubAdmin;
  bool get isSuperAdmin => role == UserRole.superAdmin;

  /// Создавать события может только club_admin
  bool get canCreateEvent => role == UserRole.clubAdmin;

  /// Видеть панель модератора
  bool get canModerate => role == UserRole.superAdmin;
}
