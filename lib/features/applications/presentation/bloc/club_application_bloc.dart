import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/club_application.dart';
import '../../domain/repositories/application_repository.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class ClubApplicationEvent {}

/// Студент отправляет форму заявки
class SubmitApplicationEvent extends ClubApplicationEvent {
  final String userId;
  final String userName;
  final String clubName;
  final String description;
  final String category;

  SubmitApplicationEvent({
    required this.userId,
    required this.userName,
    required this.clubName,
    required this.description,
    required this.category,
  });
}

/// Загрузить заявки текущего студента
class LoadMyApplicationsEvent extends ClubApplicationEvent {
  final String userId;
  LoadMyApplicationsEvent(this.userId);
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class ClubApplicationState {}

class ApplicationInitial extends ClubApplicationState {}

class ApplicationLoading extends ClubApplicationState {}

class ApplicationSuccess extends ClubApplicationState {}

class ApplicationError extends ClubApplicationState {
  final String message;
  ApplicationError(this.message);
}

class MyApplicationsLoaded extends ClubApplicationState {
  final List<ClubApplication> applications;
  MyApplicationsLoaded(this.applications);
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class ClubApplicationBloc
    extends Bloc<ClubApplicationEvent, ClubApplicationState> {
  final ApplicationRepository _repo;

  ClubApplicationBloc(this._repo) : super(ApplicationInitial()) {
    on<SubmitApplicationEvent>(_onSubmit);
    on<LoadMyApplicationsEvent>(_onLoadMy);
  }

  Future<void> _onSubmit(
    SubmitApplicationEvent event,
    Emitter<ClubApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    try {
      await _repo.submitApplication(
        userId: event.userId,
        userName: event.userName,
        clubName: event.clubName,
        description: event.description,
        category: event.category,
      );
      emit(ApplicationSuccess());
    } catch (e) {
      emit(ApplicationError('Ошибка при отправке заявки: $e'));
    }
  }

  Future<void> _onLoadMy(
    LoadMyApplicationsEvent event,
    Emitter<ClubApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    try {
      final list = await _repo.getMyApplications(event.userId);
      emit(MyApplicationsLoaded(list));
    } catch (e) {
      emit(ApplicationError('Ошибка при загрузке заявок: $e'));
    }
  }
}
