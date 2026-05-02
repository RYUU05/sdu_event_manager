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
  Stream<bool> isFollowingClub(String clubId, String userId);
  Future<void> deleteEvent(String eventId);
}

/// Helper to safely add 'id' to a Firestore map without mutating original.
Map<String, dynamic> _withId(Map<String, dynamic> data, String id) {
  return {...data, 'id': id};
}

class FirebaseDataSourceImpl implements FirebaseDataSource {
  final FirebaseFirestore firestore;
  final String userId;

  FirebaseDataSourceImpl({required this.firestore, required this.userId});

  @override
  Future<List<EventModel>> getAllEvents() async {
    try {
      final snapshot = await firestore
          .collection('events')
          .orderBy('dateTime', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => EventModel.fromJson(_withId(doc.data(), doc.id)))
          .toList();
    } catch (e) {
      // Fallback without ordering if index not set up
      try {
        final snapshot = await firestore.collection('events').get();
        return snapshot.docs
            .map((doc) => EventModel.fromJson(_withId(doc.data(), doc.id)))
            .toList();
      } catch (e2) {
        throw Exception('Failed to fetch all events: $e2');
      }
    }
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final snapshot = await firestore.collection('events').limit(10).get();
      return snapshot.docs
          .map((doc) => EventModel.fromJson(_withId(doc.data(), doc.id)))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming events: $e');
    }
  }

  @override
  Future<List<ClubModel>> getPopularClubs() async {
    try {
      final snapshot = await firestore.collection('clubs').limit(10).get();
      return snapshot.docs
          .map((doc) => ClubModel.fromJson(_withId(doc.data(), doc.id)))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular clubs: $e');
    }
  }

  @override
  Future<void> registerForEvent(String eventId, String userId) async {
    final eventRef = firestore.collection('events').doc(eventId);
    final userRef = firestore.collection('users').doc(userId);

    try {
      await userRef.set(
        {'registeredEvents': FieldValue.arrayUnion([eventId])},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Не удалось обновить данные пользователя: $e');
    }

    try {
      await eventRef.update({
        'currentParticipants': FieldValue.increment(1),
        'participants': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Update event failed (check Firestore Rules): $e');
      throw Exception('Ошибка доступа к Firebase. Проверьте Firestore Rules!');
    }
  }

  @override
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    final eventRef = firestore.collection('events').doc(eventId);
    final userRef = firestore.collection('users').doc(userId);

    try {
      await userRef.set(
        {'registeredEvents': FieldValue.arrayRemove([eventId])},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Не удалось обновить данные пользователя: $e');
    }

    try {
      await eventRef.update({
        'currentParticipants': FieldValue.increment(-1),
        'participants': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      debugPrint('Update event failed (check Firestore Rules): $e');
      throw Exception('Ошибка доступа к Firebase. Проверьте Firestore Rules!');
    }
  }

  @override
  Future<EventModel> getEventDetails(String eventId) async {
    try {
      final doc = await firestore.collection('events').doc(eventId).get();
      if (!doc.exists) throw Exception('Ивент не найден');
      return EventModel.fromJson(_withId(doc.data()!, doc.id));
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

      final events = snapshot.docs
          .map((doc) => EventModel.fromJson(_withId(doc.data(), doc.id)))
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

      // Also store in user doc
      final userRef = firestore.collection('users').doc(userId);
      batch.set(
        userRef,
        {'followedClubs': FieldValue.arrayUnion([clubId])},
        SetOptions(merge: true),
      );

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

      final userRef = firestore.collection('users').doc(userId);
      batch.set(
        userRef,
        {'followedClubs': FieldValue.arrayRemove([clubId])},
        SetOptions(merge: true),
      );

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
      final List<String> registeredEvents =
          List<String>.from(data['registeredEvents'] ?? []);

      if (registeredEvents.isEmpty) return [];

      // Fix N+1: parallel fetch with Future.wait
      final futures = registeredEvents
          .map((docId) => firestore.collection('events').doc(docId).get());
      final docs = await Future.wait(futures);

      return docs
          .where((doc) => doc.exists)
          .map((doc) => EventModel.fromJson(_withId(doc.data()!, doc.id)))
          .toList();
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

  @override
  Stream<bool> isFollowingClub(String clubId, String userId) {
    return firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return false;
      final data = doc.data() ?? {};
      final List<dynamic> followedClubs = data['followedClubs'] ?? [];
      return followedClubs.contains(clubId);
    });
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}
