import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/features/home/data/models/event_model.dart';
import 'package:event_manager/features/home/data/models/club_model.dart';

abstract class FirebaseDataSource {
  Future<List<EventModel>> getAllEvents();
  Future<List<EventModel>> getUpcomingEvents();
  Future<List<ClubModel>> getPopularClubs();
  Future<void> registerForEvent(String eventId, String userId);
  Future<void> unregisterFromEvent(String eventId, String userId);
  Future<EventModel> getEventDetails(String eventId);
  Future<List<EventModel>> getEventsByClub(String clubId);
  Future<void> followClub(String clubId, String userId);
  Future<void> unfollowClub(String clubId, String userId);
}

class FirebaseDataSourceImpl implements FirebaseDataSource {
  final FirebaseFirestore firestore;
  final String userId;

  FirebaseDataSourceImpl({required this.firestore, required this.userId});

  @override
  Future<List<EventModel>> getAllEvents() async {
    try {
      final snapshot = await firestore.collection('events').get();
      return snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all events: $e');
    }
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      // Simple query without orderBy to avoid index requirement
      final snapshot = await firestore.collection('events').limit(10).get();

      return snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming events: $e');
    }
  }

  @override
  Future<List<ClubModel>> getPopularClubs() async {
    try {
      // Simple query without orderBy to avoid index requirement
      final snapshot = await firestore.collection('clubs').limit(10).get();

      return snapshot.docs
          .map((doc) => ClubModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular clubs: $e');
    }
  }

  @override
  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      final batch = firestore.batch();

      final eventRef = firestore.collection('events').doc(eventId);
      final registrationRef = firestore
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .doc(userId);

      batch.set(registrationRef, {
        'userId': userId,
        'registeredAt': Timestamp.now(),
      });

      batch.update(eventRef, {'currentParticipants': FieldValue.increment(1)});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to register for event: $e');
    }
  }

  @override
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    try {
      final batch = firestore.batch();

      final eventRef = firestore.collection('events').doc(eventId);
      final registrationRef = firestore
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .doc(userId);

      batch.delete(registrationRef);

      batch.update(eventRef, {'currentParticipants': FieldValue.increment(-1)});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unregister from event: $e');
    }
  }

  @override
  Future<EventModel> getEventDetails(String eventId) async {
    try {
      final doc = await firestore.collection('events').doc(eventId).get();

      if (!doc.exists) {
        throw Exception('Event not found');
      }

      return EventModel.fromJson(doc.data()!..['id'] = doc.id);
    } catch (e) {
      throw Exception('Failed to fetch event details: $e');
    }
  }

  @override
  Future<List<EventModel>> getEventsByClub(String clubId) async {
    try {
      final snapshot = await firestore
          .collection('events')
          .where('clubId', isEqualTo: clubId)
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events by club: $e');
    }
  }

  @override
  Future<void> followClub(String clubId, String userId) async {
    try {
      final batch = firestore.batch();

      final clubRef = firestore.collection('clubs').doc(clubId);
      final followRef = firestore
          .collection('clubs')
          .doc(clubId)
          .collection('followers')
          .doc(userId);

      batch.set(followRef, {'userId': userId, 'followedAt': Timestamp.now()});

      batch.update(clubRef, {'memberCount': FieldValue.increment(1)});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to follow club: $e');
    }
  }

  @override
  Future<void> unfollowClub(String clubId, String userId) async {
    try {
      final batch = firestore.batch();

      final clubRef = firestore.collection('clubs').doc(clubId);
      final followRef = firestore
          .collection('clubs')
          .doc(clubId)
          .collection('followers')
          .doc(userId);

      batch.delete(followRef);

      batch.update(clubRef, {'memberCount': FieldValue.increment(-1)});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unfollow club: $e');
    }
  }
}
