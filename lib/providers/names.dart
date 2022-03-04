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
  late int _lastNameViewed;
  List<int> _pictureIds = [];
  List<DivineName> _names = [];
  bool _moveToName = false;

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
    int numberOfPicsAvailable = 14;
    String r;
    Random rnd = new Random();

    //If this is first run, no pics yet, put all possible pics in
    if (_pictureIds.length == 0) {
      //i is index, so + 1 on each as it will start with 0
      _pictureIds = List<int>.generate(numberOfPicsAvailable, (i) => i + 1);
    }

    //get a random number between 1 and the number of pics we have left in this round
    //The indexes here are 0 through _pictureIds.length, in other words these are the indexes, not the values
    //the 'max' is in the parentheses here, and 0 is inclusive and max is exclusive, so you have to do the number of pics you have -1
    int indexToGrab = rnd.nextInt(_pictureIds.length - 1);

    //This line does two things -
    //grabs the element at the random index we just generated and gets rid of it in the list
    //so we don't grab that picture again until all pics have been used
    r = _pictureIds.removeAt(indexToGrab).toString();
    print(r);
    return r;
  }

  Future<void> getDivineNames() async {
    print('getDivineNames');
    print(_names.length);

    //On launch initialize the last name viewed
    int myint = await getLastNameViewed();
    print("lastNameViewed " + myint.toString());

    //Get the divine names from names.json file
    String jsonString = await rootBundle.loadString("assets/names.json");
    final jsonResponse = json.decode(jsonString) as List<dynamic>;

    //So we have the info but it's in the wrong format - here map it to our class
    _names = jsonResponse
        .map((name) => DivineName(
              id: name['id'].toString(),
              arabicName: name['arabicName'],
              wolofName: name['wolofName'],
              wolofalName: name['wolofalName'],
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
    List? _favList;
    final prefs = await SharedPreferences.getInstance();
    //If there is no list of favs, set the list to empty, or if there are favs, load them into the list
    !prefs.containsKey('favList')
        ? _favList = []
        : _favList = json.decode(prefs.getString('favList')!) as List;

    //Loop over the names list and fill in the values
    _names.forEach((name) {
      _favList!.contains(name.id) ? name.isFav = true : name.isFav = false;
    });
    // notifyListeners();
    print('end getDivineNames');
  }

  Future<void> saveLastNameViewed(lastNameViewed) async {
    _lastNameViewed = lastNameViewed;
    print('lastNameViewed ' + lastNameViewed.toString());
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(lastNameViewed.toString());
    prefs.setString('lastNameViewed', jsonData);
  }

  Future<int> getLastNameViewed() async {
    print('getting _lastNameViewed');
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastNameViewed')) {
      _lastNameViewed = 0;
      return _lastNameViewed;
    } else {
      String storedValue = json.decode(prefs.getString('lastNameViewed')!);
      _lastNameViewed = int.parse(storedValue);
      return _lastNameViewed;
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
      //or if not get that list in memory so we can use it
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
    notifyListeners();
    //Now store the list back to disk
    final favList = json.encode(_favList);
    prefs.setString('favList', favList);
  }
}
