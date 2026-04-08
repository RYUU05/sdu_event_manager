import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';
import 'package:event_manager/features/home/domain/entities/club.dart';
import 'package:event_manager/features/home/domain/repositories/home_repository.dart';
import '../datasources/firebase_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseDataSource dataSource;
  final FirebaseAuth auth;

  HomeRepositoryImpl({required this.dataSource, required this.auth});

  @override
  Future<Either<String, List<Event>>> getUpcomingEvents() async {
    try {
      final events = await dataSource.getUpcomingEvents();
      return Right(events);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Club>>> getPopularClubs() async {
    try {
      final clubs = await dataSource.getPopularClubs();
      return Right(clubs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> registerForEvent(String eventId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        return const Left('User not authenticated');
      }

      await dataSource.registerForEvent(eventId, userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> unregisterFromEvent(String eventId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        return const Left('User not authenticated');
      }

      await dataSource.unregisterFromEvent(eventId, userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Event>> getEventDetails(String eventId) async {
    try {
      final event = await dataSource.getEventDetails(eventId);
      return Right(event);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Event>>> getEventsByClub(String clubId) async {
    try {
      final events = await dataSource.getEventsByClub(clubId);
      return Right(events);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> followClub(String clubId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        return const Left('User not authenticated');
      }

      await dataSource.followClub(clubId, userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> unfollowClub(String clubId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        return const Left('User not authenticated');
      }

      await dataSource.unfollowClub(clubId, userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
