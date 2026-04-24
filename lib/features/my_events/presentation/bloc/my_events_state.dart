import 'package:event_manager/features/home/domain/entities/event.dart';

abstract class MyEventsState {}

class MyEventsInitial extends MyEventsState {}

class MyEventsLoading extends MyEventsState {}

class MyEventsLoaded extends MyEventsState {
  final List<Event> events;
  MyEventsLoaded(this.events);
}

class MyEventsError extends MyEventsState {
  final String message;
  MyEventsError(this.message);
}
