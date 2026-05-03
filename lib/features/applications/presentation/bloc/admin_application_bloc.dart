import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/club_application.dart';
import '../../domain/repositories/application_repository.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class AdminApplicationEvent {}

class ApproveApplicationEvent extends AdminApplicationEvent {
  final ClubApplication application;
  ApproveApplicationEvent(this.application);
}

class RejectApplicationEvent extends AdminApplicationEvent {
  final String applicationId;
  final String? note;
  RejectApplicationEvent(this.applicationId, {this.note});
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class AdminApplicationState {}

class AdminInitial extends AdminApplicationState {}

class AdminLoading extends AdminApplicationState {}

class AdminActionSuccess extends AdminApplicationState {
  final String message;
  AdminActionSuccess(this.message);
}

class AdminError extends AdminApplicationState {
  final String message;
  AdminError(this.message);
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class AdminApplicationBloc
    extends Bloc<AdminApplicationEvent, AdminApplicationState> {
  final ApplicationRepository _repo;

  AdminApplicationBloc(this._repo) : super(AdminInitial()) {
    on<ApproveApplicationEvent>(_onApprove);
    on<RejectApplicationEvent>(_onReject);
  }

  Future<void> _onApprove(
    ApproveApplicationEvent event,
    Emitter<AdminApplicationState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await _repo.approveApplication(event.application);
      emit(AdminActionSuccess('Клуб "${event.application.clubName}" одобрен!'));
    } catch (e) {
      emit(AdminError('Ошибка при одобрении: $e'));
    }
  }

  Future<void> _onReject(
    RejectApplicationEvent event,
    Emitter<AdminApplicationState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await _repo.rejectApplication(event.applicationId, note: event.note);
      emit(AdminActionSuccess('Заявка отклонена.'));
    } catch (e) {
      emit(AdminError('Ошибка при отклонении: $e'));
    }
  }
}
