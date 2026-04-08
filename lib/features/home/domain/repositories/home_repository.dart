import 'package:dartz/dartz.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';
import 'package:event_manager/features/home/domain/entities/club.dart';

abstract class HomeRepository {
  Future<Either<String, List<Event>>> getUpcomingEvents();
  Future<Either<String, List<Club>>> getPopularClubs();
  Future<Either<String, void>> registerForEvent(String eventId);
  Future<Either<String, void>> unregisterFromEvent(String eventId);
  Future<Either<String, Event>> getEventDetails(String eventId);
  Future<Either<String, List<Event>>> getEventsByClub(String clubId);
  Future<Either<String, void>> followClub(String clubId);
  Future<Either<String, void>> unfollowClub(String clubId);
}
