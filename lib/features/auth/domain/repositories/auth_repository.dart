import 'package:dartz/dartz.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';

/// Repository for authentication operations
abstract class AuthRepository {
  /// Login user
  Future<Either<String, UserEntity>> login(String email, String password);

  /// Register user
  Future<Either<String, UserEntity>> register(
    String email,
    String password,
    String name,
    UserRole role,
  );

  /// Logout user
  Future<void> logout();

  /// Get current user
  Future<Option<UserEntity>> getCurrentUser();

  /// Get user stream
  Stream<UserEntity?> get user;
}
