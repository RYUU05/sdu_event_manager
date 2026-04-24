part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class AccountEvent extends SettingsEvent {}

class LanguageEvent extends SettingsEvent {
  final String languageCode;
  LanguageEvent(this.languageCode);
}

class LogoutEvent extends SettingsEvent {}

class LoadSettingsEvent extends SettingsEvent {}
