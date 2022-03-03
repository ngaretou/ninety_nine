import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui' as ui;
import '../providers/card_prefs.dart';
import '../providers/names.dart';

import '../widgets/card_icon_bar.dart';

class CardFront extends StatelessWidget {
  final DivineName name;
  final BuildContext context;

  CardFront(
    this.name,
    this.context,
  );
  static const _portraitFontSize = 70.0;
  static const _landscapeFontSize = 50.0;

  @override
  Widget build(BuildContext context) {
    final cardPrefs = Provider.of<CardPrefs>(context, listen: false).cardPrefs!;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    double? adaptiveFontSize;
    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;

    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest is 414 x 896 = 1310.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024

    //if it's portrait mode
    if (mediaQuery.orientation != Orientation.landscape) {
      adaptiveFontSize =
          min(_portraitFontSize * (mediaQuery.size.width / 320), 70);
    } else if (mediaQuery.orientation == Orientation.landscape) {
      // adaptiveFontSize = min(_portraitFontSize * (mediaQuery.size.width / 320), 75);
      adaptiveFontSize =
          min(_landscapeFontSize * (mediaQuery.size.width / 568), 70);
    }

//Note that the + " " in the arabicName and wolofalName is a hack -
//otherwise as of Sep 24 2020 teh end of hte line gets cut off
//Tried Padding widget around but the problem is the Text widget itslef not seeing how much space is needed
    Widget arabicNameFront(mediaQuery, names) {
      return Text(" " + names.arabicName + " ",
          textAlign: TextAlign.center,
          style: TextStyle(
              // height: 1.3,
              color: Colors.white,
              fontFamily: "Harmattan",
              fontSize: adaptiveFontSize),
          textDirection: rtlText);
    }

    Widget wolofalNameFront(mediaQuery, names) {
      return Text(
        " " + names.wolofalName + " ",
        //change
        // 'دࣹ اَلّ هِيرِنْ',
        textAlign: TextAlign.center,
        style: TextStyle(
            // height: 1,
            color: Colors.white,
            fontFamily: "Harmattan",
            fontSize: adaptiveFontSize),
        textDirection: rtlText,
      );
    }

    Widget wolofNameFront(mediaQuery, names) {
      return Text(names.wolofName,
          //change
          // 'The All-Hearing',
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1,
            fontFamily: "Harmattan",
            color: Colors.white,
            fontSize: adaptiveFontSize,
          ),
          textDirection: ltrText);
    }

    return Container(
      //with background image or not?
      decoration: cardPrefs.imageEnabled!
          ? BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/${name.img}.jpg"),
              ),
            )
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(.9),
              Colors.black.withOpacity(.3)
            ],
          ),
        ),
        //Card text
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: isLandscape
              // Landscape version
              ? Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(width: 20),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: wolofNameFront(mediaQuery, name)),
                          VerticalDivider(
                              color: Theme.of(context).primaryColor,
                              thickness: 3,
                              width: 100),
                          Expanded(child: arabicNameFront(mediaQuery, name)),
                          VerticalDivider(
                              color: Theme.of(context).primaryColor,
                              thickness: 3,
                              width: 100),
                          Expanded(
                            child: wolofalNameFront(mediaQuery, name),
                          ),
                        ],
                      ),
                    ),
                    //Favorite Button - in landscape
                    Expanded(flex: 1, child: CardIconBar(name, context)),
                  ],
                )
              //Portrait version
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: SizedBox(width: 20)),
                    Expanded(
                        flex: 2,
                        //This Align widget aligns vertically here
                        child: Align(
                            alignment: Alignment.center,
                            child: arabicNameFront(mediaQuery, name))),
                    Divider(
                        color: Theme.of(context).primaryColor, thickness: 3),
                    Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: wolofalNameFront(mediaQuery, name)),
                        )),
                    Divider(
                        color: Theme.of(context).primaryColor, thickness: 3),
                    Expanded(
                        flex: 2,
                        child: Align(
                            alignment: Alignment.center,
                            child: wolofNameFront(mediaQuery, name))),
                    Expanded(
                      child: CardIconBar(name, context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
