import 'package:event_manager/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension LocalizationX on BuildContext {
  AppLocalizations get localization {
    final loc = AppLocalizations.of(this);
    assert(loc != null, 'AppLocalizations not found in context');
    return loc!;
  }
}
