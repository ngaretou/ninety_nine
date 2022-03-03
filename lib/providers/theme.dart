import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

//New Material 3 version

class ThemeComponents {
  Brightness brightness;
  Color color;

  ThemeComponents({
    required this.brightness,
    required this.color,
  });
}

class ThemeModel extends ChangeNotifier {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  ThemeComponents? userTheme;
  ThemeData? currentTheme;
  Locale? userLocale;

  //called in initState of main.dart
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
      default:
    }
    return;
  }

  Future<void> setupTheme() async {
    ThemeComponents _defaultTheme =
        ThemeComponents(brightness: Brightness.light, color: Colors.teal);
    print('setupTheme');

    //get the prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme with teal
    if (!prefs.containsKey('userTheme')) {
      setTheme(_defaultTheme, refresh: false);
    } else {
      final List<String>? _savedTheme = prefs.getStringList('userTheme');
      late Brightness _brightness;
      //Try this out - if there's a version problem where the variable doesn't fit,
      //the default theme is used
      try {
        switch (_savedTheme?[0]) {
          case "Brightness.light":
            {
              _brightness = Brightness.light;
              break;
            }

          case "Brightness.dark":
            {
              _brightness = Brightness.dark;
              break;
            }
        }
        int _colorValue = int.parse(_savedTheme![1]);

        Color color = Color(_colorValue).withOpacity(1);

        ThemeComponents _componentsToSet =
            ThemeComponents(brightness: _brightness, color: color);
        setTheme(_componentsToSet, refresh: false);
      } catch (e) {
        setTheme(_defaultTheme, refresh: false);
      }
    }

    print('end of setup theme');
    notifyListeners();
    return;
  }

  void setTheme(ThemeComponents theme, {bool? refresh}) {
    //Set incoming theme
    userTheme = theme;
    currentTheme = ThemeData(
        brightness: theme.brightness,
        colorSchemeSeed: theme.color,
        fontFamily: 'Lato');
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

    await prefs.setStringList('userTheme',
        <String>[theme.brightness.toString(), theme.color.value.toString()]);
  }
}




// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// import '../providers/names.dart';
// import '../providers/card_prefs.dart';

// ThemeData darkTheme = ThemeData.dark().copyWith(
//     primaryColor: Color(0xff1f655d),
//     accentColor: Color(0xff40bf7a),
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//         foregroundColor: Colors.white, backgroundColor: Colors.teal),
//     iconTheme: IconThemeData(color: Colors.white70),
//     textTheme: TextTheme(
//         headline6:
//             TextStyle(color: Colors.white70, fontFamily: 'Lato', fontSize: 20),
//         subtitle2: TextStyle(color: Colors.white),
//         subtitle1: TextStyle(color: Colors.white),
//         bodyText2: TextStyle(color: Colors.white)),
//     appBarTheme: AppBarTheme(
//       color: Color(0xff1f655d),
//       iconTheme: IconThemeData(color: Colors.black54),
//     ),
//     buttonTheme: ButtonThemeData(
//       minWidth: 80,
//     ));

// ThemeData lightTheme = ThemeData.light().copyWith(
//     primaryColor: Color(0xfff5f5f5),
//     accentColor: Color(0xff40bf7a),
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//         // foregroundColor: Colors.white, backgroundColor: Colors.black54),
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.teal),
//     iconTheme: IconThemeData(color: Colors.black54),
//     textTheme: TextTheme(
//       headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
//       subtitle2: TextStyle(color: Colors.black54),
//       subtitle1: TextStyle(color: Colors.black54),
//       bodyText2: TextStyle(color: Colors.black87),
//     ),
//     appBarTheme: AppBarTheme(
//         iconTheme: IconThemeData(color: Colors.black54),
//         textTheme: TextTheme(
//           headline6: TextStyle(color: Colors.black54),
//         ),
//         //     subtitle2: TextStyle(color: Colors.white),
//         //     subtitle1: TextStyle(color: Colors.white)),
//         color: Colors.teal,
//         actionsIconTheme: IconThemeData(color: Colors.black54)),
//     buttonTheme: ButtonThemeData(minWidth: 80));

// ThemeData blueTheme = ThemeData.light().copyWith(
//     primaryColor: Colors.blueGrey,
//     accentColor: Colors.blueAccent,
//     backgroundColor: Colors.blue,
//     scaffoldBackgroundColor: Colors.blue,
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//         foregroundColor: Colors.white, backgroundColor: Colors.blue[700]),
//     iconTheme: IconThemeData(color: Colors.white),
//     textTheme: TextTheme(
//         headline6: TextStyle(color: Colors.white, fontFamily: 'Lato'),
//         subtitle2: TextStyle(color: Colors.white),
//         subtitle1: TextStyle(color: Colors.white),
//         bodyText2: TextStyle(color: Colors.white)),
//     appBarTheme: AppBarTheme(
//         color: Colors.blueAccent,
//         actionsIconTheme: IconThemeData(color: Colors.white)),
//     buttonTheme: ButtonThemeData(minWidth: 80),
//     dialogTheme: DialogTheme(
//         contentTextStyle: TextStyle(color: Colors.black54),
//         titleTextStyle: TextStyle(
//             color: Colors.black54, fontFamily: 'Lato', fontSize: 20)));

