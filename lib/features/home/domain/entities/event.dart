class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final DateTime registrationDeadline;
  final String location;
  final int maxParticipants;
  final int currentParticipants;
  final String clubId;
  final String clubName;
  final List<String> tags;
  final bool isRegistered;
  final bool isActive;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.registrationDeadline,
    required this.location,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.clubId,
    required this.clubName,
    required this.tags,
    required this.isRegistered,
    required this.isActive,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? date,
    DateTime? registrationDeadline,
    String? location,
    int? maxParticipants,
    int? currentParticipants,
    String? clubId,
    String? clubName,
    List<String>? tags,
    bool? isRegistered,
    bool? isActive,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      location: location ?? this.location,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      tags: tags ?? this.tags,
      isRegistered: isRegistered ?? this.isRegistered,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isRegistrationOpen =>
      DateTime.now().isBefore(registrationDeadline) &&
      (maxParticipants == 0 || currentParticipants < maxParticipants);

  double get registrationPercentage =>
      maxParticipants > 0 ? currentParticipants / maxParticipants : 0.0;
}
