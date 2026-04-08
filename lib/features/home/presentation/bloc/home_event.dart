import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

class RegisterForEvent extends HomeEvent {
  final String eventId;

  const RegisterForEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class UnregisterFromEvent extends HomeEvent {
  final String eventId;

  const UnregisterFromEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class FollowClub extends HomeEvent {
  final String clubId;

  const FollowClub(this.clubId);

  @override
  List<Object?> get props => [clubId];
}

class UnfollowClub extends HomeEvent {
  final String clubId;

  const UnfollowClub(this.clubId);

  @override
  List<Object?> get props => [clubId];
}
