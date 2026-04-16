import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_popular_clubs.dart';
import '../../domain/usecases/get_upcoming_events.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUpcomingEvents getUpcomingEvents;
  final GetPopularClubs getPopularClubs;
  final HomeRepository homeRepository;

  HomeBloc({
    required this.getUpcomingEvents,
    required this.getPopularClubs,
    required this.homeRepository,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final eventsResult = await getUpcomingEvents();
      final clubsResult = await getPopularClubs();

      eventsResult.fold(
        (error) => emit(HomeError(error)),
        (events) =>
            clubsResult.fold((error) => emit(HomeError(error)), (clubs) {
              if (events.isEmpty && clubs.isEmpty) {
                emit(HomeEmpty());
              } else {
                emit(HomeLoaded(upcomingEvents: events, popularClubs: clubs));
              }
            }),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
