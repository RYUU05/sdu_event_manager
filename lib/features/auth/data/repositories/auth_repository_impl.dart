import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) return null;

      final doc = await _db.collection('users').doc(result.user!.uid).get();
      final roleStr = doc.data()?['role'] ?? 'student';
      final role = roleStr == 'club' ? UserRole.club : UserRole.student;

      return UserEntity(
        id: result.user!.uid,
        email: email,
        name: doc.data()?['name'],
        role: role,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity?> register(
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

      if (result.user == null) return null;

      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'name': name,
        'role': role == UserRole.club ? 'club' : 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserEntity(
        id: result.user!.uid,
        email: email,
        name: name,
        role: role,
      );
    } catch (e) {
      return null;
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
      final roleStr = doc.data()?['role'] ?? 'student';
      final role = roleStr == 'club' ? UserRole.club : UserRole.student;

      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: doc.data()?['name'],
        role: role,
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
        final roleStr = doc.data()?['role'] ?? 'student';
        final role = roleStr == 'club' ? UserRole.club : UserRole.student;

        return UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: doc.data()?['name'],
          role: role,
        );
      } catch (e) {
        return null;
      }
    });
  }
}
