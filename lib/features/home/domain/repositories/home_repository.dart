import '../entities/event.dart';
import '../entities/club.dart';

abstract class HomeRepository {
  Future<List<Event>> getAllEvents();
  Future<List<Event>> getUpcomingEvents();
  Future<List<Club>> getPopularClubs();
  Future<void> registerForEvent(String eventId);
  Future<void> unregisterFromEvent(String eventId);
  Future<Event?> getEventDetails(String eventId);
  Future<List<Event>> getEventsByClub(String clubId);
  Future<void> followClub(String clubId);
  Future<void> unfollowClub(String clubId);
  Future<List<Event>> getMyEvents();
  Stream<bool> isRegisteredForEvent(String eventId);
  Stream<bool> isFollowingClub(String clubId);
  Future<void> deleteEvent(String eventId);
}
