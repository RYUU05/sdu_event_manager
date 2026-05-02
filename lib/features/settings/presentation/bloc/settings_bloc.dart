import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
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
        role = authState.user.role == UserRole.club ? 'Клуб' : 'Студент';
      }

      // Always emit loaded — even if not authenticated
      emit(SettingsLoaded(settings.language, account, role));
    } catch (e) {
      emit(SettingsError('Не удалось загрузить настройки'));
    }
  }

  Future<void> _onChangeLanguage(
    LanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await repository.changeLang(event.languageCode);
      if (state is SettingsLoaded) {
        final current = state as SettingsLoaded;
        // Fixed: args were swapped before (currentRole was in currentUser position)
        emit(SettingsLoaded(
          event.languageCode,
          current.currentUser,
          current.currentRole,
        ));
      }
    } catch (e) {
      emit(SettingsError('Не удалось изменить язык'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<SettingsState> emit) async {
    try {
      await repository.logout();
    } catch (e) {
      emit(SettingsError('Не удалось выйти'));
    }
  }
}
