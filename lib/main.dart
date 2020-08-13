import 'package:flutter/material.dart';
import 'package:ninety_nine/providers/card_prefs.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'locale/app_localization.dart';

import './providers/names.dart';
import './providers/theme.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
// import './screens/splash_screen.dart';
import './screens/cards_screen.dart';

void main() {
  //getting the multiproviders
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => CardPrefs(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ThemeModel(),
        ),
      ],
      // ChangeNotifierProvider(
      //   create: (ctx) => ThemeModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp() {
    // mySetup();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLocalizationDelegate _localeOverrideDelegate =
      AppLocalizationDelegate(Locale('fr', ''));

  @override
  void didChangeDependencies() {
    Provider.of<ThemeModel>(context, listen: false).initialSetupAsync(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    print('main.dart build');
    return ChangeNotifierProvider(
      create: (ctx) => DivineNames(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '99',
        home: FutureBuilder(
          future: Provider.of<ThemeModel>(context).setupTheme(),
          builder: (ctx, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : CardsScreen(),
        ),

        // Provider.of<ThemeModel>(context).currentTheme == null
        //     ? SplashScreen()
        //     : CardsScreen(),
        theme: Provider.of<ThemeModel>(context).currentTheme,
        routes: {
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
          AboutScreen.routeName: (ctx) => AboutScreen(),
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          _localeOverrideDelegate
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('fr', ''),
          const Locale('wo', '')
        ],
      ),
    );
  }
}
