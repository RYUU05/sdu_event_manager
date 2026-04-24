import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_manager/features/home/domain/repositories/home_repository.dart';
import 'my_events_event.dart';
import 'my_events_state.dart';

class MyEventsBloc extends Bloc<MyEventsEvent, MyEventsState> {
  final HomeRepository repository;

  MyEventsBloc(this.repository) : super(MyEventsInitial()) {
    on<LoadMyEvents>(_onLoad);
    on<RemoveMyEvent>(_onRemove);
  }

  Future<void> _onLoad(
    LoadMyEvents event,
    Emitter<MyEventsState> emit,
  ) async {
    emit(MyEventsLoading());
    try {
      final events = await repository.getMyEvents();
      emit(MyEventsLoaded(events));
    } catch (e) {
      emit(MyEventsError(e.toString()));
    }
  }

  Future<void> _onRemove(
    RemoveMyEvent event,
    Emitter<MyEventsState> emit,
  ) async {
    try {
      await repository.unregisterFromEvent(event.eventId);
      // Reload after removal
      final events = await repository.getMyEvents();
      emit(MyEventsLoaded(events));
    } catch (e) {
      emit(MyEventsError(e.toString()));
    }
  }
}
