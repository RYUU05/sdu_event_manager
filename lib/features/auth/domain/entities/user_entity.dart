import 'package:equatable/equatable.dart';

/// User roles enum
enum UserRole {
  student,
  club,
}

/// User entity with role-based permissions
class UserEntity extends Equatable {
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

  /// Factory constructor for creating user from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final roleString = json['role'] as String? ?? 'student';
    final role = UserRole.values.firstWhere(
      (role) => role.name == roleString,
      orElse: () => UserRole.student,
    );

    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? json['email'] as String,
      role: role,
    );
  }

  /// Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
    };
  }

  /// Copy user with new values
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

  @override
  List<Object?> get props => [id, email, name, role];

  @override
  String toString() => 'UserEntity(id: $id, email: $email, name: $name, role: $role)';
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
