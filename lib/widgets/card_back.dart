import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/card_prefs.dart';
import '../providers/names.dart';
import '../providers/theme.dart';

const darkBackground = AssetImage("assets/images/black-bg-1.jpg");
const lightBackground = AssetImage("assets/images/white-bg-2.jpg");

class CardBack extends StatelessWidget {
  final DivineName name;
  final Widget cardIconBar;
  final MediaQueryData mediaQuery;
  final EdgeInsets cardPadding;

  const CardBack(
    this.name,
    this.cardIconBar,
    this.mediaQuery,
    this.cardPadding,
  );

  @override
  Widget build(BuildContext context) {
    print('card back build ' + name.id.toString());
    CardPrefList cardPrefs =
        Provider.of<CardPrefs>(context, listen: false).cardPrefs;
    final bool _isDark =
        Provider.of<ThemeModel>(context, listen: false).userTheme!.brightness ==
            Brightness.dark;
    final ui.TextDirection rtlText = ui.TextDirection.rtl;
    final Color _fontColor = _isDark ? Colors.white : Colors.black;

    bool _isPhone = (mediaQuery.size.width + mediaQuery.size.height) <= 1400;

    Widget textRS(input, double fontReduction) {
      return Text(
        input,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _fontColor,
          fontFamily: "Charis",
          fontSize: 30 - fontReduction,
        ),
      );
    }

    Widget textAS(input, double fontReduction) {
      return Text(
        input,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _fontColor,
          fontFamily: "Harmattan",
          fontSize: 40 - fontReduction,
        ),
        textDirection: rtlText,
      );
    }

    BoxDecoration adaptiveBackground() {
      late BoxDecoration _boxDecoration;

      if (Provider.of<CardPrefs>(context, listen: false)
          .cardPrefs
          .imageEnabled) {
        _boxDecoration = BoxDecoration(
          color: Colors.yellow[50],
          borderRadius:
              _isPhone ? BorderRadius.circular(0) : BorderRadius.circular(20.0),
          gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
            Colors.black.withOpacity(.3),
            Colors.black.withOpacity(.0)
          ]),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: _isDark ? darkBackground : lightBackground,
          ),
        );
      } else {
        _boxDecoration = BoxDecoration(
          color: Colors.yellow[50],
          borderRadius:
              _isPhone ? BorderRadius.circular(0) : BorderRadius.circular(20.0),
          gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
            Colors.black.withOpacity(.3),
            Colors.black.withOpacity(.0)
          ]),
        );
      }
      return _boxDecoration;
    }

    //Card back does not have alternate layouts for portrait and landscape
    return Container(
      //This Container and height seems superfluous but must be here to help the low animation not go weird
      height: mediaQuery.size.height,
      child: Padding(
        padding: _isPhone ? EdgeInsets.all(0) : cardPadding,
        child: Stack(
          children: [
            Container(
              height: _isPhone
                  ? mediaQuery.size.height
                  : mediaQuery.size.height - (cardPadding.top * 2),
              decoration: adaptiveBackground(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: _isPhone
                      ? BorderRadius.circular(0.0)
                      : BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(.3),
                      Colors.black.withOpacity(.0)
                    ],
                  ),
                ),
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // children: [
                        //Name Header
                        Row(
                          children: [
                            Expanded(child: textRS(name.wolofName, 0)),
                            VerticalDivider(
                              color: Theme.of(context).primaryColor,
                              thickness: 3,
                            ),
                            Expanded(
                              child: textAS(name.wolofalName, 0),
                            ),
                          ],
                        ),
                        // Wolofal verse section
                        cardPrefs.wolofalVerseEnabled
                            ? Column(
                                children: [
                                  Divider(
                                    color: Theme.of(context).primaryColor,
                                    thickness: 3,
                                  ),
                                  textAS(name.wolofalVerse, 0.0),
                                  textAS(name.wolofalVerseRef, 10.0)
                                ],
                              )
                            : SizedBox(width: 20),
                        //Wolof verse section
                        cardPrefs.wolofVerseEnabled
                            ? Column(
                                children: [
                                  Divider(
                                    color: Theme.of(context).primaryColor,
                                    thickness: 3,
                                  ),
                                  textRS(name.wolofVerse, 0.0),
                                  SizedBox(height: 20),
                                  textRS(name.wolofVerseRef, 10.0),
                                ],
                              )
                            : SizedBox(width: 20),
                        SizedBox(height: 60),
                        TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  AppLocalizations.of(context)
                                      .clickHereToReadMore,
                                  style: TextStyle(color: _fontColor)),
                              Icon(Icons.arrow_forward, color: _fontColor),
                            ],
                          ),
                          onPressed: () async {
                            const String url = 'https://sng.al/chrono';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                        SizedBox(
                          height: 70,
                        ),
                        // ],
                      ],
                    )),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: cardIconBar,
            ),
          ],
        ),
      ),
    );
  }
}
