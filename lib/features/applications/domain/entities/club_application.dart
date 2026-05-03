import 'package:cloud_firestore/cloud_firestore.dart';

/// Статус заявки на создание клуба
enum ApplicationStatus { pending, approved, rejected }

/// Доменная модель заявки
class ClubApplication {
  final String id;
  final String userId;
  final String userName;
  final String clubName;
  final String description;
  final String category;
  final ApplicationStatus status;
  final DateTime createdAt;

  /// Необязательная пометка от модератора (причина отказа и т.п.)
  final String? reviewNote;

  const ClubApplication({
    required this.id,
    required this.userId,
    required this.userName,
    required this.clubName,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.reviewNote,
  });

  // ─── Helpers ────────────────────────────────────────────────────────────────

  static ApplicationStatus _statusFromString(String? s) {
    switch (s) {
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }

  // ─── Serialization ──────────────────────────────────────────────────────────

  factory ClubApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubApplication(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String? ?? '',
      clubName: data['clubName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewNote: data['reviewNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'clubName': clubName,
      'description': description,
      'category': category,
      'status': status.name, // 'pending' | 'approved' | 'rejected'
      'createdAt': FieldValue.serverTimestamp(),
      if (reviewNote != null) 'reviewNote': reviewNote,
    };
  }
}
