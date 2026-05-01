import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_manager/features/home/domain/repositories/home_repository.dart';
import 'dart:developer' as developer;
import 'my_events_event.dart';
import 'my_events_state.dart';

class MyEventsBloc extends Bloc<MyEventsEvent, MyEventsState> {
  final HomeRepository repository;

  MyEventsBloc(this.repository) : super(MyEventsInitial()) {
    on<LoadMyEvents>(_onLoad);
    on<LoadClubEvents>(_onLoadClub);
    on<RemoveMyEvent>(_onRemove);
  }

  Future<void> _onLoad(
    LoadMyEvents event,
    Emitter<MyEventsState> emit,
  ) async {
    developer.log('Request start: LoadMyEvents', name: 'MyEventsBloc');
    emit(MyEventsLoading());
    try {
      final events = await repository.getMyEvents();
      developer.log('Success: Loaded ${events.length} my events', name: 'MyEventsBloc');
      emit(MyEventsLoaded(events));
    } catch (e) {
      developer.log('Failure: Failed to load my events', error: e, name: 'MyEventsBloc');
      emit(MyEventsError(e.toString()));
    }
  }

  Future<void> _onLoadClub(
    LoadClubEvents event,
    Emitter<MyEventsState> emit,
  ) async {
    developer.log('Request start: LoadClubEvents for club ${event.clubId}', name: 'MyEventsBloc');
    emit(MyEventsLoading());
    try {
      final events = await repository.getEventsByClub(event.clubId);
      developer.log('Success: Loaded ${events.length} club events', name: 'MyEventsBloc');
      emit(MyEventsLoaded(events));
    } catch (e) {
      developer.log('Failure: Failed to load club events', error: e, name: 'MyEventsBloc');
      emit(MyEventsError(e.toString()));
    }
  }

  Future<void> _onRemove(
    RemoveMyEvent event,
    Emitter<MyEventsState> emit,
  ) async {
    if (event.eventId.isEmpty) {
      developer.log('Failure: Invalid input, eventId is empty', name: 'MyEventsBloc');
      emit(MyEventsError('Invalid event ID'));
      return;
    }

    developer.log('Request start: RemoveMyEvent for event ${event.eventId}', name: 'MyEventsBloc');
    try {
      await repository.unregisterFromEvent(event.eventId);
      final events = await repository.getMyEvents();
      developer.log('Success: Removed event ${event.eventId}', name: 'MyEventsBloc');
      emit(MyEventsLoaded(events));
    } catch (e) {
      developer.log('Failure: Failed to remove event', error: e, name: 'MyEventsBloc');
      emit(MyEventsError(e.toString()));
    }
  }
}
