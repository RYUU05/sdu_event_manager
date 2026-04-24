import 'package:event_manager/core/constants/app_constants.dart';
import 'package:event_manager/features/settings/data/datasources/settings_data_source.dart';
import 'package:event_manager/features/settings/domain/entities/settings_entity.dart';
import 'package:event_manager/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _dataSource;
  SettingsRepositoryImpl(this._dataSource);
  @override
  Future<void> changeLang(String code) async {
    if (code != AppConstants.english && code != AppConstants.russion) {
      throw ArgumentError('Unsupported language code: $code');
    }

    await _dataSource.changeLanguage(code);
  }

  @override
  Future<SettingsEntity> getSettings() async {
    final language = await _dataSource.getLang();
    return SettingsEntity(language: language, account: '', role: '');
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }
}
