import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/entities/club_application.dart';
import '../domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final FirebaseFirestore _db;

  ApplicationRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ─── Submit (студент подаёт заявку) ────────────────────────────────────────

  @override
  Future<void> submitApplication({
    required String userId,
    required String userName,
    required String clubName,
    required String description,
    required String category,
  }) async {
    await _db.collection('club_applications').add({
      'userId': userId,
      'userName': userName,
      'clubName': clubName,
      'description': description,
      'category': category,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Мои заявки (студент) ───────────────────────────────────────────────────

  @override
  Future<List<ClubApplication>> getMyApplications(String userId) async {
    final snap = await _db
        .collection('club_applications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(ClubApplication.fromFirestore).toList();
  }

  // ─── Стрим pending-заявок (admin) ──────────────────────────────────────────

  @override
  Stream<List<ClubApplication>> watchPendingApplications() {
    return _db
        .collection('club_applications')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(ClubApplication.fromFirestore).toList());
  }

  // ─── Approve — атомарная транзакция ────────────────────────────────────────
  //
  // Три действия в одной транзакции:
  //   1. club_applications/{id}  → status: approved
  //   2. clubs/{newId}           → новый документ клуба
  //   3. users/{userId}          → role: club_admin, managedClubId: newId

  @override
  Future<void> approveApplication(ClubApplication application) async {
    // Заранее создаём ref для нового клуба (чтобы знать ID внутри транзакции)
    final newClubRef = _db.collection('clubs').doc();

    await _db.runTransaction((tx) async {
      final appRef =
          _db.collection('club_applications').doc(application.id);
      final userRef = _db.collection('users').doc(application.userId);

      // 1. Статус заявки → approved
      tx.update(appRef, {'status': 'approved'});

      // 2. Создаём клуб
      tx.set(newClubRef, {
        'name': application.clubName,
        'description': application.description,
        'category': application.category,
        'imageUrl': '',
        'memberCount': 0,
        'rating': 0.0,
        'tags': <String>[],
        'ownerId': application.userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Обновляем пользователя
      tx.update(userRef, {
        'role': 'club_admin',
        'managedClubId': newClubRef.id,
      });
    });

    debugPrint('✅ Approved: club ${newClubRef.id} created for ${application.userId}');
  }

  // ─── Reject ─────────────────────────────────────────────────────────────────

  @override
  Future<void> rejectApplication(String applicationId, {String? note}) async {
    await _db.collection('club_applications').doc(applicationId).update({
      'status': 'rejected',
      if (note != null && note.isNotEmpty) 'reviewNote': note,
    });
  }
}
