enum UserRole { student, club }

class UserEntity {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'student';
    final role = roleStr == 'club' ? UserRole.club : UserRole.student;

    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? json['email'] as String,
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role == UserRole.club ? 'club' : 'student',
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }
}

/// Extension for user permissions
extension UserPermissions on UserEntity {
  /// Check if user can create events
  bool get canCreateEvent => role == UserRole.club;

  /// Check if user is student
  bool get isStudent => role == UserRole.student;

  /// Check if user is club
  bool get isClub => role == UserRole.club;
}
