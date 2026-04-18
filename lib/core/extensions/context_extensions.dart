import 'package:event_manager/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension LocalizationX on BuildContext {
  AppLocalizations? get localization => AppLocalizations.of(this);
}
