import '../entities/club_application.dart';

abstract class ApplicationRepository {
  /// Студент подаёт заявку
  Future<void> submitApplication({
    required String userId,
    required String userName,
    required String clubName,
    required String description,
    required String category,
  });

  /// Список заявок текущего студента (для MyApplicationsPage)
  Future<List<ClubApplication>> getMyApplications(String userId);

  /// Стрим всех pending-заявок (для AdminApplicationsPage, StreamBuilder)
  Stream<List<ClubApplication>> watchPendingApplications();

  /// Одобрить: атомарная транзакция — заявка + создание clubs + обновление users
  Future<void> approveApplication(ClubApplication application);

  /// Отклонить: просто меняем статус + опциональная пометка
  Future<void> rejectApplication(String applicationId, {String? note});
}
