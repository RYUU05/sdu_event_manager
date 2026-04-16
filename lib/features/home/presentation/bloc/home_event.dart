abstract class HomeEvent {
  const HomeEvent();
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}
