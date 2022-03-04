import 'package:flutter/material.dart';
import 'package:ninety_nine/screens/names_list_screen.dart';
import 'package:ninety_nine/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/names.dart';
import '../providers/theme.dart';
import '../providers/card_prefs.dart';

import './about_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //The individual setting headings

  //Main Settings screen construction:
  @override
  Widget build(BuildContext context) {
    final bool _isPhone = (MediaQuery.of(context).size.width +
            MediaQuery.of(context).size.height) <=
        1400;

    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    final ThemeComponents? _userTheme = themeProvider.userTheme;
    final Locale userLocale = themeProvider.userLocale!;

    final cardPrefs = Provider.of<CardPrefs>(context, listen: false);
    final _wolof = cardPrefs.cardPrefs.wolofVerseEnabled;
    bool? _wolofal = cardPrefs.cardPrefs.wolofalVerseEnabled;

    //Widgets
    //Main template for all setting titles
    Widget settingTitle(String title, IconData icon, Function? tapHandler) {
      return InkWell(
        onTap: tapHandler as void Function()?,
        child: Container(
            width: 300,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 27,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    SizedBox(width: 25),
                    Text(title, style: Theme.of(context).textTheme.headline6),
                  ],
                ))),
      );
    }

//Main section layout types
    Widget settingRow(title, setting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          title,
          VerticalDivider(width: 10, color: Colors.white),
          Expanded(
            child: setting,
          )
          // setting,
        ],
      );
    }

    Widget settingColumn(title, setting) {
      return Column(
        //This aligns titles to the left
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          setting,
          Divider(),
        ],
      );
    }

    //Now individual implementations of it
    Widget themeTitle() {
      return settingTitle(AppLocalizations.of(context).settingsTheme,
          Icons.settings_brightness, null);
    }

    Widget themeSettings() {
      List<Color> themeColors = [
        // Colors.red,
        // Colors.deepOrange,
        // Colors.amber,
        // Colors.lightGreen,
        Colors.green,
        Colors.teal,
        Colors.cyan,
        Colors.blue,
        // Colors.indigo,
        // Colors.deepPurple,
        // Colors.blueGrey,
        // Colors.brown,
        // Colors.grey
      ];

      List<DropdownMenuItem<String>> menuItems = [];

      for (var color in themeColors) {
        menuItems.add(DropdownMenuItem(
            child: Material(
              shape: CircleBorder(side: BorderSide.none),
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                margin: EdgeInsets.all(0),
                width: 36,
              ),
            ),
            value: color.value.toString()));
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton(
              itemHeight: 48,
              underline: SizedBox(),
              value: _userTheme!.color.value.toString(),
              items: menuItems,
              onChanged: (response) {
                int _colorValue = int.parse(response.toString());

                Color color = Color(_colorValue).withOpacity(1);

                ThemeComponents _themeToSet = ThemeComponents(
                    brightness: _userTheme.brightness, color: color);

                themeProvider.setTheme(_themeToSet);
              }),
          Container(
              height: 45,
              width: 1,
              color: Theme.of(context).colorScheme.outline),
          ElevatedButton(
            child: _userTheme.brightness == Brightness.light
                ? Icon(
                    Icons.check,
                    color: Colors.black,
                  )
                : null,
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              ThemeComponents _themeToSet = ThemeComponents(
                  brightness: Brightness.light, color: _userTheme.color);

              themeProvider.setTheme(_themeToSet);
            },
          ),
          ElevatedButton(
            child: _userTheme.brightness == Brightness.dark
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              ThemeComponents _themeToSet = ThemeComponents(
                  brightness: Brightness.dark, color: _userTheme.color);

              themeProvider.setTheme(_themeToSet);
            },
          ),
        ],
      );
    }

    Widget languageSetting() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            direction: Axis.horizontal,
            spacing: 15,
            children: [
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr_CH' ? true : false,
                label: Text(
                  "Wolof",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                onSelected: (bool selected) {
                  themeProvider.setLocale('fr_CH');
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr' ? true : false,
                label: Text(
                  "Français",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                onSelected: (bool selected) {
                  themeProvider.setLocale('fr');
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'en' ? true : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                onSelected: (bool selected) {
                  themeProvider.setLocale('en');
                },
              ),
            ],
          ),
        ],
      );
    }

    Widget backgroundTitle() {
      return settingTitle(AppLocalizations.of(context).settingsCardBackground,
          Icons.image, null);
    }

    Widget directionTitle() {
      return settingTitle(AppLocalizations.of(context).settingsCardDirection,
          Icons.compare_arrows, null);
    }

    Widget scriptPickerTitle() {
      return settingTitle(AppLocalizations.of(context).settingsVerseDisplay,
          Icons.format_quote, null);
    }

    Widget showFavsTitle() {
      return settingTitle(
          AppLocalizations.of(context).settingsShowFavs, Icons.favorite, null);
    }

    Widget languageTitle() {
      return settingTitle(
          AppLocalizations.of(context).settingsLanguage, Icons.translate, null);
    }

    Widget backgroundSettings() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // crossAxisAlignment: CrossAxisAlignment.center,
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
              cardPrefs.savePref('imageEnabled', false);
              setState(() {});
            },
          ),
          Material(
            shape: CircleBorder(),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.black,
              onTap: () {
                cardPrefs.savePref('imageEnabled', true);
                setState(() {});
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
      );
    }

    Widget directionSettings() {
      return Row(
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
                onSelected: (bool selected) {
                  setState(() {
                    cardPrefs.savePref('textDirection', true);
                  });
                },
              ),
            ],
          ),
        ],
      );
    }

    Widget asScriptPicker() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 80),
                  child: Row(children: [
                    // Expanded(child:
                    Text(AppLocalizations.of(context).settingsVerseinWolofal,
                        style: Theme.of(context).textTheme.subtitle1),
                  ]))),
          Expanded(
            child: Row(
              mainAxisAlignment:
                  _isPhone ? MainAxisAlignment.end : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                  value: _wolofal,
                  onChanged: (_) {
                    setState(() {
                      cardPrefs.savePref('wolofalVerseEnabled', !_wolofal);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget rsScriptPicker() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 80),
                  child: Row(children: [
                    // Expanded(child:
                    Text(AppLocalizations.of(context).settingsVerseinWolof,
                        style: Theme.of(context).textTheme.subtitle1),
                  ]))),
          Expanded(
            child: Row(
              mainAxisAlignment:
                  _isPhone ? MainAxisAlignment.end : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                  value: _wolof,
                  onChanged: (_) {
                    setState(() {
                      cardPrefs.savePref('wolofVerseEnabled', !_wolof);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget showFavsSetting() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            direction: Axis.horizontal,
            spacing: 15,
            children: [
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: cardPrefs.cardPrefs.showFavs ? true : false,
                avatar: Icon(Icons.favorite),
                label: Text(
                  AppLocalizations.of(context).settingsFavorites,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                onSelected: (bool selected) async {
                  print('in fav selector');
                  if (Provider.of<DivineNames>(context, listen: false)
                          .favoriteNames
                          .length ==
                      0) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            AppLocalizations.of(context).favsNoneYet,
                          ),
                          content: Text(
                            AppLocalizations.of(context)
                                .favsNoneYetInstructions,
                          ),
                          actions: [
                            FlatButton(
                                child: Text(
                                  AppLocalizations.of(context).ok,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      cardPrefs.savePref('showFavs', true);
                    });
                  }
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: cardPrefs.cardPrefs.showFavs ? false : true,
                avatar: Icon(Icons.all_inclusive),
                label: Text(
                  AppLocalizations.of(context).settingsTextAll,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                onSelected: (bool selected) {
                  setState(() {
                    cardPrefs.savePref('showFavs', false);
                  });
                },
              ),
            ],
          ),
        ],
      );
    }

//old; delete if wokrking
    // Widget languageSetting() {
    //   return Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //     children: [
    //       Wrap(
    //         direction: Axis.horizontal,
    //         spacing: 15,
    //         children: [
    //           ChoiceChip(
    //             padding: EdgeInsets.symmetric(horizontal: 10),
    //             selected: userLang == 'wo' ? true : false,
    //             label: Text(
    //               "Wolof",
    //               style: Theme.of(context).textTheme.subtitle1,
    //             ),
    //             backgroundColor: Theme.of(context).primaryColor,
    //             selectedColor: Theme.of(context).accentColor,
    //             onSelected: (bool selected) {
    //               setState(() {
    //                 Provider.of<ThemeModel>(context, listen: false)
    //                     .setLang('wo');
    //               });
    //             },
    //           ),
    //           ChoiceChip(
    //             padding: EdgeInsets.symmetric(horizontal: 10),
    //             selected: userLang == 'fr' ? true : false,
    //             label: Text(
    //               "Français",
    //               style: Theme.of(context).textTheme.subtitle1,
    //             ),
    //             backgroundColor: Theme.of(context).primaryColor,
    //             selectedColor: Theme.of(context).accentColor,
    //             onSelected: (bool selected) {
    //               setState(() {
    //                 Provider.of<ThemeModel>(context, listen: false)
    //                     .setLang('fr');
    //               });
    //             },
    //           ),
    //           ChoiceChip(
    //             padding: EdgeInsets.symmetric(horizontal: 10),
    //             selected: userLang == 'en' ? true : false,
    //             label: Text(
    //               "English",
    //               style: Theme.of(context).textTheme.subtitle1,
    //             ),
    //             backgroundColor: Theme.of(context).primaryColor,
    //             selectedColor: Theme.of(context).accentColor,
    //             onSelected: (bool selected) {
    //               setState(() {
    //                 Provider.of<ThemeModel>(context, listen: false)
    //                     .setLang('en');
    //               });
    //             },
    //           ),
    //         ],
    //       ),
    //     ],
    //   );
    // }

    Widget viewListOfNames() {
      return settingTitle(
        AppLocalizations.of(context).listView,
        Icons.list,
        () {
          //Part of the names list navigation - this opens the NamesLIst, then gets and then passes on the value from the popped screen
          Navigator.of(context).pushNamed(NamesList.routeName).then((value) {
            Navigator.of(context).pop(value);
          });
        },
      );
    }

    // print(MediaQuery.of(context).size.width);
///////////////////////////////
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).settingsTitle,
        ),
      ),
      //If the width of the screen is greater or equal to 500
      //show the wide view
      body: MediaQuery.of(context).size.width >= 730
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: ListView(
                children: [
                  viewListOfNames(),
                  settingRow(themeTitle(), themeSettings()),
                  Divider(),
                  settingRow(backgroundTitle(), backgroundSettings()),
                  Divider(),
                  settingRow(directionTitle(), directionSettings()),
                  Divider(),
                  scriptPickerTitle(),
                  asScriptPicker(),
                  rsScriptPicker(),
                  Divider(),
                  settingRow(showFavsTitle(), showFavsSetting()),
                  Divider(),
                  settingRow(languageTitle(), languageSetting()),
                  Divider(),
                  settingTitle(
                    AppLocalizations.of(context).settingsAbout,
                    Icons.question_answer,
                    () {
                      Navigator.of(context).pushNamed(AboutScreen.routeName);
                    },
                  ),
                  Divider(),
                  settingTitle(
                    AppLocalizations.of(context).settingsContactUs,
                    Icons.email,
                    () async {
                      const url = 'mailto:equipedevmbs@gmail.com';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  Divider(),
                  settingTitle(AppLocalizations.of(context).settingsViewIntro,
                      Icons.replay, () {
                    Navigator.of(context).pushNamed(OnboardingScreen.routeName);
                  }),
                ],
              ),
            )
          : ListView(
              children: [
                viewListOfNames(),
                settingColumn(themeTitle(), themeSettings()),
                settingColumn(backgroundTitle(), backgroundSettings()),
                settingColumn(directionTitle(), directionSettings()),
                scriptPickerTitle(),
                asScriptPicker(),
                rsScriptPicker(),
                Divider(),
                settingColumn(showFavsTitle(), showFavsSetting()),
                settingColumn(languageTitle(), languageSetting()),
                settingTitle(
                  AppLocalizations.of(context).settingsAbout,
                  Icons.question_answer,
                  () {
                    Navigator.of(context).pushNamed(AboutScreen.routeName);
                  },
                ),
                Divider(),
                settingTitle(
                  AppLocalizations.of(context).settingsContactUs,
                  Icons.email,
                  () async {
                    const url = 'mailto:equipedevmbs@gmail.com';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
                Divider(),
                settingTitle(AppLocalizations.of(context).settingsViewIntro,
                    Icons.replay, () {
                  Navigator.of(context).pushNamed(OnboardingScreen.routeName);
                }),
              ],
            ),
      // ),
    );
  }
}
