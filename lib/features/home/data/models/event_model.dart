import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.date,
    required super.registrationDeadline,
    required super.location,
    required super.maxParticipants,
    required super.currentParticipants,
    required super.clubId,
    required super.clubName,
    required super.tags,
    required super.isRegistered,
    required super.isActive,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      registrationDeadline: DateTime.parse(
        json['registrationDeadline'] ?? DateTime.now().toIso8601String(),
      ),
      location: json['location'] ?? '',
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      clubId: json['clubId'] ?? '',
      clubName: json['clubName'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isRegistered: json['isRegistered'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  factory EventModel.fromEntity(Event entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      date: entity.date,
      registrationDeadline: entity.registrationDeadline,
      location: entity.location,
      maxParticipants: entity.maxParticipants,
      currentParticipants: entity.currentParticipants,
      clubId: entity.clubId,
      clubName: entity.clubName,
      tags: entity.tags,
      isRegistered: entity.isRegistered,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'location': location,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'clubId': clubId,
      'clubName': clubName,
      'tags': tags,
      'isRegistered': isRegistered,
      'isActive': isActive,
    };
  }
}
