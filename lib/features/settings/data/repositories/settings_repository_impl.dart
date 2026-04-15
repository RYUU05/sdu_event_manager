import 'package:event_manager/features/settings/data/datasources/settings_data_source.dart';
import 'package:event_manager/features/settings/domain/entities/settings_entity.dart';
import 'package:event_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource dataSource;
  SettingsRepositoryImpl(this.dataSource);
  @override
  Future<void> changeLang(String code) async {
    await dataSource.changeLanguage(code);
  }

  @override
  Future<SettingsEntity> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? 'en';
    return SettingsEntity(language: language);
  }

  @override
  Future<void> logout() async {
    await dataSource.logout();
  }
}
