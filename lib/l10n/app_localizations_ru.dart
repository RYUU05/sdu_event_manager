// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Событий';

  @override
  String get comingEvents => 'Ближайшие мероприятия';

  @override
  String get popularClubs => 'Популярные клубы';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get logout => 'Выход';

  @override
  String get selectingLang => 'Выборите язык';

  @override
  String get cancel => 'Отмена';
}
