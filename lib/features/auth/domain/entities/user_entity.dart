enum UserRole { student, club }

class UserEntity {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  /// Теги интересов для POST /recommend (Firestore `users.interests`).
  final List<String> interests;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.interests = const [],
  });

  static List<String> interestsFromFirestore(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'student';
    final role = roleStr == 'club' ? UserRole.club : UserRole.student;

    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? json['email'] as String,
      role: role,
      interests: interestsFromFirestore(json['interests']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role == UserRole.club ? 'club' : 'student',
      'interests': interests,
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    List<String>? interests,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      interests: interests ?? this.interests,
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
