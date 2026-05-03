import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/club.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../unibuddy/data/unibuddy_api.dart';
import '../datasources/firebase_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseDataSource dataSource;
  final FirebaseAuth auth;

  HomeRepositoryImpl({required this.dataSource, required this.auth});

  @override
  Future<List<Event>> getAllEvents() async {
    return await dataSource.getAllEvents();
  }

  @override
  Future<List<Event>> getUpcomingEvents() async {
    return await dataSource.getUpcomingEvents();
  }

  @override
  Future<List<Club>> getPopularClubs() async {
    return await dataSource.getPopularClubs();
  }

  @override
  Future<void> registerForEvent(String eventId) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');
    await dataSource.registerForEvent(eventId, userId);
  }

  @override
  Future<void> unregisterFromEvent(String eventId) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');
    await dataSource.unregisterFromEvent(eventId, userId);
  }

  @override
  Future<Event?> getEventDetails(String eventId) async {
    return await dataSource.getEventDetails(eventId);
  }

  @override
  Future<List<Event>> getEventsByClub(String clubId) async {
    return await dataSource.getEventsByClub(clubId);
  }

  @override
  Future<void> followClub(String clubId) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');
    await dataSource.followClub(clubId, userId);
  }

  @override
  Future<void> unfollowClub(String clubId) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');
    await dataSource.unfollowClub(clubId, userId);
  }

  @override
  Future<List<Event>> getMyEvents() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');
    return await dataSource.getMyEvents(userId);
  }

  @override
  Stream<bool> isRegisteredForEvent(String eventId) {
    final userId = auth.currentUser?.uid;
    if (userId == null) return Stream.value(false);
    return dataSource.isRegisteredForEvent(eventId, userId);
  }

  @override
  Stream<bool> isFollowingClub(String clubId) {
    final userId = auth.currentUser?.uid;
    if (userId == null) return Stream.value(false);
    return dataSource.isFollowingClub(clubId, userId);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');
    await dataSource.deleteEvent(eventId);
    // Вызываем синхронизацию с Python-бэкендом
    try {
      await getIt<UniBuddyApi>().sync();
    } catch (e) {
      // Игнорируем ошибку синхронизации, чтобы не ломать UI
    }
  }
}
