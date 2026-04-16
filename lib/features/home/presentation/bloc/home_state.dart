import '../../domain/entities/event.dart';
import '../../domain/entities/club.dart';

abstract class HomeState {
  const HomeState();
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
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}

class HomeEmpty extends HomeState {
  const HomeEmpty();
}
