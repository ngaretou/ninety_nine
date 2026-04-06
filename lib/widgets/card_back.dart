import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import '../l10n/app_localizations.dart'; // the new Flutter 3.x localization method

import '../providers/card_prefs.dart';
import '../providers/names.dart';
import '../providers/theme.dart';
import 'package:just_audio/just_audio.dart';
import 'card_icon_bar.dart';

// const darkBackground = AssetImage("assets/images/black-bg-1.jpg");
// const lightBackground = AssetImage("assets/images/white-bg-2.jpg");

class CardBack extends StatelessWidget {
  final DivineName name;
  final AudioPlayer player;
  final MediaQueryData mediaQuery;
  final EdgeInsets cardPadding;

  const CardBack(
    this.name,
    this.player,
    this.mediaQuery,
    this.cardPadding, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('card back build ${name.id}');
    // debugPrint('card padding bottom ${cardPadding.bottom}');
    CardPrefList cardPrefs = Provider.of<CardPrefs>(
      context,
      listen: false,
    ).cardPrefs;
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    final bool isDark = themeModel.userTheme!.brightness == Brightness.dark;
    final String chosenLang = themeModel.userLocale.toString();
    final ui.TextDirection rtlText = ui.TextDirection.rtl;
    final Color fontColor = isDark ? Colors.white : Colors.black;

    bool isPhone = (mediaQuery.size.width + mediaQuery.size.height) <= 1400;

    Widget textRS(input, double fontReduction, {String fontFamily = 'Charis'}) {
      return Text(
        input,
        textDirection: .ltr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: fontColor,
          fontFamily: fontFamily,
          fontSize: 30 - fontReduction,
        ),
      );
    }

    Widget textAS(String input, double fontReduction) {
      String textToRender = input;

      //This is to fix a problem not in regular web but in mobile web,
      //but is identical in regular desktop web
      if (kIsWeb) {
        textToRender = input.replaceAll(RegExp(r'-'), '-\u200f');
        textToRender = textToRender.replaceAll(RegExp(r'،'), '،\u200f');
      }

      return Text(
        textToRender,

        textAlign: TextAlign.center,
        style: TextStyle(
          color: fontColor,
          fontFamily: "Harmattan",
          fontSize: 40 - fontReduction,
        ),
        textDirection: rtlText,
      );
    }

    BoxDecoration adaptiveBackground() {
      late BoxDecoration boxDecoration;

      if (Provider.of<CardPrefs>(
        context,
        listen: false,
      ).cardPrefs.imageEnabled) {
        boxDecoration = BoxDecoration(
          borderRadius: isPhone
              ? BorderRadius.circular(0)
              : BorderRadius.circular(20.0),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: isDark ? darkBackground : lightBackground,
          ),
        );
      } else {
        boxDecoration = BoxDecoration(
          borderRadius: isPhone
              ? BorderRadius.circular(0)
              : BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            colors: [Colors.black.withAlpha(77), Colors.black.withAlpha(25)],
          ),
        );
      }
      return boxDecoration;
    }

    //Card back does not have alternate layouts for portrait and landscape
    return SizedBox(
      //This Container and height seems superfluous but must be here to help the low animation not go weird
      height: mediaQuery.size.height,
      child: Padding(
        padding: isPhone ? EdgeInsets.all(0) : cardPadding,
        child: Stack(
          children: [
            Container(
              height: isPhone
                  ? mediaQuery.size.height
                  : mediaQuery.size.height - (cardPadding.top * 2),
              decoration: adaptiveBackground(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: isPhone
                      ? BorderRadius.circular(0.0)
                      : BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.black.withAlpha(77),
                      Colors.black.withAlpha(25),
                    ],
                  ),
                ),
                child: Padding(
                  padding: isPhone
                      ? EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          // this prevents the text from going behind the status bar
                          top: cardPadding.top,
                        )
                      : EdgeInsets.symmetric(horizontal: 20.0),
                  // On Android, a ListView (and CustomScrollView, SingleChildScrollView, etc.)
                  // automatically applies MediaQuery padding at the top to avoid the status bar and system UI.
                  // To get the names to line up at the top but then have the Padding enable it to slide into invisibility,
                  // remove the auto padding
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: isPhone ? true : false,
                    child: ListView(
                      children: [
                        //Name Header
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(child: textRS(name.wolofName, 0)),
                            VerticalDivider(
                              color: Theme.of(context).primaryColor,
                              thickness: 1,
                            ),
                            Expanded(child: textAS(name.wolofalName, 0)),
                          ],
                        ),
                        // Wolofal verse section
                        cardPrefs.wolofalVerseEnabled
                            ? Column(
                                children: [
                                  Divider(
                                    color: Theme.of(context).primaryColor,
                                    thickness: 1,
                                  ),
                                  textAS(name.wolofalVerse, 0.0),
                                  textAS(name.wolofalVerseRef, 10.0),
                                ],
                              )
                            : SizedBox(width: 20),
                        //Wolof verse section
                        cardPrefs.wolofVerseEnabled
                            ? Column(
                                children: [
                                  Divider(
                                    color: Theme.of(context).primaryColor,
                                    thickness: 1,
                                  ),
                                  textRS(name.wolofVerse, 0.0),
                                  SizedBox(height: 20),
                                  textRS(name.wolofVerseRef, 10.0),
                                ],
                              )
                            : SizedBox(width: 20),
                        SizedBox(height: 60),
                        TextButton(
                          // style: TextButton.styleFrom(
                          //     backgroundColor: Theme.of(context)
                          //         .colorScheme
                          //         .tertiaryContainer),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              chosenLang == 'ar'
                                  ? Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: textAS(
                                        AppLocalizations.of(
                                          context,
                                        )!.clickHereToReadMore,
                                        16.0,
                                      ),
                                    )
                                  : textRS(
                                      AppLocalizations.of(
                                        context,
                                      )!.clickHereToReadMore,
                                      10.0,
                                      fontFamily: 'Harmattan',
                                    ),
                              Icon(Icons.arrow_forward, color: fontColor),
                            ],
                          ),
                          onPressed: () async {
                            const String url = 'https://sng.al/chrono';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                        SizedBox(height: 90),
                        // ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: isPhone
                  ? EdgeInsets.only(bottom: cardPadding.bottom + 8)
                  : EdgeInsets.only(bottom: 20),
              child: CardIconBar(name, player),
            ),
          ],
        ),
      ),
    );
  }
}
