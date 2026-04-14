import 'package:event_manager/features/settings/domain/entities/settings_entity.dart';
import 'package:event_manager/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<void> changeLang(String code) {
    // TODO: implement changeLang
    throw UnimplementedError();
  }

  @override
  Future<SettingsEntity> getSettings() {
    // TODO: implement getSettings
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }
}
