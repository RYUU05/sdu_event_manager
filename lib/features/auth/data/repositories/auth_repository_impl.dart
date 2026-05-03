import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/auth_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  static String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'invalid-email':
        return 'Некорректный email';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Неверный email или пароль';
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'operation-not-allowed':
        return 'Этот способ входа отключён';
      case 'network-request-failed':
        return 'Нет соединения с сетью';
      default:
        return e.message?.isNotEmpty == true
            ? e.message!
            : 'Ошибка авторизации (${e.code})';
    }
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        return const AuthFailure('Не удалось войти');
      }

      final doc = await _db.collection('users').doc(result.user!.uid).get();
      final data = doc.data();
      return AuthSuccess(
        UserEntity(
          id: result.user!.uid,
          email: email,
          name: data?['name'] ?? email,
          role: UserEntity.roleFromString(data?['role'] as String?),
          interests: UserEntity.interestsFromFirestore(data?['interests']),
          managedClubId: data?['managedClubId'] as String?,
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.code} - ${e.message}');
      return AuthFailure(_mapAuthException(e));
    } on FirebaseException catch (e) {
      debugPrint('Login Firestore error: ${e.code} - ${e.message}');
      return AuthFailure(
        e.message?.isNotEmpty == true
            ? e.message!
            : 'Ошибка при загрузке профиля',
      );
    } catch (e) {
      debugPrint('Login error: $e');
      return const AuthFailure('Ошибка сети. Проверьте подключение');
    }
  }

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        return const AuthFailure('Не удалось создать аккаунт');
      }

      final uid = result.user!.uid;

      // Регистрация всегда создаёт студента.
      // Стать club_admin можно только через заявку (одобряет super_admin).
      await _db.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'role': 'student',
        'interests': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthSuccess(
        UserEntity(
          id: uid,
          email: email,
          name: name,
          role: UserRole.student,
          interests: const [],
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Register error: ${e.code} - ${e.message}');
      return AuthFailure(_mapAuthException(e));
    } on FirebaseException catch (e) {
      debugPrint('Register Firestore error: ${e.code} - ${e.message}');
      return AuthFailure(
        e.message?.isNotEmpty == true
            ? e.message!
            : 'Ошибка при сохранении профиля',
      );
    } catch (e) {
      debugPrint('Register error: $e');
      return const AuthFailure('Ошибка сети. Проверьте подключение');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data();
      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: data?['name'] ?? user.email ?? '',
        role: UserEntity.roleFromString(data?['role'] as String?),
        interests: UserEntity.interestsFromFirestore(data?['interests']),
        managedClubId: data?['managedClubId'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> get user {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      try {
        final doc = await _db.collection('users').doc(user.uid).get();
        final data = doc.data();
        return UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: data?['name'] ?? user.email ?? '',
          role: UserEntity.roleFromString(data?['role'] as String?),
          interests: UserEntity.interestsFromFirestore(data?['interests']),
          managedClubId: data?['managedClubId'] as String?,
        );
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<UserEntity?> updateInterests(List<String> interests) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    await _db.collection('users').doc(user.uid).set(
          {'interests': interests},
          SetOptions(merge: true),
        );
    return getCurrentUser();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
