import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'University Events'**
  String get appTitle;

  /// No description provided for @comingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get comingEvents;

  /// No description provided for @popularClubs.
  ///
  /// In en, this message translates to:
  /// **'Popular clubs'**
  String get popularClubs;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @selectingLang.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectingLang;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create_event.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get create_event;

  /// No description provided for @firstNavBar.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get firstNavBar;

  /// No description provided for @secondNavBar.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get secondNavBar;

  /// No description provided for @thirdNavBar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get thirdNavBar;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Accont'**
  String get account;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEvents;

  String get myEventsClub;
  String get filter;
  String get refresh;
  String get retry;
  String get noCreatedEvents;
  String get noRegisteredEvents;
  String get createEventPrompt;
  String get registerEventPrompt;
  String get findEvents;
  String get yourEvent;
  String get youAreRegistered;
  String get removeFromMyEvents;
  String get removeEvent;
  String get cancelParticipationPrompt;
  String get remove;
  String get allCategories;
  String get selectCategory;

  String get catAcademic;
  String get catSports;
  String get catCulture;
  String get catSocial;
  String get catCareer;
  String get catOther;

  String get searchEvents;
  String get nothingFound;
  String get noEventsYet;
  String get resetFilters;
  String get all;
  String get errorLabel;
  String get noTitle;

  String get editEvent;
  String get eventTitle;
  String get description;
  String get location;
  String get maxParticipants;
  String get categoryLabel;
  String get requiredField;
  String get enterInteger;
  String get cannotBeNegative;
  String get selectCategoryPrompt;
  String get addPosterPrompt;
  String get selectDate;
  String get selectTime;
  String get saving;
  String get creating;
  String get save;
  String get onlyClubsCreate;
  String get imageError;
  String get selectDateTimePrompt;
  String get eventUpdated;
  String get eventCreated;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'kk': return AppLocalizationsKk();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
