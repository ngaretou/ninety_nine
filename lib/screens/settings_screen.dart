import 'package:flutter/material.dart';
import 'package:ninety_nine/screens/names_list_screen.dart';
import 'package:ninety_nine/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/names.dart';
import '../providers/theme.dart';
import '../providers/card_prefs.dart';

import './about_screen.dart';
import './cards_screen.dart';

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
    MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool _isPhone =
        (mediaQuery.size.width + mediaQuery.size.height) <= 1400;

    ThemeModel themeProvider = Provider.of<ThemeModel>(context, listen: false);
    ThemeComponents? _userTheme = themeProvider.userTheme;
    Locale userLocale = themeProvider.userLocale!;

    CardPrefs cardPrefs = Provider.of<CardPrefs>(context, listen: false);
    bool _wolof = cardPrefs.cardPrefs.wolofVerseEnabled;
    bool _wolofal = cardPrefs.cardPrefs.wolofalVerseEnabled;

    if (!_wolof && !_wolofal) {
      _wolof = true;
      _wolofal = true;
      cardPrefs.savePref('wolofVerseEnabled', true);
      cardPrefs.savePref('wolofalVerseEnabled', true);
    }

    final activeControlColor = Theme.of(context).colorScheme.inversePrimary;
    final activeSwitchColor = Theme.of(context).colorScheme.primary;

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
                    Expanded(
                        child: Text(title,
                            style: Theme.of(context).textTheme.titleLarge)),
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
    Widget viewListOfNames() {
      return settingTitle(
        AppLocalizations.of(context)!.listView,
        Icons.list,
        () {
          //Part of the names list navigation - this opens the NamesLIst, then gets and then passes on the value from the popped screen
          Navigator.of(context).pushNamed(NamesList.routeName).then((value) {
            Navigator.of(context).pop(value);
          });
        },
      );
    }

    Widget themeTitle() {
      return settingTitle(AppLocalizations.of(context)!.settingsTheme,
          Icons.settings_brightness, null);
    }

    Widget themeSettings() {
      List<Color> themeColors = [
        // Colors.red,
        // Colors.deepOrange,
        // Colors.amber,
        Colors.lightGreen,
        Colors.green,
        Colors.teal,
        Colors.cyan,
        Colors.blue,
        Colors.indigo,
        Colors.deepPurple,
        Colors.blueGrey,
        Colors.brown,
        Colors.grey
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
              backgroundColor: Colors.white,
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
              backgroundColor: Colors.black,
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
              //Note that userLocale.toString() evaluates to for example 'fr' in Android/iOS but on the web 'fr_' with the underscore.
              //So three slightly different checks for the three langs:
              //fr_CH checks for fr_CH only
              //fr checks for fr or fr_
              //en checks for contains en
              ChoiceChip(
                selectedColor: activeControlColor,
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr_CH' ? true : false,
                label: Text(
                  "Wolof",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onSelected: (bool selected) {
                  themeProvider.setLocale('fr_CH');
                },
              ),
              ChoiceChip(
                selectedColor: activeControlColor,
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr' ||
                        userLocale.toString() == 'fr_'
                    ? true
                    : false,
                label: Text(
                  "Français",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onSelected: (bool selected) {
                  themeProvider.setLocale('fr');
                },
              ),
              ChoiceChip(
                selectedColor: activeControlColor,
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString().contains('en') ? true : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.titleMedium,
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
      return settingTitle(AppLocalizations.of(context)!.settingsCardBackground,
          Icons.image, null);
    }

    Widget directionTitle() {
      return settingTitle(AppLocalizations.of(context)!.settingsCardDirection,
          Icons.compare_arrows, null);
    }

    Widget scriptPickerTitle() {
      return settingTitle(AppLocalizations.of(context)!.settingsVerseDisplay,
          Icons.format_quote, null);
    }

    Widget showFavsTitle() {
      return settingTitle(
          AppLocalizations.of(context)!.settingsShowFavs, Icons.favorite, null);
    }

    Widget lowPowerModeTitle() {
      return settingTitle(
          AppLocalizations.of(context)!.powerMode, Icons.bolt, null);
    }

    Widget languageTitle() {
      return settingTitle(AppLocalizations.of(context)!.settingsLanguage,
          Icons.translate, null);
    }

    Widget backgroundSettings() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            child: cardPrefs.cardPrefs.imageEnabled
                ? null
                : Icon(
                    Icons.check,
                    color: Colors.black,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
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
                selectedColor: activeControlColor,
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: cardPrefs.cardPrefs.textDirection ? false : true,
                label: Row(children: [
                  Text(
                    "(abc)",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.arrow_forward),
                ]),
                onSelected: (bool selected) {
                  cardPrefs.savePref('textDirection', false);
                  setState(() {});
                },
              ),
              ChoiceChip(
                selectedColor: activeControlColor,
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: cardPrefs.cardPrefs.textDirection ? true : false,
                label: Row(
                  children: [
                    Text(
                      "(بدف)",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.arrow_back),
                  ],
                ),
                onSelected: (bool selected) {
                  cardPrefs.savePref('textDirection', true);
                  setState(() {});
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
                    Text(AppLocalizations.of(context)!.settingsVerseinWolofal,
                        style: Theme.of(context).textTheme.titleMedium),
                  ]))),
          Expanded(
            child: Row(
              mainAxisAlignment:
                  _isPhone ? MainAxisAlignment.end : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                  activeColor: activeSwitchColor,
                  activeTrackColor: activeControlColor,
                  value: _wolofal,
                  onChanged: (_) {
                    if (_wolof) {
                      cardPrefs.savePref('wolofalVerseEnabled', !_wolofal);
                      //but if wolof is not on and you're trying to turn of wolofal, turn on wolof.
                    } else if (!_wolof && _wolofal) {
                      cardPrefs.savePref('wolofalVerseEnabled', false);
                      cardPrefs.savePref('wolofVerseEnabled', true);
                    }

                    setState(() {});
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
                    Text(AppLocalizations.of(context)!.settingsVerseinWolof,
                        style: Theme.of(context).textTheme.titleMedium),
                  ]))),
          Expanded(
            child: Row(
              mainAxisAlignment:
                  _isPhone ? MainAxisAlignment.end : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                  activeColor: activeSwitchColor,
                  activeTrackColor: activeControlColor,
                  value: _wolof,
                  onChanged: (_) {
                    if (_wolofal) {
                      cardPrefs.savePref('wolofVerseEnabled', !_wolof);
                      //but if wolof is not on and you're trying to turn of wolofal, turn on wolof.
                    } else if (_wolof && !_wolofal) {
                      cardPrefs.savePref('wolofalVerseEnabled', true);
                      cardPrefs.savePref('wolofVerseEnabled', false);
                    }

                    setState(() {});
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
                selectedColor: activeControlColor,
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: cardPrefs.cardPrefs.showFavs ? true : false,
                // avatar: Icon(Icons.favorite),
                label: Text(
                  AppLocalizations.of(context)!.settingsFavorites,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onSelected: (bool selected) async {
                  if (Provider.of<DivineNames>(context, listen: false)
                          .favoriteNames
                          .length ==
                      0) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.favsNoneYet,
                          ),
                          content: Text(
                            AppLocalizations.of(context)!
                                .favsNoneYetInstructions,
                          ),
                          actions: [
                            TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.ok,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ],
                        );
                      },
                    );
                  } else {
                    cardPrefs.savePref('showFavs', true);
                    setState(() {});
                  }
                },
              ),
              ChoiceChip(
                selectedColor: activeControlColor,
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: cardPrefs.cardPrefs.showFavs ? false : true,
                // avatar: Icon(Icons.all_inclusive),
                label: Text(
                  AppLocalizations.of(context)!.settingsTextAll,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onSelected: (bool selected) {
                  cardPrefs.savePref('showFavs', false);
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      );
    }

    Widget lowPowerModeChooser() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 80),
                  child: Row(children: [
                    Expanded(
                        child: Text(AppLocalizations.of(context)!.lowPowerMode,
                            style: Theme.of(context).textTheme.titleMedium)),
                  ]))),
          Expanded(
            child: Row(
              mainAxisAlignment:
                  _isPhone ? MainAxisAlignment.end : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                  activeColor: activeSwitchColor,
                  activeTrackColor: activeControlColor,
                  value: cardPrefs.cardPrefs.lowPower,
                  onChanged: (_) {
                    cardPrefs.savePref(
                        'lowPower', !cardPrefs.cardPrefs.lowPower);
                    //This makes it so if the user chooses a setting, we won't ask them again to set to low power, they know where the setting is
                    cardPrefs.savePref('shouldTestDevicePerformance', false);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget aboutWidget() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsAbout,
        Icons.info,
        () {
          showAbout(context);
          // Navigator.of(context).pushNamed(AboutScreen.routeName);
        },
      );
    }

    Widget contactUsWidget() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsContactUs,
        Icons.email,
        () async {
          const url = 'mailto:equipedevmbs@gmail.com';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            throw 'Could not launch $url';
          }
        },
      );
    }

    Widget showIntroWidget() {
      return settingTitle(
          AppLocalizations.of(context)!.settingsViewIntro, Icons.replay, () {
        Navigator.of(context).pushNamed(OnboardingScreen.routeName);
      });
    }

