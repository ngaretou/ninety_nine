import 'package:flutter/material.dart';
import 'package:ninety_nine/screens/names_list_screen.dart';
import 'package:ninety_nine/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart'; // the new Flutter 3.x localization method
import '../providers/names.dart';
import '../providers/theme.dart';
import '../providers/card_prefs.dart';

import './about_screen.dart';
import './cards_screen.dart';

const double indentWidth = 300;

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  //The individual setting headings

  //Main Settings screen construction:
  @override
  Widget build(BuildContext context) {
    // MediaQueryData mediaQuery = MediaQuery.of(context);
    Size mediaQuerySize = MediaQuery.sizeOf(context);

    final bool isPhone = (mediaQuerySize.width + mediaQuerySize.height) <= 1400;

    ThemeModel themeProvider = Provider.of<ThemeModel>(context, listen: false);
    ThemeComponents? userTheme = themeProvider.userTheme;
    Locale userLocale = themeProvider.userLocale!;

    CardPrefs cardPrefs = Provider.of<CardPrefs>(context, listen: false);
    bool wolof = cardPrefs.cardPrefs.wolofVerseEnabled;
    bool wolofal = cardPrefs.cardPrefs.wolofalVerseEnabled;

    TextStyle titleStyle = TextStyle();
    TextStyle optionsStyle = TextStyle();

    bool isArabic = userLocale.toString() == 'ar';

    TextStyle titleStyleAs = Theme.of(
      context,
    ).textTheme.titleMedium!.copyWith(fontFamily: 'Harmattan', fontSize: 24);
    TextStyle optionsStyleAs = Theme.of(
      context,
    ).textTheme.titleSmall!.copyWith(fontFamily: 'Harmattan', fontSize: 20);

    TextStyle titleStyleRs = Theme.of(context).textTheme.titleMedium!;
    TextStyle optionsStyleRs = Theme.of(context).textTheme.titleSmall!;

    if (isArabic) {
      titleStyle = titleStyleAs;
      optionsStyle = optionsStyleAs;
    } else {
      titleStyle = titleStyleRs;
      optionsStyle = optionsStyleRs;
    }

    if (!wolof && !wolofal) {
      wolof = true;
      wolofal = true;
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
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 27, color: Theme.of(context).iconTheme.color),
              SizedBox(width: 25),
              // Expanded(child:
              Text(title, style: titleStyle),
              // ),
            ],
          ),
        ),
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
          Expanded(child: setting),
          // setting,
        ],
      );
    }

    Widget settingColumn(title, setting) {
      return Column(
        //This aligns titles to the left
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, setting, Divider()],
      );
    }

    //Now individual implementations of it
    Widget viewListOfNames() {
      return settingTitle(AppLocalizations.of(context)!.listView, Icons.list, () {
        //Part of the names list navigation - this opens the NamesLIst, then gets and then passes on the value from the popped screen
        Navigator.of(context).pushNamed(NamesList.routeName).then((value) {
          if (!context.mounted) return;
          Navigator.of(context).pop(value);
        });
      });
    }

    Widget themeTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsTheme,
        Icons.settings_brightness,
        null,
      );
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
        Colors.grey,
      ];

      List<DropdownMenuItem<String>> menuItems = [];

      for (var color in themeColors) {
        menuItems.add(
          DropdownMenuItem(
            value: colorToInt(color).toString(),
            child: Material(
              shape: CircleBorder(side: BorderSide.none),
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                margin: EdgeInsets.all(0),
                width: 36,
              ),
            ),
          ),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton(
            itemHeight: 48,
            underline: SizedBox(),
            value: colorToInt(userTheme!.color).toString(),
            items: menuItems,
            onChanged: (response) {
              int colorValue = int.parse(response.toString());

              Color color = colorFromInt(colorValue);

              ThemeComponents themeToSet = ThemeComponents(
                brightness: userTheme.brightness,
                color: color,
              );

              themeProvider.setTheme(themeToSet);
            },
          ),
          Container(
            height: 45,
            width: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              ThemeComponents themeToSet = ThemeComponents(
                brightness: Brightness.light,
                color: userTheme.color,
              );

              themeProvider.setTheme(themeToSet);
            },
            child: userTheme.brightness == Brightness.light
                ? Icon(Icons.check, color: Colors.black)
                : null,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              ThemeComponents themeToSet = ThemeComponents(
                brightness: Brightness.dark,
                color: userTheme.color,
              );

              themeProvider.setTheme(themeToSet);
            },
            child: userTheme.brightness == Brightness.dark
                ? Icon(Icons.check, color: Colors.white)
                : null,
          ),
        ],
      );
    }

    Widget backgroundTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsCardBackground,
        Icons.image,
        null,
      );
    }

    Widget directionTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsCardDirection,
        Icons.compare_arrows,
        null,
      );
    }

    Widget scriptPickerTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsVerseDisplay,
        Icons.format_quote,
        null,
      );
    }

    Widget showFavsTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsShowFavs,
        Icons.favorite,
        null,
      );
    }

    Widget lowPowerModeTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.powerMode,
        Icons.bolt,
        null,
      );
    }

    Widget languageTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsLanguage,
        Icons.translate,
        null,
      );
    }

    Widget backgroundSettings() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              cardPrefs.savePref('imageEnabled', false);
              setState(() {});
            },
            child: cardPrefs.cardPrefs.imageEnabled
                ? null
                : Icon(Icons.check, color: Colors.black),
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
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/7.jpg'),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                ),
                child: cardPrefs.cardPrefs.imageEnabled
                    ? Icon(Icons.check, color: Colors.white)
                    : null,
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
                label: Row(
                  children: [
                    Text("(abc)", style: optionsStyle),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward),
                  ],
                ),
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
                    Text("(بدف)", style: optionsStyle),
                    SizedBox(width: 6),
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

    Widget switchRow({
      required String label,
      required bool value,
      required void Function(bool)? onChanged,
    }) {
      return Row(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          SizedBox(width: 80),
          Expanded(child: Text(label, style: optionsStyle)),
          SizedBox(width: 8),
          Switch(
            activeThumbColor: activeSwitchColor,
            activeTrackColor: activeControlColor,
            value: value,
            onChanged: onChanged,
          ),
          isPhone ? SizedBox(width: 8) : SizedBox(width: 80),
        ],
      );
    }

    Widget asScriptPicker() {
      return switchRow(
        label: AppLocalizations.of(context)!.settingsVerseinWolofal,
        value: wolofal,
        onChanged: (_) {
          if (wolof) {
            cardPrefs.savePref('wolofalVerseEnabled', !wolofal);
            //but if wolof is not on and you're trying to turn of wolofal, turn on wolof.
          } else if (!wolof && wolofal) {
            cardPrefs.savePref('wolofalVerseEnabled', false);
            cardPrefs.savePref('wolofVerseEnabled', true);
          }

          setState(() {});
        },
      );
    }

    Widget rsScriptPicker() {
      return switchRow(
        label: AppLocalizations.of(context)!.settingsVerseinWolof,
        value: wolof,
        onChanged: (_) {
          if (wolofal) {
            cardPrefs.savePref('wolofVerseEnabled', !wolof);
            //but if wolof is not on and you're trying to turn of wolofal, turn on wolof.
          } else if (wolof && !wolofal) {
            cardPrefs.savePref('wolofalVerseEnabled', true);
            cardPrefs.savePref('wolofVerseEnabled', false);
          }

          setState(() {});
        },
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
                  style: optionsStyle,
                ),
                onSelected: (bool selected) async {
                  if (Provider.of<DivineNames>(
                    context,
                    listen: false,
                  ).favoriteNames.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.favsNoneYet,
                          ),
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.favsNoneYetInstructions,
                          ),
                          actions: [
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.ok),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
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
                  style: optionsStyle,
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
      return switchRow(
        label: AppLocalizations.of(context)!.lowPowerMode,
        value: cardPrefs.cardPrefs.lowPower,
        onChanged: (_) {
          cardPrefs.savePref('lowPower', !cardPrefs.cardPrefs.lowPower);
          //This makes it so if the user chooses a setting, we won't ask them again to set to low power, they know where the setting is
          cardPrefs.savePref('shouldTestDevicePerformance', false);
          setState(() {});
        },
      );
    }

    Widget languageSetting() {
      final narrow = mediaQuerySize.width > 575;

      Widget aligner({required Widget child}) {
        return Align(alignment: narrow ? .center : .centerStart, child: child);
      }

      List<Widget> languageChips = [
        //Note that userLocale.toString() evaluates to for example 'fr' in Android/iOS but on the web 'fr_' with the underscore.
        //So three slightly different checks for the three langs:
        //fr_CH checks for fr_CH only
        //fr checks for fr or fr_
        //en checks for contains en
        aligner(
          child: ChoiceChip(
            selectedColor: activeControlColor,
            padding: EdgeInsets.symmetric(horizontal: 10),
            selected: userLocale.toString() == 'fr_CH' ? true : false,
            label: Text("Wolof", style: optionsStyleRs),
            onSelected: (bool selected) {
              themeProvider.setLocale('fr_CH');
            },
          ),
        ),
        aligner(
          child: ChoiceChip(
            selectedColor: activeControlColor,
            padding: EdgeInsets.symmetric(horizontal: 10),
            selected: userLocale.toString() == 'ar' ? true : false,
            label: Text("وࣷلࣷفَلْ", style: optionsStyleAs),
            onSelected: (bool selected) {
              themeProvider.setLocale('ar');
            },
          ),
        ),
        aligner(
          child: ChoiceChip(
            selectedColor: activeControlColor,
            padding: EdgeInsets.symmetric(horizontal: 10),
            selected:
                userLocale.toString() == 'fr' || userLocale.toString() == 'fr_'
                ? true
                : false,
            label: Text("Français", style: optionsStyleRs),
            onSelected: (bool selected) {
              themeProvider.setLocale('fr');
            },
          ),
        ),
        aligner(
          child: ChoiceChip(
            selectedColor: activeControlColor,
            padding: EdgeInsets.symmetric(horizontal: 10),
            selected: userLocale.toString().contains('en') ? true : false,
            label: Text("English", style: optionsStyleRs),
            onSelected: (bool selected) {
              themeProvider.setLocale('en');
            },
          ),
        ),
      ];

      return Padding(
        padding: userLocale.toString() == 'ar'
            ? const EdgeInsets.only(right: 80.0)
            : const EdgeInsets.only(left: 80.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: narrow ? 4 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 15,
          childAspectRatio: 3.2,
          children: languageChips,
        ),
      );

      // return Wrap(
      //   spacing: 15,
      //   runSpacing: 12, // space BETWEEN rows
      //   alignment: .center,
      //   crossAxisAlignment: .center,
      //   direction: Axis.horizontal,

      //   // mediaQuerySize.width > 390
      //   //     ? Axis.horizontal
      //   //     : Axis.vertical,
      //   children: languageChips
      // );
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

    Widget shareAppWidget() {
      return settingTitle(
        AppLocalizations.of(context)!.shareAppLink,
        Icons.share,
        () async {
          Navigator.of(context).pop();
          if (!kIsWeb) {
            Share.share(
              'https://sng.al/99',
              sharePositionOrigin: Rect.fromLTWH(
                0,
                0,
                mediaQuerySize.width,
                mediaQuerySize.height * .33,
              ),
            );
          } else {
            const url =
                "mailto:?subject=99&body=Xoolal appli bi: https://sng.al/99";

            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            } else {
              throw 'Could not launch $url';
            }
          }
        },
      );
    }

    Widget showIntroWidget() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsViewIntro,
        Icons.replay,
        () {
          Navigator.of(context).pushNamed(OnboardingScreen.routeName);
        },
      );
    }

    ///////////////////////////////

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: isArabic
              ? Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontFamily: 'Harmattan',
                  fontSize: 26,
                )
              : Theme.of(context).textTheme.titleLarge,
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
            child: mediaQuerySize.width >= 730
                // tablet
                ? SizedBox(
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
                          shareAppWidget(),
                          Divider(),
                          aboutWidget(),
                          Divider(),
                          contactUsWidget(),
                          Divider(),
                          showIntroWidget(),
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
                      shareAppWidget(),
                      Divider(),
                      aboutWidget(),
                      Divider(),
                      contactUsWidget(),
                      Divider(),
                      showIntroWidget(),
                    ],
                  ),
            // ),
          ),
        ),
      ),
    );
  }

  void showAbout(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    Widget dialogButton(String title) {
      return SizedBox(width: 75, child: Text(title, textAlign: .center));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: .ltr,
          child: AlertDialog(
            // title: Text(packageInfo.appName),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Row(
                    children: [
                      Container(
                        // child: Image.asset('assets/icons/icon.png'),
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              "assets/images/icons/99-icon-round.png",
                            ),
                          ),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                            'Version ${packageInfo.version} (${packageInfo.buildNumber})',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(fontStyle: FontStyle.italic),
                          text: 'Kàddug Yàlla',
                        ),
                        TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          text: ' copyright © 2025 La MBS.',
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          text: 'Appli © 2022-2026 Foundational LLC.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            actions: <Widget>[
              ElevatedButton(
                child: dialogButton('Copyrights'),
                onPressed: () {
                  // Navigator.of(context).pushNamed(AboutScreen.routeName);
                  clearPage(Widget page) => PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, _) => page,
                  );
                  Navigator.push(context, clearPage(const AboutScreen()));
                },
              ),
              SizedBox(height: 6),
              ElevatedButton(
                child: dialogButton('Licenses'),
                onPressed: () {
                  // Navigator.of(context).pop();
                  showLicenses(
                    context,
                    appName: packageInfo.appName,
                    appVersion:
                        '${packageInfo.version} (${packageInfo.buildNumber})',
                  );
                },
              ),
              SizedBox(height: 6),
              ElevatedButton(
                child: dialogButton('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
    Navigator.of(context, rootNavigator: useRootNavigator).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LicensePage(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
        ),
      ),
    );
  }

  showLicensePage(
    context: context,
    applicationVersion: appVersion,
    applicationName: appName,
    useRootNavigator: true,
  );
}
