import 'package:event_manager/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<void> logout();
  Future<void> changeLang(String code);
  Future<SettingsEntity> getSettings();
}
