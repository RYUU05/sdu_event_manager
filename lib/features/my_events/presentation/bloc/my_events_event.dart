abstract class MyEventsEvent {}

class LoadMyEvents extends MyEventsEvent {}

class LoadClubEvents extends MyEventsEvent {
  final String clubId;
  LoadClubEvents(this.clubId);
}

class RemoveMyEvent extends MyEventsEvent {
  final String eventId;
  RemoveMyEvent(this.eventId);
}
