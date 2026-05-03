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
  /// **'Log out'**
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

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

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

  /// No description provided for @myEventsClub.
  ///
  /// In en, this message translates to:
  /// **'My Events (Club)'**
  String get myEventsClub;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @noCreatedEvents.
  ///
  /// In en, this message translates to:
  /// **'No created events'**
  String get noCreatedEvents;

  /// No description provided for @noRegisteredEvents.
  ///
  /// In en, this message translates to:
  /// **'No registered events'**
  String get noRegisteredEvents;

  /// No description provided for @createEventPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create an event and it will appear here'**
  String get createEventPrompt;

  /// No description provided for @registerEventPrompt.
  ///
  /// In en, this message translates to:
  /// **'Click \'Participate\' on an event to see it here'**
  String get registerEventPrompt;

  /// No description provided for @findEvents.
  ///
  /// In en, this message translates to:
  /// **'Find events'**
  String get findEvents;

  /// No description provided for @yourEvent.
  ///
  /// In en, this message translates to:
  /// **'Your event'**
  String get yourEvent;

  /// No description provided for @youAreRegistered.
  ///
  /// In en, this message translates to:
  /// **'You are registered'**
  String get youAreRegistered;

  /// No description provided for @removeFromMyEvents.
  ///
  /// In en, this message translates to:
  /// **'Remove from my events'**
  String get removeFromMyEvents;

  /// No description provided for @removeEvent.
  ///
  /// In en, this message translates to:
  /// **'Remove event?'**
  String get removeEvent;

  /// No description provided for @cancelParticipationPrompt.
  ///
  /// In en, this message translates to:
  /// **'You will cancel your participation in this event.'**
  String get cancelParticipationPrompt;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @catAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get catAcademic;

  /// No description provided for @catSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get catSports;

  /// No description provided for @catCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get catCulture;

  /// No description provided for @catSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get catSocial;

  /// No description provided for @catCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get catCareer;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @searchEvents.
  ///
  /// In en, this message translates to:
  /// **'Search events...'**
  String get searchEvents;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title *'**
  String get eventTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location *'**
  String get location;

  /// No description provided for @maxParticipants.
  ///
  /// In en, this message translates to:
  /// **'Max participants (0 = no limit)'**
  String get maxParticipants;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get categoryLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @enterInteger.
  ///
  /// In en, this message translates to:
  /// **'Enter an integer'**
  String get enterInteger;

  /// No description provided for @cannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Cannot be negative'**
  String get cannotBeNegative;

  /// No description provided for @selectCategoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategoryPrompt;

  /// No description provided for @addPosterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Click to add a poster'**
  String get addPosterPrompt;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @onlyClubsCreate.
  ///
  /// In en, this message translates to:
  /// **'Only clubs can create events'**
  String get onlyClubsCreate;

  /// No description provided for @imageError.
  ///
  /// In en, this message translates to:
  /// **'Image selection error'**
  String get imageError;

  /// No description provided for @selectDateTimePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select date and time of the event'**
  String get selectDateTimePrompt;

  /// No description provided for @eventUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event updated!'**
  String get eventUpdated;

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'Event created!'**
  String get eventCreated;

  /// No description provided for @unibuddyTitle.
  ///
  /// In en, this message translates to:
  /// **'UniBuddy'**
  String get unibuddyTitle;

  /// No description provided for @unibuddyNavBar.
  ///
  /// In en, this message translates to:
  /// **'UniBuddy'**
  String get unibuddyNavBar;

  /// No description provided for @unibuddyInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about events or campus…'**
  String get unibuddyInputHint;

  /// No description provided for @unibuddyEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try: where are today\'s events, or what karate clubs exist — answers use synced campus data.'**
  String get unibuddyEmptyHint;

  /// No description provided for @recommendationForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get recommendationForYou;

  /// No description provided for @interestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interests (comma-separated)'**
  String get interestsLabel;

  /// No description provided for @interestsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. dancing, IT, karate'**
  String get interestsHint;

  /// No description provided for @interestsSaved.
  ///
  /// In en, this message translates to:
  /// **'Interests saved'**
  String get interestsSaved;

  /// No description provided for @fillInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'Add interests in Settings for personalized recommendations.'**
  String get fillInterestsHint;

  /// No description provided for @recoCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load recommendations'**
  String get recoCouldNotLoad;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get register;

  /// No description provided for @emptyFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in all fields'**
  String get emptyFields;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @shortPassword.
  ///
  /// In en, this message translates to:
  /// **'Password too short (min 8 characters)'**
  String get shortPassword;

  /// No description provided for @authErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get authErrorWrong;

  /// No description provided for @authErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get authErrorNotFound;

  /// No description provided for @authErrorTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try later.'**
  String get authErrorTooMany;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get authErrorNetwork;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get emailSent;

  /// No description provided for @resetPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send a reset link.'**
  String get resetPasswordPrompt;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmail;

  /// No description provided for @enterClubName.
  ///
  /// In en, this message translates to:
  /// **'Enter club name'**
  String get enterClubName;

  /// No description provided for @enterNameSurname.
  ///
  /// In en, this message translates to:
  /// **'Enter first and last name'**
  String get enterNameSurname;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @club.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get club;

  /// No description provided for @clubNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Club name'**
  String get clubNameLabel;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @registerAsClub.
  ///
  /// In en, this message translates to:
  /// **'Register as club'**
  String get registerAsClub;

  /// No description provided for @registerAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Register as student'**
  String get registerAsStudent;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get memberCount;

  /// No description provided for @aboutClub.
  ///
  /// In en, this message translates to:
  /// **'About the club'**
  String get aboutClub;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @eventNotFound.
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get eventNotFound;

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteConfirmContent;

  /// No description provided for @organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizer;

  /// No description provided for @participantsCount.
  ///
  /// In en, this message translates to:
  /// **'spots'**
  String get participantsCount;

  /// No description provided for @unlimitedParticipants.
  ///
  /// In en, this message translates to:
  /// **'participants (no limit)'**
  String get unlimitedParticipants;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @noSeats.
  ///
  /// In en, this message translates to:
  /// **'No seats left'**
  String get noSeats;

  /// No description provided for @cancelParticipation.
  ///
  /// In en, this message translates to:
  /// **'Cancel participation'**
  String get cancelParticipation;

  /// No description provided for @participate.
  ///
  /// In en, this message translates to:
  /// **'Participate'**
  String get participate;

  /// No description provided for @myEventsShortcut.
  ///
  /// In en, this message translates to:
  /// **'My events'**
  String get myEventsShortcut;
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
