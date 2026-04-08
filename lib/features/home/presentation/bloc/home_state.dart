import 'package:equatable/equatable.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';
import 'package:event_manager/features/home/domain/entities/club.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Event> upcomingEvents;
  final List<Club> popularClubs;

  const HomeLoaded({required this.upcomingEvents, required this.popularClubs});

  HomeLoaded copyWith({List<Event>? upcomingEvents, List<Club>? popularClubs}) {
    return HomeLoaded(
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      popularClubs: popularClubs ?? this.popularClubs,
    );
  }

  @override
  List<Object?> get props => [upcomingEvents, popularClubs];
}

class HomeRefreshing extends HomeState {
  final List<Event> upcomingEvents;
  final List<Club> popularClubs;

  const HomeRefreshing({
    required this.upcomingEvents,
    required this.popularClubs,
  });

  @override
  List<Object?> get props => [upcomingEvents, popularClubs];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeEmpty extends HomeState {
  const HomeEmpty();
}
