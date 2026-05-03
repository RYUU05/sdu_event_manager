import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Сервис In-App уведомлений.
///
/// Слушает коллекцию `club_applications` для конкретного userId.
/// Когда статус меняется на approved/rejected — показывает Dialog.
///
/// Как использовать:
///   InAppNotificationService.instance.init(userId, navigatorKey);
///
/// Вызывать init() в AuthBloc после успешного входа (в _onUserChanged).
class InAppNotificationService {
  InAppNotificationService._();
  static final instance = InAppNotificationService._();

  StreamSubscription? _sub;
  String? _currentUserId;

  // Ключ для доступа к контексту без BuildContext
  final navigatorKey = GlobalKey<NavigatorState>();

  /// Запускает слушатель для userId.
  /// Если уже запущен для того же userId — ничего не делает.
  void init(String userId) {
    if (_currentUserId == userId) return;
    dispose(); // остановить предыдущий

    _currentUserId = userId;

    _sub = FirebaseFirestore.instance
        .collection('club_applications')
        .where('userId', isEqualTo: userId)
        // Слушаем только свежие изменения (не старые approved/rejected)
        .where('status', whereIn: ['approved', 'rejected'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snap) {
      if (snap.docs.isEmpty) return;

      final doc = snap.docs.first;
      final data = doc.data();
      final status = data['status'] as String?;
      final clubName = data['clubName'] as String? ?? 'Клуб';

      // Проверяем, не показывали ли это уведомление уже
      final notified = data['notified'] as bool? ?? false;
      if (notified) return;

      // Помечаем как уведомлённое, чтобы не показывать повторно
      doc.reference.update({'notified': true});

      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      if (status == 'approved') {
        _showApprovedDialog(context, clubName);
      } else if (status == 'rejected') {
        final note = data['reviewNote'] as String?;
        _showRejectedDialog(context, clubName, note);
      }
    });
  }

  /// Остановить слушатель (при выходе из аккаунта)
  void dispose() {
    _sub?.cancel();
    _sub = null;
    _currentUserId = null;
  }

  // ─── Диалоги ────────────────────────────────────────────────────────────────

  void _showApprovedDialog(BuildContext context, String clubName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(
          Icons.celebration_outlined,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Заявка одобрена! 🎉'),
        content: Text(
          'Поздравляем! Ваш клуб "$clubName" создан. '
          'Теперь вы можете создавать события. '
          'Перезайдите в приложение, чтобы роль обновилась.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Отлично!'),
          ),
        ],
      ),
    );
  }

  void _showRejectedDialog(
      BuildContext context, String clubName, String? note) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(
          Icons.info_outline,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('Заявка отклонена'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ваша заявка на клуб "$clubName" была отклонена.'),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Причина:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(note, style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 8),
            const Text('Вы можете подать новую заявку.'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
