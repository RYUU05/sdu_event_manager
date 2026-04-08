import 'package:event_manager/features/home/domain/repositories/home_repository.dart';
import 'package:event_manager/features/home/domain/usecases/get_popular_clubs.dart';
import 'package:event_manager/features/home/domain/usecases/get_upcoming_events.dart';
import 'package:event_manager/features/home/domain/usecases/register_for_event.dart'
    as usecases;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUpcomingEvents getUpcomingEvents;
  final GetPopularClubs getPopularClubs;
  final usecases.RegisterForEvent registerForEvent;
  final HomeRepository homeRepository;

  HomeBloc({
    required this.getUpcomingEvents,
    required this.getPopularClubs,
    required this.registerForEvent,
    required this.homeRepository,
  }) : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<RegisterForEvent>(_onRegisterForEvent);
    on<UnregisterFromEvent>(_onUnregisterFromEvent);
    on<FollowClub>(_onFollowClub);
    on<UnfollowClub>(_onUnfollowClub);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final upcomingEventsResult = await getUpcomingEvents();
    final popularClubsResult = await getPopularClubs();

    return upcomingEventsResult.fold(
      (error) => emit(HomeError(error)),
      (upcomingEvents) => popularClubsResult.fold(
        (error) => emit(HomeError(error)),
        (popularClubs) {
          if (upcomingEvents.isEmpty && popularClubs.isEmpty) {
            emit(const HomeEmpty());
          } else {
            emit(
              HomeLoaded(
                upcomingEvents: upcomingEvents,
                popularClubs: popularClubs,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(
        HomeRefreshing(
          upcomingEvents: currentState.upcomingEvents,
          popularClubs: currentState.popularClubs,
        ),
      );
    } else {
      emit(const HomeLoading());
    }

    final upcomingEventsResult = await getUpcomingEvents();
    final popularClubsResult = await getPopularClubs();

    return upcomingEventsResult.fold(
      (error) => emit(HomeError(error)),
      (upcomingEvents) => popularClubsResult.fold(
        (error) => emit(HomeError(error)),
        (popularClubs) {
          if (upcomingEvents.isEmpty && popularClubs.isEmpty) {
            emit(const HomeEmpty());
          } else {
            emit(
              HomeLoaded(
                upcomingEvents: upcomingEvents,
                popularClubs: popularClubs,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _onRegisterForEvent(
    RegisterForEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      final updatedEvents = currentState.upcomingEvents.map((e) {
        if (e.id == event.eventId) {
          return e.copyWith(
            isRegistered: true,
            currentParticipants: (e.currentParticipants ?? 0) + 1,
          );
        }
        return e;
      }).toList();

      emit(currentState.copyWith(upcomingEvents: updatedEvents));

      final result = await registerForEvent(event.eventId);

      result.fold(
        (error) {
          emit(HomeError(error));
        },
        (_) {
          emit(currentState.copyWith(upcomingEvents: updatedEvents));
        },
      );
    }
  }

  Future<void> _onUnregisterFromEvent(
    UnregisterFromEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      final updatedEvents = currentState.upcomingEvents.map((e) {
        if (e.id == event.eventId) {
          return e.copyWith(
            isRegistered: false,
            currentParticipants: (e.currentParticipants ?? 1) - 1,
          );
        }
        return e;
      }).toList();

      emit(currentState.copyWith(upcomingEvents: updatedEvents));

      final result = await homeRepository.unregisterFromEvent(event.eventId);

      result.fold(
        (error) {
          emit(HomeError(error));
        },
        (_) {
          emit(currentState.copyWith(upcomingEvents: updatedEvents));
        },
      );
    }
  }

  Future<void> _onFollowClub(FollowClub event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      final updatedClubs = currentState.popularClubs.map((c) {
        if (c.id == event.clubId) {
          return c.copyWith(
            isFollowed: true,
            memberCount: (c.memberCount ?? 0) + 1,
          );
        }
        return c;
      }).toList();

      emit(currentState.copyWith(popularClubs: updatedClubs));

      final result = await homeRepository.followClub(event.clubId);

      result.fold(
        (error) {
          emit(HomeError(error));
        },
        (_) {
          emit(currentState.copyWith(popularClubs: updatedClubs));
        },
      );
    }
  }

  Future<void> _onUnfollowClub(
    UnfollowClub event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      final updatedClubs = currentState.popularClubs.map((c) {
        if (c.id == event.clubId) {
          return c.copyWith(
            isFollowed: false,
            memberCount: (c.memberCount ?? 1) - 1,
          );
        }
        return c;
      }).toList();

      emit(currentState.copyWith(popularClubs: updatedClubs));

      final result = await homeRepository.unfollowClub(event.clubId);

      result.fold(
        (error) {
          emit(HomeError(error));
        },
        (_) {
          emit(currentState.copyWith(popularClubs: updatedClubs));
        },
      );
    }
  }
}
