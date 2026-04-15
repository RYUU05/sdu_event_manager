import 'package:event_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;
  SettingsBloc(this.repository) : super(SettingsInitial()) {
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
      emit(SettingsLoaded(settings.language));
    } catch (e) {
      emit(SettingsError('Failed to load settings'));
    }
  }

  Future<void> _onChangeLanguage(
    LanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await repository.changeLang(event.languageCode);
      emit(SettingsLoaded(event.languageCode));
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
