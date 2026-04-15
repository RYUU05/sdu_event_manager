part of 'settings_bloc.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String currentLang;
  SettingsLoaded(this.currentLang);
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}
