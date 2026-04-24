abstract class MyEventsEvent {}

class LoadMyEvents extends MyEventsEvent {}

class RemoveMyEvent extends MyEventsEvent {
  final String eventId;
  RemoveMyEvent(this.eventId);
}
