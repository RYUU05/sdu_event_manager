import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:event_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;
  final AuthBloc authBloc;
  SettingsBloc(this.repository, this.authBloc) : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<LanguageEvent>(_onChangeLanguage);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await repository.getSettings();

      final authState = authBloc.state;
      String account = '';
      String role = '';
      if (authState is Authenticated) {
        account = authState.user.name;
        role = authState.user.role.toString();
        emit(SettingsLoaded(settings.language, account, role));
      }
    } catch (e) {
      emit(SettingsError('Failed to load settings'));
    }
  }

  Future<void> _onChangeLanguage(
    LanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final current = state as SettingsLoaded;
        emit(
          SettingsLoaded(
            event.languageCode,
            current.currentRole,
            current.currentUser,
          ),
        );
      }
    } catch (e) {
      emit(SettingsError('Failed to change lang'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<SettingsState> emit) async {
    try {
      await repository.logout();
    } catch (e) {
      emit(SettingsError('Failed to logout'));
    }
  }
}
