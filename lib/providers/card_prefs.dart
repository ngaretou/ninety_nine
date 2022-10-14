import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
import 'dart:core';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const darkBackground = AssetImage("assets/images/black-bg-1.jpg");
const lightBackground = AssetImage("assets/images/white-bg-5.jpg");
const assetImage1 = AssetImage("assets/images/1.jpg");
const assetImage2 = AssetImage("assets/images/2.jpg");
const assetImage3 = AssetImage("assets/images/3.jpg");
const assetImage4 = AssetImage("assets/images/4.jpg");
const assetImage5 = AssetImage("assets/images/5.jpg");
const assetImage6 = AssetImage("assets/images/6.jpg");
const assetImage7 = AssetImage("assets/images/7.jpg");
const assetImage8 = AssetImage("assets/images/8.jpg");
const assetImage9 = AssetImage("assets/images/9.jpg");
const assetImage10 = AssetImage("assets/images/10.jpg");
const assetImage11 = AssetImage("assets/images/11.jpg");
const assetImage12 = AssetImage("assets/images/12.jpg");
const assetImage13 = AssetImage("assets/images/13.jpg");
const assetImage14 = AssetImage("assets/images/14.jpg");
const assetImage15 = AssetImage("assets/images/15.jpg");
const assetImage16 = AssetImage("assets/images/16.jpg");
const assetImage17 = AssetImage("assets/images/17.jpg");
const assetImage18 = AssetImage("assets/images/18.jpg");
const assetImage19 = AssetImage("assets/images/19.jpg");
const assetImage20 = AssetImage("assets/images/20.jpg");

class CardPrefList {
  bool textDirection;
  bool imageEnabled;
  bool wolofVerseEnabled;
  bool wolofalVerseEnabled;
  bool showFavs = false;
  bool showOnboarding;
  bool lowPower;
  bool shouldTestDevicePerformance;

  CardPrefList(
      {required this.textDirection,
      required this.imageEnabled,
      required this.wolofVerseEnabled,
      required this.wolofalVerseEnabled,
      required this.showFavs,
      required this.showOnboarding,
      required this.lowPower,
      required this.shouldTestDevicePerformance});
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
    void setDefaultCardPrefs() {
      CardPrefList defaultCardPrefs = CardPrefList(
          //Starting off LTR as in English - the relevant setting is in cards.dart PageView(reverse: false) = LTR
          textDirection: false,
          imageEnabled: true,
          wolofVerseEnabled: true,
          wolofalVerseEnabled: true,
          showFavs: false,
          showOnboarding: true,
          lowPower: false,
          shouldTestDevicePerformance: true);
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
        'lowPower': defaultCardPrefs.lowPower,
        'shouldTestDevicePerformance':
            defaultCardPrefs.shouldTestDevicePerformance,
      });
      prefs.setString('cardPrefs', _defaultCardPrefs);
    }

    if (!prefs.containsKey('cardPrefs')) {
      setDefaultCardPrefs();
    } else {
      //The user has prefs from a previous session - load them
      final jsonResponse =
          json.decode(prefs.getString('cardPrefs')!) as Map<String, dynamic>;

      try {
        _cardPrefs = CardPrefList(
          textDirection: jsonResponse['textDirection'] as bool,
          imageEnabled: jsonResponse['imageEnabled'] as bool,
          wolofVerseEnabled: jsonResponse['wolofVerseEnabled'] as bool,
          wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'] as bool,
          showFavs: jsonResponse['showFavs'] as bool,
          showOnboarding: jsonResponse['showOnboarding'] as bool,
          lowPower: jsonResponse['lowPower'] as bool,
          shouldTestDevicePerformance:
              jsonResponse['shouldTestDevicePerformance'] as bool,
        );
      } catch (e) {
        //If there's a problem - example we've added a new preference that there is a null value for in their saved prefs - reset all
        setDefaultCardPrefs();
      }
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
      lowPower: jsonResponse['lowPower'] as bool,
      shouldTestDevicePerformance:
          jsonResponse['shouldTestDevicePerformance'] as bool,
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
      case 'lowPower':
        {
          _tempCardPrefs.lowPower = userPref;
        }
        break;
      case 'shouldTestDevicePerformance':
        {
          _tempCardPrefs.shouldTestDevicePerformance = userPref;
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
      'lowPower': _tempCardPrefs.lowPower,
      'shouldTestDevicePerformance': _tempCardPrefs.shouldTestDevicePerformance,
    });
    prefs.setString('cardPrefs', _userPrefs);
    notifyListeners();
  }
}
