import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('fr', 'CH')
  ];

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// settings: Theme section
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// settings: CardBackground section
  ///
  /// In en, this message translates to:
  /// **'Card Background'**
  String get settingsCardBackground;

  /// settingsLanguage
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// settingsAbout
  ///
  /// In en, this message translates to:
  /// **'About & Copyright'**
  String get settingsAbout;

  /// settingsCardDirection
  ///
  /// In en, this message translates to:
  /// **'Card Direction'**
  String get settingsCardDirection;

  /// settingsLTR
  ///
  /// In en, this message translates to:
  /// **'LTR'**
  String get settingsLTR;

  /// settingsRTL
  ///
  /// In en, this message translates to:
  /// **'RTL'**
  String get settingsRTL;

  /// settingsVerseDisplay
  ///
  /// In en, this message translates to:
  /// **'Verse Display'**
  String get settingsVerseDisplay;

  /// settingsVerseinWolofal
  ///
  /// In en, this message translates to:
  /// **'Verse in Wolofal'**
  String get settingsVerseinWolofal;

  /// settingsVerseinWolof
  ///
  /// In en, this message translates to:
  /// **'Verse in Wolof'**
  String get settingsVerseinWolof;

  /// settingsShowFavs
  ///
  /// In en, this message translates to:
  /// **'Show Favorites'**
  String get settingsShowFavs;

  /// settingsFavorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get settingsFavorites;

  /// settingsTextAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get settingsTextAll;

  /// settingsContactUs
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get settingsContactUs;

  /// settingsViewIntro
  ///
  /// In en, this message translates to:
  /// **'View intro again'**
  String get settingsViewIntro;

  /// sharingTitle
  ///
  /// In en, this message translates to:
  /// **'Share a verse'**
  String get sharingTitle;

  /// sharingMsg
  ///
  /// In en, this message translates to:
  /// **'Choose which script you\'d like to share'**
  String get sharingMsg;

  /// cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// clickHereToReadMore
  ///
  /// In en, this message translates to:
  /// **'Click here to read more'**
  String get clickHereToReadMore;

  /// General introductory words
  ///
  /// In en, this message translates to:
  /// **'This app contains 99 names of God in Arabic, Wolofal, and Wolof.\n\nRead and reflect on the verses found on the back of the cards to know God better and understand how he wants us to live.'**
  String get introPage1;

  /// DBS questions
  ///
  /// In en, this message translates to:
  /// **'When you read a verse, ask yourself four questions:\n\n 1. What do these verses teach about God?\n\n 2. What do these verses teach about people?\n\n 3. How can I live out these verses?\n\n 4. Who in my life needs to hear these verses?'**
  String get introPage2;

  /// Motivation for DBS
  ///
  /// In en, this message translates to:
  /// **'As you meditate on God’s Word, you will see your love for him grow.\n\nGod says in Proverbs 8:17:'**
  String get introPage3a;

  /// Motivation for DBS: bible verse
  ///
  /// In en, this message translates to:
  /// **'I love those who love me, and those who seek me diligently find me.'**
  String get introPage3b;

  /// On each card you can
  ///
  /// In en, this message translates to:
  /// **'On each card you can:'**
  String get introPage4a;

  /// hear the verse read,
  ///
  /// In en, this message translates to:
  /// **'hear the verse read,'**
  String get introPage4b;

  /// share the verse with your friends,
  ///
  /// In en, this message translates to:
  /// **'share the verse with your friends,'**
  String get introPage4c;

  /// and choose your favorites.
  ///
  /// In en, this message translates to:
  /// **'and choose your favorites.'**
  String get introPage4d;

  /// favsNoneYet
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favsNoneYet;

  /// favsNoneYetInstructions
  ///
  /// In en, this message translates to:
  /// **'Click the heart icon on your favorite names to add some.'**
  String get favsNoneYetInstructions;

  /// OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Skip on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Start on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// List View
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// Power mode
  ///
  /// In en, this message translates to:
  /// **'Power mode'**
  String get powerMode;

  /// Low power mode on
  ///
  /// In en, this message translates to:
  /// **'Low power mode on'**
  String get lowPowerMode;

  /// lowPowerModeMessage
  ///
  /// In en, this message translates to:
  /// **'Switching to low power mode.'**
  String get lowPowerModeMessage;

  /// when sharing, audio
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioForSharing;

  /// Share link to app on app store
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareAppLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'CH':
            return AppLocalizationsFrCh();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
