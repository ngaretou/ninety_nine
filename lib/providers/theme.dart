import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

//New Material 3 version

class ThemeComponents {
  Brightness brightness;
  Color color;

  ThemeComponents({required this.brightness, required this.color});
}

class ThemeModel extends ChangeNotifier {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  ThemeComponents? userTheme;
  ThemeData? currentTheme;
  Locale? userLocale;

  Future<void> setLocale(String incomingLocale) async {
    switch (incomingLocale) {
      case 'en':
        userLocale = Locale('en', '');
        notifyListeners();
        break;
      case 'fr':
        userLocale = Locale('fr', '');
        notifyListeners();
        break;
      case 'fr_CH':
        userLocale = Locale('fr', 'CH');
        notifyListeners();
        break;
      case 'ar':
        userLocale = Locale('ar', '');
        notifyListeners();
        break;
      default:
    }
    return;
  }

  Future<void> setupTheme() async {
    ThemeComponents defaultTheme = ThemeComponents(
      brightness: Brightness.light,
      color: Colors.teal,
    );
    debugPrint('setupTheme');

    //get the prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme with teal
    if (!prefs.containsKey('userTheme')) {
      setTheme(defaultTheme, refresh: false);
    } else {
      final List<String>? savedTheme = prefs.getStringList('userTheme');
      late Brightness brightness;
      //Try this out - if there's a version problem where the variable doesn't fit,
      //the default theme is used
      try {
        switch (savedTheme?[0]) {
          case "Brightness.light":
            {
              brightness = Brightness.light;
              break;
            }

          case "Brightness.dark":
            {
              brightness = Brightness.dark;
              break;
            }
        }
        //We save the color this way so have to convert it to Color:
        int colorValue = int.parse(savedTheme![1]);
        Color color = Color(colorValue);

        ThemeComponents componentsToSet = ThemeComponents(
          brightness: brightness,
          color: color,
        );

        setTheme(componentsToSet, refresh: false);
      } catch (e) {
        //If something goes wrong, set default theme
        setTheme(defaultTheme, refresh: false);
      }
    }

    debugPrint('end of setup theme');
    return;
  }

  void setTheme(ThemeComponents theme, {bool? refresh}) {
    //Set incoming theme
    userTheme = theme;
    currentTheme = ThemeData(
      brightness: theme.brightness,
      colorSchemeSeed: theme.color,
      fontFamily: 'Lato',
    );
    //send it for storage
    saveThemeToDisk(theme);
    if (refresh == true || refresh == null) {
      notifyListeners();
    }
  }

  Future<void> saveThemeToDisk(ThemeComponents theme) async {
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();
    //save _themeName to disk
    // final _userTheme = json.encode(theme);

    await prefs.setStringList('userTheme', <String>[
      theme.brightness.toString(),
      colorToInt(theme.color).toString(),
    ]);
  }
}

Color colorFromInt(int value) {
  final int alpha = (value >> 24) & 0xFF;
  final int red = (value >> 16) & 0xFF;
  final int green = (value >> 8) & 0xFF;
  final int blue = value & 0xFF;

  return Color.fromARGB(alpha, red, green, blue);
}

int colorToInt(Color color) {
  final a = (color.a * 255.0).round().clamp(0, 255);
  final r = (color.r * 255.0).round().clamp(0, 255);
  final g = (color.g * 255.0).round().clamp(0, 255);
  final b = (color.b * 255.0).round().clamp(0, 255);

  return (a << 24) | (r << 16) | (g << 8) | b;
}
