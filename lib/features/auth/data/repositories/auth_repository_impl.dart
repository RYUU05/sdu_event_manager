import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/domain/repositories/auth_repository.dart';

/// Firebase implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<Option<UserEntity>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Get user role from custom claims or default to student
        final role = _getUserRoleFromClaims(user);
        
        return some(UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? user.email ?? '',
          role: role,
        ));
      }
      return none();
    } catch (e) {
      return none();
    }
  }

  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user != null) {
        final role = UserRole.student; // Default role for new users
        
        return right(UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? email,
          role: role,
        ));
      }
      
      return left('User not found');
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Login failed');
    } catch (e) {
      return left('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> register(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user != null) {
        final role = UserRole.student; // Default role for new users
        
        return right(UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: name,
          role: role,
        ));
      }
      
      return left('Registration failed');
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Registration failed');
    } catch (e) {
      return left('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // Log error but don't throw - logout should always succeed
      print('Logout error: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> updateUserRole(String userId, UserRole newRole) async {
    try {
      // This would typically be an admin function
      // For now, return success without actual implementation
      return right(UserEntity(
        id: userId,
        email: '',
        name: '',
        role: newRole,
      ));
    } catch (e) {
      return left('Failed to update user role: ${e.toString()}');
    }
  }

  /// Extract user role from Firebase custom claims
  UserRole _getUserRoleFromClaims(user) {
    final claims = user.getIdTokenResult(true);
    if (claims.claims != null) {
      final roleClaim = claims.claims!['role'] as String?;
      return UserRole.values.firstWhere(
        (role) => role.name == role,
        orElse: () => UserRole.student,
      );
    }
    return UserRole.student;
  }
}
