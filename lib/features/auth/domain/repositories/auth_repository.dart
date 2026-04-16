import 'package:dartz/dartz.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';

/// Repository for authentication operations
abstract class AuthRepository {
  /// Get current user
  Future<Option<UserEntity>> getCurrentUser();
  
  /// Login user
  Future<Either<String, UserEntity>> login(String email, String password);
  
  /// Register user
  Future<Either<String, UserEntity>> register(String email, String password, String name);
  
  /// Logout user
  Future<void> logout();
  
  /// Update user role (admin function)
  Future<Either<String, UserEntity>> updateUserRole(String userId, UserRole newRole);
}
