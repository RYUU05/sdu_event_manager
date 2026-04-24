part of 'settings_bloc.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String currentLang;
  final String currentUser;
  final String currentRole;
  SettingsLoaded(this.currentLang, this.currentUser, this.currentRole);
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}
