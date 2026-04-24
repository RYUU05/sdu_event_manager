import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    debugPrint('HomeBloc: Loading data...');

    try {
      final events = await homeRepository.getAllEvents();
      debugPrint('HomeBloc: Loaded ${events.length} events');
      final clubs = await homeRepository.getPopularClubs();
      debugPrint('HomeBloc: Loaded ${clubs.length} clubs');

      if (events.isEmpty && clubs.isEmpty) {
        debugPrint('HomeBloc: Empty data');
        emit(HomeEmpty());
      } else {
        debugPrint('HomeBloc: Emitting loaded state');
        emit(HomeLoaded(upcomingEvents: events, popularClubs: clubs));
      }
    } catch (e) {
      debugPrint('HomeBloc: Error - $e');
      emit(HomeError(e.toString()));
    }
  }
}
