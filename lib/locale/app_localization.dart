import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/messages_all.dart';

class AppLocalization {
  static Future<AppLocalization> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalization();
    });
  }

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: 'Settings screen title',
    );
  }

  String get settingsTheme {
    return Intl.message(
      'Theme',
      name: 'settingsTheme',
      desc: 'settings: Theme section',
    );
  }

  String get settingsCardBackground {
    return Intl.message(
      'Card Background',
      name: 'settingsCardBackground',
      desc: 'settings: CardBackground section',
    );
  }

  String get settingsLanguage {
    return Intl.message(
      'Language',
      name: 'settingsLanguage',
      desc: 'settingsLanguage',
    );
  }

  String get settingsAbout {
    return Intl.message(
      'About & Copyright',
      name: 'settingsAbout',
      desc: 'settingsAbout',
    );
  }

  String get settingsCardDirection {
    return Intl.message(
      'Card Direction',
      name: 'settingsCardDirection',
      desc: 'settingsCardDirection',
    );
  }

  String get settingsLTR {
    return Intl.message(
      'LTR',
      name: 'settingsLTR',
      desc: 'settingsLTR',
    );
  }

  String get settingsRTL {
    return Intl.message(
      'RTL',
      name: 'settingsRTL',
      desc: 'settingsRTL',
    );
  }

  String get settingsVerseDisplay {
    return Intl.message(
      'Verse Display',
      name: 'settingsVerseDisplay',
      desc: 'settingsVerseDisplay title: Show verses in Wolof and/or Wolofal',
    );
  }

  String get settingsVerseinWolofal {
    return Intl.message(
      'Verse in Wolofal',
      name: 'settingsVerseinWolofal',
      desc: 'settingsVerseinWolofal',
    );
  }

  String get settingsVerseinWolof {
    return Intl.message(
      'Verse in Wolof',
      name: 'settingsVerseinWolof',
      desc: 'settingsVerseinWolof',
    );
  }

  String get settingsShowFavs {
    return Intl.message(
      'Show Favorites',
      name: 'settingsShowFavs',
      desc: 'settingsShowFavs',
    );
  }

  String get settingsFavorites {
    return Intl.message(
      'Favorites',
      name: 'settingsFavorites',
      desc: 'settingsFavorites',
    );
  }

  String get settingsTextAll {
    return Intl.message(
      'All',
      name: 'settingsTextAll',
      desc: 'settingsTextAll',
    );
  }

  String get settingsContactUs {
    return Intl.message(
      'Contact Us',
      name: 'settingsContactUs',
      desc: 'settingsContactUs',
    );
  }

  String get settingsViewIntro {
    return Intl.message(
      'View intro again',
      name: 'settingsViewIntro',
      desc: 'settingsViewIntro',
    );
  }

  String get sharingTitle {
    return Intl.message(
      'Share a verse',
      name: 'sharingTitle',
      desc: 'sharingTitle',
    );
  }

  String get sharingMsg {
    return Intl.message(
      "Choose which script you'd like to share",
      name: 'sharingMsg',
      desc: 'sharingMsg',
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'cancel',
    );
  }

  String get clickHereToReadMore {
    return Intl.message(
      'Click here to read more',
      name: 'clickHereToReadMore',
      desc: 'clickHereToReadMore',
    );
  }

  String get introPage1 {
    return Intl.message(
      "This app contains 99 names of God in Arabic, Wolofal, and Wolof.\n\nRead and reflect on the verses found on the back of the cards to know God better and understand how he wants us to live.",
      name: 'introPage1',
      desc: 'General introductory words',
    );
  }

  String get introPage2 {
    return Intl.message(
      "When you read a verse, ask yourself four questions:\n\n 1.\tWhat do these verses teach about God?\n\n 2.\tWhat do these verses teach about people?\n\n 3.\tHow can I live out these verses?\n\n 4.\tWho in my life needs to hear these verses?",
      name: 'introPage2',
      desc: 'DBS questions',
    );
  }

  String get introPage3a {
    return Intl.message(
      "As you meditate on God’s Word, you will see your love for him grow.\n\nGod says in Proverbs 8:17:",
      name: 'introPage3a',
      desc: 'Motivation for DBS',
    );
  }

  String get introPage3b {
    return Intl.message(
      'I love those who love me, and those who seek me diligently find me.',
      name: 'introPage3b',
      desc: 'Motivation for DBS: bible verse',
    );
  }

  String get introPage4a {
    return Intl.message(
      'On each card you can:',
      name: 'introPage4a',
      desc: 'On each card you can',
    );
  }

  String get introPage4b {
    return Intl.message(
      'hear the verse read,',
      name: 'introPage4b',
      desc: 'hear the verse read,',
    );
  }

  String get introPage4c {
    return Intl.message(
      'share the verse with your friends,',
      name: 'introPage4c',
      desc: 'share the verse with your friends,',
    );
  }

  String get introPage4d {
    return Intl.message(
      'and choose your favorites.',
      name: 'introPage4d',
      desc: 'and choose your favorites.',
    );
  }

  String get favsNoneYet {
    return Intl.message(
      'No favorites yet',
      name: 'favsNoneYet',
      desc: 'favsNoneYet',
    );
  }

  String get favsNoneYetInstructions {
    return Intl.message(
      'Click the heart icon on your favorite names to add some.',
      name: 'favsNoneYetInstructions',
      desc: 'favsNoneYetInstructions',
    );
  }

  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: 'OK',
    );
  }

  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: 'Skip on onboarding screen',
    );
  }

  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: 'Start on onboarding screen',
    );
  }
  //to add:
  //skip and start on intro page
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  final Locale overriddenLocale;

  const AppLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'wo'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) => AppLocalization.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) => false;
}