// ThemeData tealTheme = ThemeData.light().copyWith(
//     primaryColor: Colors.tealAccent,
//     accentColor: Color(0xff40bf7a),
//     backgroundColor: Colors.teal,
//     scaffoldBackgroundColor: Colors.teal,
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//         foregroundColor: Colors.white, backgroundColor: Colors.teal[800]),
//     textTheme: TextTheme(
//       headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
//       subtitle2: TextStyle(color: Colors.black54),
//       subtitle1: TextStyle(color: Colors.black54),
//       bodyText2: TextStyle(color: Colors.black87),
//     ),
//     appBarTheme: AppBarTheme(
//         color: Color(0xff1f655d),
//         actionsIconTheme: IconThemeData(color: Colors.white)),
//     buttonTheme: ButtonThemeData(
//       minWidth: 80,
//     ));

// enum ThemeType { Light, Blue, Teal, Dark }

// class ThemeModel extends ChangeNotifier {
//   Future<SharedPreferences> prefs = SharedPreferences.getInstance();
//   // ignore: unused_field
//   ThemeType? _themeType;
//   String? userThemeName;
//   ThemeData? currentTheme;
//   String? userLang;


//   Future<void> initialSetupAsync(context) async {
//     await Provider.of<DivineNames>(context, listen: false).getDivineNames();
//     await Provider.of<CardPrefs>(context, listen: false).setupCardPrefs();
//     await setupTheme();
//     await setupLang();

//     return;
//   }

//   Future<void> setupTheme() async {
//     print('setupTheme');
//     if (currentTheme != null) {
//       return;
//     }
//     //get the prefs
//     final prefs = await SharedPreferences.getInstance();
//     //if there's no userTheme, it's the first time they've run the app, so give them lightTheme
//     //We're also grabbing other setup info here: language:

//     if (!prefs.containsKey('userThemeName')) {
//       setLightTheme();
//     } else {
//       userThemeName = json.decode(prefs.getString('userThemeName')!) as String?;

//       switch (userThemeName) {
//         case 'darkTheme':
//           {
//             currentTheme = darkTheme;

//             _themeType = ThemeType.Dark;
//             break;
//           }

//         case 'lightTheme':
//           {
//             currentTheme = lightTheme;
//             _themeType = ThemeType.Light;
//             break;
//           }
//         case 'blueTheme':
//           {
//             currentTheme = blueTheme;
//             _themeType = ThemeType.Blue;
//             break;
//           }
//         case 'tealTheme':
//           {
//             currentTheme = tealTheme;
//             _themeType = ThemeType.Teal;
//             break;
//           }
//       }
//     }
//     notifyListeners();
//   }

//   void setDarkTheme() {
//     currentTheme = darkTheme;
//     _themeType = ThemeType.Dark;
//     //get the theme name as a string for storage
//     userThemeName = 'darkTheme';
//     //send it for storage
//     saveThemeToDisk(userThemeName);
//     notifyListeners();
//   }

//   void setLightTheme() {
//     currentTheme = lightTheme;
//     _themeType = ThemeType.Light;
//     userThemeName = 'lightTheme';
//     saveThemeToDisk(userThemeName);
//     notifyListeners();
//   }

//   void setTealTheme() {
//     currentTheme = tealTheme;
//     _themeType = ThemeType.Teal;
//     userThemeName = 'tealTheme';
//     saveThemeToDisk(userThemeName);
//     notifyListeners();
//   }

//   void setBlueTheme() {
//     currentTheme = blueTheme;
//     _themeType = ThemeType.Blue;
//     userThemeName = 'blueTheme';
//     saveThemeToDisk(userThemeName);
//     notifyListeners();
//   }

//   Future<void> saveThemeToDisk(userThemeName) async {
//     //get prefs from disk
//     final prefs = await SharedPreferences.getInstance();
//     //save _themeName to disk
//     final _userThemeName = json.encode(userThemeName);
//     prefs.setString('userThemeName', _userThemeName);
//   }

//   //Language code:
//   Future<void> setupLang() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!prefs.containsKey('userLang')) {
//       // setLang('fr');
//       setLang('en');
//     } else {
//       final savedUserLang =
//           json.decode(prefs.getString('userLang')!) as String?;
//       setLang(savedUserLang);
//     }
//   }

//   Future<void> setLang(incomingLang) async {
//     if (incomingLang == null) {
//       return;
//     } else {
//       userLang = incomingLang;
//       AppLocalization.load(Locale(userLang!, ''));
//       //get prefs from disk
//       final prefs = await SharedPreferences.getInstance();
//       //save userLang to disk
//       final _userLang = json.encode(userLang);
//       prefs.setString('userLang', _userLang);
//     }
//   }
// }
