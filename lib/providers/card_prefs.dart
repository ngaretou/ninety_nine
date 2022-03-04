import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:core';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CardPrefList {
  bool textDirection;
  bool imageEnabled;
  bool wolofVerseEnabled;
  bool wolofalVerseEnabled;
  bool showFavs = false;
  bool showOnboarding;

  CardPrefList({
    required this.textDirection,
    required this.imageEnabled,
    required this.wolofVerseEnabled,
    required this.wolofalVerseEnabled,
    required this.showFavs,
    required this.showOnboarding,
  });
}

class CardPrefs with ChangeNotifier {
  late CardPrefList _cardPrefs;

  CardPrefList get cardPrefs {
    return _cardPrefs;
  }

  Future<void> setupCardPrefs() async {
    //get the prefs
    final prefs = await SharedPreferences.getInstance();

    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme
    //We're also grabbing other setup info here:
    if (!prefs.containsKey('cardPrefs')) {
      CardPrefList defaultCardPrefs = CardPrefList(
        //Starting off LTR as in English - the relevant setting is in cards.dart PageView(reverse: false) = LTR
        textDirection: false,
        imageEnabled: true,
        wolofVerseEnabled: true,
        wolofalVerseEnabled: true,
        showFavs: false,
        showOnboarding: true,
      );
      //Set in-memory copy of prefs
      _cardPrefs = defaultCardPrefs;
      //Save prefs to disk
      final _defaultCardPrefs = json.encode({
        'textDirection': defaultCardPrefs.textDirection,
        'imageEnabled': defaultCardPrefs.imageEnabled,
        'wolofVerseEnabled': defaultCardPrefs.wolofVerseEnabled,
        'wolofalVerseEnabled': defaultCardPrefs.wolofalVerseEnabled,
        'showFavs': defaultCardPrefs.showFavs,
        'showOnboarding': defaultCardPrefs.showOnboarding,
      });
      prefs.setString('cardPrefs', _defaultCardPrefs);
    } else {
      //The user has prefs from a previous session - load them
      final jsonResponse =
          json.decode(prefs.getString('cardPrefs')!) as Map<String, dynamic>;

      _cardPrefs = CardPrefList(
        textDirection: jsonResponse['textDirection'] as bool,
        imageEnabled: jsonResponse['imageEnabled'] as bool,
        wolofVerseEnabled: jsonResponse['wolofVerseEnabled'] as bool,
        wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'] as bool,
        showFavs: jsonResponse['showFavs'] as bool,
        showOnboarding: jsonResponse['showOnboarding'] as bool,
      );

      // notifyListeners();
    }
  }

  Future<void> savePref(String setting, userPref) async {
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    final jsonResponse =
        json.decode(prefs.getString('cardPrefs')!) as Map<String, dynamic>;
    var _tempCardPrefs = CardPrefList(
      textDirection: jsonResponse['textDirection'] as bool,
      imageEnabled: jsonResponse['imageEnabled'] as bool,
      wolofVerseEnabled: jsonResponse['wolofVerseEnabled'] as bool,
      wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'] as bool,
      showFavs: jsonResponse['showFavs'] as bool,
      showOnboarding: jsonResponse['showOnboarding'] as bool,
    );

    //set the incoming setting
    switch (setting) {
      case 'textDirection':
        {
          _tempCardPrefs.textDirection = userPref;
        }
        break;
      case 'imageEnabled':
        {
          _tempCardPrefs.imageEnabled = userPref;
        }
        break;
      case 'wolofVerseEnabled':
        {
          _tempCardPrefs.wolofVerseEnabled = userPref;
        }
        break;
      case 'wolofalVerseEnabled':
        {
          _tempCardPrefs.wolofalVerseEnabled = userPref;
        }
        break;
      case 'showFavs':
        {
          _tempCardPrefs.showFavs = userPref;
        }
        break;
      case 'showOnboarding':
        {
          _tempCardPrefs.showOnboarding = userPref;
        }
        break;
    }

    //now set it in memory
    _cardPrefs = _tempCardPrefs;
    // notifyListeners();
    //now save it to disk
    final _userPrefs = json.encode({
      'textDirection': _tempCardPrefs.textDirection,
      'imageEnabled': _tempCardPrefs.imageEnabled,
      'wolofVerseEnabled': _tempCardPrefs.wolofVerseEnabled,
      'wolofalVerseEnabled': _tempCardPrefs.wolofalVerseEnabled,
      'showFavs': _tempCardPrefs.showFavs,
      'showOnboarding': _tempCardPrefs.showOnboarding,
    });
    prefs.setString('cardPrefs', _userPrefs);
    notifyListeners();
  }
}