///////////////////////////////

    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.settingsTitle,
          ),
        ),
        //If the width of the screen is greater or equal to 500
        //show the wide view
        body: ScrollConfiguration(
            //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
            behavior: MyCustomScrollBehavior().copyWith(scrollbars: false),
            child: Center(
                child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: mediaQuery.size.width >= 730
                  // tablet
                  ? Container(
                      width: 730,
                      child: Padding(
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
                            lowPowerModeTitle(),
                            lowPowerModeChooser(),
                            Divider(),
                            languageTitle(),
                            languageSetting(),
                            Divider(),
                            aboutWidget(),
                            Divider(),
                            contactUsWidget(),
                            Divider(),
                            showIntroWidget()
                          ],
                        ),
                      ),
                    )
                  // phone
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
                        lowPowerModeTitle(),
                        lowPowerModeChooser(),
                        Divider(),
                        settingColumn(languageTitle(), languageSetting()),
                        aboutWidget(),
                        Divider(),
                        contactUsWidget(),
                        Divider(),
                        showIntroWidget()
                      ],
                    ),
              // ),
            ))));
  }

  void showAbout(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text(packageInfo.appName),
            content: SingleChildScrollView(
                child: ListBody(children: [
              Row(
                children: [
                  Container(
                    // child: Image.asset('assets/icons/icon.png'),
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage("assets/images/icons/99-icon-round.png"),
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          "99",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Text(
                          'Version ${packageInfo.version} (${packageInfo.buildNumber})'),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontStyle: FontStyle.italic),
                    text: 'Kàddug Yàlla',
                  ),
                  TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    text: ' copyright © 2024 La MBS.',
                  ),
                ],
              )),
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    text: 'Appli © 2024 Foundational LLC.',
                  ),
                ],
              )),
            ])),

            actions: <Widget>[
              OutlinedButton(
                child: const Text('Copyrights'),
                onPressed: () {
                  // Navigator.of(context).pushNamed(AboutScreen.routeName);
                  clearPage(Widget page) => PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) => page,
                      );
                  Navigator.push(
                    context,
                    clearPage(const AboutScreen()),
                  );
                },
              ),
              OutlinedButton(
                child: const Text('Licenses'),
                onPressed: () {
                  // Navigator.of(context).pop();
                  showLicenses(context,
                      appName: packageInfo.appName,
                      appVersion:
                          '${packageInfo.version} (${packageInfo.buildNumber})');
                },
              ),
              OutlinedButton(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}

void showLicenses(BuildContext context, {String? appName, String? appVersion}) {
  void showLicensePage({
    required BuildContext context,
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    bool useRootNavigator = false,
  }) {
    // assert(context != null);
    // assert(useRootNavigator != null);
    Navigator.of(context, rootNavigator: useRootNavigator)
        .push(MaterialPageRoute<void>(
      builder: (BuildContext context) => LicensePage(
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
      ),
    ));
  }

  showLicensePage(
      context: context,
      applicationVersion: appVersion,
      applicationName: appName,
      useRootNavigator: true);
}
