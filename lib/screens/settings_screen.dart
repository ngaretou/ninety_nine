import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';
// import 'dart:convert';

import '../locale/app_localization.dart';

import '../providers/theme.dart';
import '../providers/card_prefs.dart';

import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //The individual setting headings
  Widget buildListTile(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 27,
        color: Theme.of(context).iconTheme.color,
      ),
      title: Text(title, style: Theme.of(context).textTheme.headline6),
      onTap: tapHandler,
    );
  }

  //Main Settings screen construction:
  @override
  Widget build(BuildContext context) {
    // var _verse;
    var userThemeName =
        Provider.of<ThemeModel>(context, listen: false).userThemeName;
    var userLang = Provider.of<ThemeModel>(context, listen: false).userLang;
    var cardPrefs = Provider.of<CardPrefs>(context);
    final _wolof = cardPrefs.cardPrefs.wolofVerseEnabled;
    final _wolofal = cardPrefs.cardPrefs.wolofalVerseEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalization.of(context).settingsTitle,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: ListView(
        children: [
          buildListTile(AppLocalization.of(context).settingsTheme,
              Icons.settings_brightness, null),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                child: userThemeName == 'lightTheme' ? Icon(Icons.check) : null,
                shape: CircleBorder(),
                color: Colors.white,
                onPressed: () {
                  Provider.of<ThemeModel>(context, listen: false)
                      .setLightTheme();
                },
              ),
              RaisedButton(
                child: userThemeName == 'blueTheme' ? Icon(Icons.check) : null,
                shape: CircleBorder(),
                color: Colors.blue,
                onPressed: () {
                  Provider.of<ThemeModel>(context, listen: false)
                      .setBlueTheme();
                },
              ),
              RaisedButton(
                  child:
                      userThemeName == 'tealTheme' ? Icon(Icons.check) : null,
                  shape: CircleBorder(),
                  color: Colors.teal,
                  onPressed: () {
                    Provider.of<ThemeModel>(context, listen: false)
                        .setTealTheme();
                  }),
              RaisedButton(
                child: userThemeName == 'darkTheme' ? Icon(Icons.check) : null,
                shape: CircleBorder(),
                color: Colors.black,
                onPressed: () {
                  Provider.of<ThemeModel>(context, listen: false)
                      .setDarkTheme();
                },
              ),
            ],
          ),
          Divider(),
          buildListTile(AppLocalization.of(context).settingsCardBackground,
              Icons.image, null),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                child: cardPrefs.cardPrefs.imageEnabled
                    ? null
                    : Icon(
                        Icons.check,
                        color: Colors.black,
                      ),
                shape: CircleBorder(),
                color: Colors.white70,
                onPressed: () {
                  setState(() {
                    cardPrefs.savePref('imageEnabled', false);
                  });
                },
              ),
              Material(
                shape: CircleBorder(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.black,
                  onTap: () {
                    setState(() {
                      cardPrefs.savePref('imageEnabled', true);
                    });
                  },
                  child: Container(
                    child: cardPrefs.cardPrefs.imageEnabled
                        ? Icon(Icons.check, color: Colors.white)
                        : null,
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/7.jpg'),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          buildListTile("Card Direction", Icons.compare_arrows, null),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Wrap(
                direction: Axis.horizontal,
                spacing: 15,
                children: [
                  ChoiceChip(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    selected: cardPrefs.cardPrefs.textDirection ? false : true,
                    avatar: Icon(Icons.arrow_forward),
                    label: Text(
                      "LTR",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    selectedColor: Theme.of(context).accentColor,
                    onSelected: (bool selected) {
                      setState(() {
                        cardPrefs.savePref('textDirection', false);
                      });
                    },
                  ),
                  ChoiceChip(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    selected: cardPrefs.cardPrefs.textDirection ? true : false,
                    avatar: Icon(Icons.arrow_back),
                    label: Text(
                      "RTL",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    selectedColor: Theme.of(context).accentColor,
                    onSelected: (bool selected) {
                      setState(() {
                        cardPrefs.savePref('textDirection', true);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          buildListTile('Verse Display', Icons.format_quote, null),
          Padding(
            padding: EdgeInsets.only(left: 60),
            child: SwitchListTile(
              title: Text('Verse in Wolofal',
                  style: Theme.of(context).textTheme.subtitle1),
              value: _wolofal,
              onChanged: (bool value) {
                setState(() {
                  cardPrefs.savePref('wolofalVerseEnabled', !_wolofal);
                });
              },
              // secondary: const Icon(Icons.lightbulb_outline),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 60),
            child: SwitchListTile(
              title: Text('Verse in Wolof',
                  style: Theme.of(context).textTheme.subtitle1),
              value: _wolof,
              onChanged: (bool value) {
                setState(() {
                  cardPrefs.savePref('wolofVerseEnabled', !_wolof);
                });
              },
              // secondary: const Icon(Icons.lightbulb_outline),
            ),
          ),
          Divider(),
          buildListTile(AppLocalization.of(context).settingsLanguage,
              Icons.translate, null),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Wrap(
                direction: Axis.horizontal,
                spacing: 15,
                children: [
                  ChoiceChip(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    selected: userLang == 'wo' ? true : false,
                    label: Text(
                      "Wolof",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    selectedColor: Theme.of(context).accentColor,
                    onSelected: (bool selected) {
                      setState(() {
                        Provider.of<ThemeModel>(context, listen: false)
                            .setLang('wo');
                      });
                    },
                  ),
                  ChoiceChip(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    selected: userLang == 'fr' ? true : false,
                    label: Text(
                      "French",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    selectedColor: Theme.of(context).accentColor,
                    onSelected: (bool selected) {
                      setState(() {
                        Provider.of<ThemeModel>(context, listen: false)
                            .setLang('fr');
                      });
                    },
                  ),
                  ChoiceChip(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    selected: userLang == 'en' ? true : false,
                    label: Text(
                      "English",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    selectedColor: Theme.of(context).accentColor,
                    onSelected: (bool selected) {
                      setState(() {
                        Provider.of<ThemeModel>(context, listen: false)
                            .setLang('en');
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          buildListTile(
              AppLocalization.of(context).settingsAbout, Icons.question_answer,
              () {
            Navigator.of(context).pushNamed(AboutScreen.routeName);
          }),
        ],
      ),
    );
  }
}
