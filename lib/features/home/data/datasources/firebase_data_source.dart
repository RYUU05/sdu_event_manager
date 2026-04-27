import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  Future<List<EventModel>> getMyEvents(String userId);
  Stream<bool> isRegisteredForEvent(String eventId, String userId);
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
    final eventRef = firestore.collection('events').doc(eventId);
    final userRef = firestore.collection('users').doc(userId);

    // 1. Add event to user's registeredEvents array
    try {
      await userRef.set({
        'registeredEvents': FieldValue.arrayUnion([eventId])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Update user document failed: $e');
    }

    // 2. Update participant counts and add user to event's participants array
    try {
      await eventRef.update({
        'currentParticipants': FieldValue.increment(1),
        'participants': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Update event document failed (check Firestore Rules): $e');
      throw Exception('Ошибка доступа к Firebase. Обновите Firestore Rules!');
    }
  }

  @override
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    final eventRef = firestore.collection('events').doc(eventId);
    final userRef = firestore.collection('users').doc(userId);

    // 1. Remove from user's registeredEvents array
    try {
      await userRef.set({
        'registeredEvents': FieldValue.arrayRemove([eventId])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Update user document failed: $e');
    }

    // 2. Update participant counts and remove user from event's participants array
    try {
      await eventRef.update({
        'currentParticipants': FieldValue.increment(-1),
        'participants': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      debugPrint('Update event document failed (check Firestore Rules): $e');
      throw Exception('Ошибка доступа к Firebase. Обновите Firestore Rules!');
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
          .get();

      var events = snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()..['id'] = doc.id))
          .where((event) => event.isActive)
          .toList();
          
      events.sort((a, b) => a.date.compareTo(b.date));

      return events;
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

  @override
  Future<List<EventModel>> getMyEvents(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final data = userDoc.data() ?? {};
      final List<dynamic> registeredEvents = data['registeredEvents'] ?? [];

      if (registeredEvents.isEmpty) return [];

      final List<EventModel> myEvents = [];
      for (final docId in registeredEvents) {
        final eventDoc =
            await firestore.collection('events').doc(docId as String).get();
        if (eventDoc.exists) {
          myEvents.add(
            EventModel.fromJson(eventDoc.data()!..['id'] = eventDoc.id),
          );
        }
      }
      return myEvents;
    } catch (e) {
      throw Exception('Failed to fetch my events: $e');
    }
  }

  @override
  Stream<bool> isRegisteredForEvent(String eventId, String userId) {
    return firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return false;
      final data = doc.data() ?? {};
      final List<dynamic> registeredEvents = data['registeredEvents'] ?? [];
      return registeredEvents.contains(eventId);
    });
  }
}
