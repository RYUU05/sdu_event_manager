import 'package:event_manager/features/settings/domain/entities/settings_entity.dart';
import 'package:event_manager/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<void> changeLang(String code) {
    throw UnimplementedError();
  }

  @override
  Future<SettingsEntity> getSettings() {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }
}
