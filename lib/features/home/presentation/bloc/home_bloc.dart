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

    try {
      final events = await homeRepository.getUpcomingEvents();
      final clubs = await homeRepository.getPopularClubs();

      if (events.isEmpty && clubs.isEmpty) {
        emit(HomeEmpty());
      } else {
        emit(HomeLoaded(upcomingEvents: events, popularClubs: clubs));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
