import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './providers/card_prefs.dart';
import './providers/names.dart';
import './providers/theme.dart';

import './screens/settings_screen.dart';
import './screens/about_screen.dart';
import './screens/cards_screen.dart';
import './screens/onboarding_screen.dart';
import './screens/names_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => CardPrefs(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DivineNames(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //A Future for the future builder
  late Future<void> _initialization;

  //Language code: Initialize the locale
  Future<void> setupLang() async {
    print('setupLang()');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Function setLocale =
        Provider.of<ThemeModel>(context, listen: false).setLocale;

    //If there is no lang pref (i.e. first run), set lang to Wolof
    if (!prefs.containsKey('userLang')) {
      // fr_CH is our Flutter 2.x stand-in for Wolof
      await setLocale('fr_CH');
    } else {
      //otherwise grab the saved setting
      String savedUserLang =
          json.decode(prefs.getString('userLang')!) as String;

      await setLocale(savedUserLang);
    }
    print('end setupLang()');
    //end language code
  }

  @override
  void initState() {
    super.initState();
    /* https://blog.devgenius.io/understanding-futurebuilder-in-flutter-491501526373
    Now you must be wondering why we are doing this right? Can’t we directly assign _getContacts() 
    to the FutureBuilder directly instead of introducing another variable?
    If you go through the Flutter documentation, you will notice that the build method can get called 
    at any time. This would include setState() or on device orientation change. What this means is that 
    any change in device configuration or widget rebuilds would trigger your Future to fire multiple times. 
    In order to prevent that, we make sure that the Future is obtained in the initState() and not in the build() 
    method itself. This is something which you may notice in a lot of tutorials online where they assign the 
    Future method directly to the FutureBuilder and it’s factually wrong.*/
    print('before _initialization');
    _initialization = callInititalization();
    print('after _initialization');
  }

  Future<void> callInititalization() async {
    await Provider.of<DivineNames>(context, listen: false).getDivineNames();
    await Provider.of<ThemeModel>(context, listen: false).setupTheme();
    await Provider.of<CardPrefs>(context, listen: false).setupCardPrefs();
    await setupLang();
    //This gives the flutter UI a second to complete these above initialization processes
    //These should wait and this be unnecessary but the build happens before all these inits finish,
    //so this is a hack that helps
    // await Future.delayed(Duration(milliseconds: 3000));
    return;
  }

  @override
  Widget build(BuildContext context) {
    print('main.dart build');

    //Don't show top status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    ThemeData? _currentTheme = Provider.of<ThemeModel>(context).currentTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _currentTheme == null ? ThemeData.light() : _currentTheme,
      title: '99',
      home: FutureBuilder(
        future: _initialization,
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : Provider.of<CardPrefs>(context, listen: false)
                        .cardPrefs
                        .showOnboarding
                    ? OnboardingScreen()
                    : CardsScreen(),
      ),
      routes: {
        // '/': (BuildContext context) => CardsScreen(),
        CardsScreen.routeName: (ctx) => CardsScreen(),
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        AboutScreen.routeName: (ctx) => AboutScreen(),
        OnboardingScreen.routeName: (ctx) => OnboardingScreen(),
        NamesList.routeName: (ctx) => NamesList(),
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', 'FR'),
        // Unfortunately there is a ton of setup to add a new language
        // to Flutter post version 2.0 and intl 0.17.
        // The most doable way to stick with the official Flutter l10n method
        // is to use Swiss French as the main source for the translations
        // and add in the Wolof to the app_fr_ch.arb in the l10n folder.
        // So when we switch locale to fr_CH, that's Wolof.
        const Locale('fr', 'CH'),
      ],
      locale: Provider.of<ThemeModel>(context, listen: false).userLocale == null
          ? Locale('fr', 'CH')
          : Provider.of<ThemeModel>(context, listen: false).userLocale,
    );
  }
}
