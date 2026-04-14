import 'package:event_manager/features/settings/domain/repositories/settings_repository.dart';

class LogOutUseCases {
  final SettingsRepository _repository;
  LogOutUseCases(this._repository);
  Future<void> call() => _repository.logout();
}
