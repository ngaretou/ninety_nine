import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

class DivineName with ChangeNotifier {
  final String id;
  final String arabicName;
  final String wolofName;
  final String wolofalName;
  final String wolofVerse;
  final String wolofVerseRef;
  final String wolofalVerse;
  final String wolofalVerseRef;
  String? img;
  bool isFav;

  DivineName({
    required this.id,
    required this.arabicName,
    required this.wolofName,
    required this.wolofalName,
    required this.wolofVerse,
    required this.wolofVerseRef,
    required this.wolofalVerse,
    required this.wolofalVerseRef,
    this.img,
    this.isFav = false,
  });
}

class DivineNames with ChangeNotifier {
  int _lastNameViewed = 0;
  List<int> _pictureIds = [];
  List<DivineName> _names = [];
  bool _moveToName = false;

  // ignore: unnecessary_getters_setters
  bool get moveToName {
    return _moveToName;
  }

  set moveToName(bool incoming) {
    _moveToName = incoming;
  }

  //Work with a copy of the map, not the map itself
  List<DivineName> get names {
    return [..._names];
  }

  List<DivineName> get favoriteNames {
    return _names.where((name) => name.isFav).toList();
  }

  int get lastNameViewed {
    return _lastNameViewed;
  }

  // get a random number for the image
  //This is to select random numbers until the pictures are gone, then loop again, but not in same order.
  String get randomNumber {
    //set max to the last int of the number of pics that we ship with the app
    int numberOfPicsAvailable = 20;
    String r;
    Random rnd = new Random();

    //If this is first run, no pics yet, put all possible pics in
    //It can also be after all pictures are assigned
    if (_pictureIds.length == 0) {
      //i is index, so + 1 on each as it will start with 0
      _pictureIds = List<int>.generate(numberOfPicsAvailable, (i) => i + 1);
    }

    //get a random number between 1 and the number of pics we have left in this round
    //The indexes here are 0 through _pictureIds.length, in other words these are the indexes, not the values
    //the 'max' is in the parentheses here
    int indexToGrab = rnd.nextInt(_pictureIds.length);

    //This line does two things -
    //grabs the element at the random index we just generated and gets rid of it in the list
    //so we don't grab that picture again until all pics have been used
    r = _pictureIds.removeAt(indexToGrab).toString();
    // print(r);
    return r;
  }

