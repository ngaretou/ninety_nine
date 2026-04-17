import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ninety_nine/providers/player_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart'; // the new Flutter 3.x localization method
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
        ChangeNotifierProvider(create: (ctx) => CardPrefs()),
        ChangeNotifierProvider(create: (ctx) => ThemeModel()),
        ChangeNotifierProvider(create: (ctx) => DivineNames()),
        ChangeNotifierProvider(create: (ctx) => PlayerManager()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  //A Future for the future builder
  late Future<void> initialization;

  //Language code: Initialize the locale
  Future<void> setupLang() async {
    debugPrint('setupLang()');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    Function setLocale = Provider.of<ThemeModel>(
      context,
      listen: false,
    ).setLocale;

    try {
      //If there is no lang pref (i.e. first run), set lang to Wolof
      if (!prefs.containsKey('userLocale')) {
        // fr_CH is our Flutter 2.x stand-in for Wolof
        await setLocale('fr_CH');
      } else {
        //otherwise grab the saved setting

        String savedUserLang = prefs.getString('userLocale')!;

        await setLocale(savedUserLang);
      }
    } catch (e) {
      debugPrint(e.toString());
      await setLocale('fr_CH');
    }

    debugPrint('end setupLang()');

    //end language code
  }

  @override
  void initState() {
    super.initState();
    /* https://blog.devgenius.io/understanding-futurebuilder-in-flutter-491501526373
    "Now you must be wondering why we are doing this right? Can’t we directly assign _getContacts() 
    to the FutureBuilder directly instead of introducing another variable?
    If you go through the Flutter documentation, you will notice that the build method can get called 
    at any time. This would include setState() or on device orientation change. What this means is that 
    any change in device configuration or widget rebuilds would trigger your Future to fire multiple times. 
    In order to prevent that, we make sure that the Future is obtained in the initState() and not in the build() 
    method itself. This is something which you may notice in a lot of tutorials online where they assign the 
    Future method directly to the FutureBuilder and it’s factually wrong."*/
    initialization = callInititalization();
  }

  Future<void> callInititalization() async {
    //do the work
    await Provider.of<DivineNames>(context, listen: false).getDivineNames();
    if (!mounted) return;
    await Provider.of<ThemeModel>(context, listen: false).setupTheme();
    if (!mounted) return;
    await Provider.of<CardPrefs>(context, listen: false).setupCardPrefs();

    await setupLang();
    //this clears out old audio files
    await AudioPlayer.clearAssetCache();
    //This gives the flutter UI a second to complete these above initialization processes
    //These should wait and this be unnecessary but the build happens before all these inits finish,
    //so this is a hack that helps
    // await Future.delayed(Duration(milliseconds: 3000));
    // debugPrint('returning future from initialization');
    return;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('main.dart build');

    ThemeData? currentTheme = Provider.of<ThemeModel>(context).currentTheme;

    // The other options are going away on Android as of SDK 36 - so go ahead and figure it out.
    // iOS can still handle them, but not worth the headaches to carve out the cases
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    // this edgeToEdge option will be enforced from 36, so go ahead and use this.

    final Brightness brightness = Theme.of(context).brightness;

    // This has no effect on Android 14+ and ambiguous effect on 13 but on prev versions it can be necessary
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // top status bar
        statusBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: Colors.transparent,
        // bottom nav bar
        systemNavigationBarColor: brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        systemNavigationBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return FutureBuilder(
      future: initialization,
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
          ? const Center(child: CircularProgressIndicator())
          : MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: currentTheme ?? ThemeData.light(),
              title: '99',
              home:
                  Provider.of<CardPrefs>(
                    context,
                    listen: false,
                  ).cardPrefs.showOnboarding
                  ? OnboardingScreen()
                  : CardsScreen(),
              routes: {
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
                // wolofal 2026
                const Locale('ar', ''),
              ],
              locale:
                  Provider.of<ThemeModel>(context, listen: false).userLocale ??
                  Locale('fr', 'CH'),
            ),
    );
  }
}