  Future<void> getDivineNames() async {
    print('getDivineNames');

    String linebreakInLongNames(String nameToBreak) {
      String returnString = nameToBreak;

      String addLinebreak(int pos) {
        String firstLine = nameToBreak.substring(0, pos);
        String secondLine = nameToBreak.substring(pos + 1);
        return firstLine + '\n' + secondLine;
      }

      //holder for list of indexes of spaces in the range we want to check
      List<int> spaces = [];
      List<int> punctBeforeSpaces = [];
      final punct = RegExp("[.,!;،.!؛]");

      try {
        //Only check for spaces in the middle third of the name.
        //If we're looking for spaces that are too far at the start or end of the name it's unbalanced: ex: "Aji\nSeetantel ji"
        //Get 1/3 of the length of the string, then round
        int rangeToCheckStart = (nameToBreak.length / 3).round();
        //End checking at that index X 2
        int rangeToCheckEnd = rangeToCheckStart * 2;
        //Check each character in that range to see if it's a space
        for (int i = rangeToCheckStart; i < rangeToCheckEnd; i++) {
          //If you find a space then make a note in the list of spaces
          if (nameToBreak[i] == " ") {
            spaces.add(i);
            if (punct.hasMatch(nameToBreak[i - 1]))
              punctBeforeSpaces.add(i - 1);
          }
        }
        //If you did this and didn't find spaces in the middle third, just do nothing, it will return the original name as-is
        if (spaces.length != 0) {
          //If just one space found or you have more than one space but no punctuation, that's the easy case, split it there.
          if (spaces.length == 1 ||
              (spaces.length > 1 && punctBeforeSpaces.length == 0)) {
            returnString = addLinebreak(spaces[0]);
          } else {
            //You have a long name with multiple spaces in the region we're looking for and there's a punctuation mark -
            //split on the punctuation mark.
            returnString = addLinebreak(punctBeforeSpaces[0] + 1);
          }
        }
      } catch (e) {
        print(nameToBreak +
            " Error adding carriage returns to names: " +
            e.toString());
      }

      return returnString;
    }

    //On launch initialize the last name viewed
    getLastNameViewed();

    //Get the divine names from names.json file
    String jsonString = await rootBundle.loadString("assets/names.json");
    final jsonResponse = json.decode(jsonString) as List<dynamic>;

    //So we have the info but it's in the wrong format - here map it to our class
    //Re: splitting the names with a carriage return via linebreakInLongNames -
    //Dart sees the length of the AS and RS names differently so the length test has to be here based on one of them,
    //not testing the individual names. Ex: first line is length = 19, second is 22.
    //     flutter: Aji Yërëm ci àddina : 19
    //     flutter: اَجِ يࣴرࣴمْ ݖِ اࣵدِّنَ 22

    //Maximum length of name before split.
    //At 20, there is only one name that goes through the process for Wolof
    int maxLength = 20;

    _names = jsonResponse
        .map((name) => DivineName(
              id: name['id'].toString(),
              arabicName: name['arabicName'].length > maxLength
                  ? linebreakInLongNames(name['arabicName'])
                  : name['arabicName'],
              wolofName: name['wolofName'].length > maxLength
                  ? linebreakInLongNames(name['wolofName'])
                  : name['wolofName'],
              wolofalName: name['wolofName'].length > maxLength
                  ? linebreakInLongNames(name['wolofalName'])
                  : name['wolofalName'],
              wolofVerse: name['wolofVerse'],
              wolofVerseRef: name['wolofVerseRef'],
              wolofalVerse: name['wolofalVerse'],
              wolofalVerseRef: name['wolofalVerseRef'],
              img: randomNumber,
            ))
        .toList();

    //The names come from the names.json but the favs come from sharedprefs,
    //so we populate the copy of names that lives in session memory with the user's info here

    //Get the user's favorite list from sharedprefs
    late List _favList;
    final prefs = await SharedPreferences.getInstance();
    //If there is no list of favs, set the list to empty, or if there are favs, load them into the list
    !prefs.containsKey('favList')
        ? _favList = []
        : _favList = json.decode(prefs.getString('favList')!) as List;

    //Loop over the names list and fill in the values
    _names.forEach((name) {
      _favList.contains(name.id) ? name.isFav = true : name.isFav = false;
    });

    print('end getDivineNames');
  }

  Future<void> saveLastNameViewed(lastNameViewed) async {
    _lastNameViewed = lastNameViewed;
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(lastNameViewed.toString());
    prefs.setString('lastNameViewed', jsonData);
  }

  Future<void> getLastNameViewed() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastNameViewed')) {
      _lastNameViewed = 0;
      return;
    } else {
      String storedValue = json.decode(prefs.getString('lastNameViewed')!);
      _lastNameViewed = int.parse(storedValue);
      return;
    }
  }

  Future<void> toggleFavoriteStatus(id) async {
    List<dynamic>? _favList;
    //Get the favorites list from disk
    final prefs = await SharedPreferences.getInstance();
    //check if this is the first time a user has set prefs - if so empty list
    if (!prefs.containsKey('favList')) {
      _favList = [];
    } else {
      //or if the user does have favs get that list in memory so we can use it
      _favList = json.decode(prefs.getString('favList')!) as List<dynamic>?;
    }
    var currentName = _names.firstWhere((name) => name.id == id);
    //set the model in memory to true or false and also add the id of the current name to the list or remove it
    if (currentName.isFav) {
      currentName.isFav = false;
      _favList!.remove(id);
    } else if (!currentName.isFav) {
      currentName.isFav = true;
      _favList!.add(id);
    }
    // notifyListeners();
    //Now store the list back to disk
    final favList = json.encode(_favList);
    prefs.setString('favList', favList);
  }
}
