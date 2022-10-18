import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/card_prefs.dart';
import '../providers/names.dart';
import 'card_icon_bar.dart';
import 'package:just_audio/just_audio.dart';

class CardFront extends StatelessWidget {
  final DivineName name;
  final AudioPlayer player;
  final MediaQueryData mediaQuery;
  final EdgeInsets cardPadding;

  const CardFront(this.name, this.player, this.mediaQuery, this.cardPadding,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('card front build ' + name.id.toString());

    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    const double adaptiveFontSize = 70;
    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;

    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest is 414 x 896 = 1310.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    bool _isPhone = (mediaQuery.size.width + mediaQuery.size.height) <= 1400;

    //Note that the + " " in the arabicName and wolofalName is a hack -
    //otherwise as of Sep 24 2020 teh end of the line gets cut off
    //Tried Padding widget around but the problem is the Text widget itslef not seeing how much space is needed

    Widget arabicNameFront(names) {
      return FittedBox(
        child: Text(" " + names.arabicName + " ",
            textAlign: TextAlign.center,
            style: TextStyle(
                // height: 1.3,
                color: Colors.white,
                fontFamily: "Harmattan",
                fontSize: adaptiveFontSize),
            textDirection: rtlText),
      );
    }

    Widget wolofalNameFront(names) {
      return FittedBox(
        child: Text(
          " " + names.wolofalName + " ",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Harmattan",
              fontSize: adaptiveFontSize),
          textDirection: rtlText,
        ),
      );
    }

    Widget wolofNameFront(names) {
      return FittedBox(
        child: Text(names.wolofName,
            textAlign: TextAlign.center,
            style: TextStyle(
              // height: 1,
              fontFamily: "Harmattan",
              color: Colors.white,
              fontSize: adaptiveFontSize,
            ),
            textDirection: ltrText),
      );
    }

    // int minCardWidth = 400;
    // double horizPadding = (mediaQuery.size.width * .5 - minCardWidth) / 2;

    // horizontal: 70);

    Widget verticalDivider = Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Container(
            height: 150,
            width: 2,
            color: Theme.of(context).colorScheme.outline));

    //Using consts for images.
    //Keeping a limited number of images in memory
    //rather than constanly reloading them
    //seems to offer some performance and memory improvements.
    AssetImage assetImage = assetImage1;
    switch (name.img) {
      case '1':
        {
          assetImage = assetImage1;
        }
        break;
      case '2':
        {
          assetImage = assetImage2;
        }
        break;
      case '3':
        {
          assetImage = assetImage3;
        }
        break;
      case '4':
        {
          assetImage = assetImage4;
        }
        break;
      case '5':
        {
          assetImage = assetImage5;
        }
        break;
      case '6':
        {
          assetImage = assetImage6;
        }
        break;
      case '7':
        {
          assetImage = assetImage7;
        }
        break;
      case '8':
        {
          assetImage = assetImage8;
        }
        break;
      case '9':
        {
          assetImage = assetImage9;
        }
        break;
      case '10':
        {
          assetImage = assetImage10;
        }
        break;
      case '11':
        {
          assetImage = assetImage11;
        }
        break;
      case '12':
        {
          assetImage = assetImage12;
        }
        break;
      case '13':
        {
          assetImage = assetImage13;
        }
        break;
      case '14':
        {
          assetImage = assetImage14;
        }
        break;
      case '15':
        {
          assetImage = assetImage15;
        }
        break;
      case '16':
        {
          assetImage = assetImage16;
        }
        break;
      case '17':
        {
          assetImage = assetImage17;
        }
        break;
      case '18':
        {
          assetImage = assetImage18;
        }
        break;
      case '19':
        {
          assetImage = assetImage19;
        }
        break;
      case '20':
        {
          assetImage = assetImage20;
        }
        break;
      default:
    }

    return Container(
      //This is important as it dictates the outer boundaries for what follows
      height: mediaQuery.size.height,
      // width: _isPhone ? mediaQuery.size.width : mediaQuery.size.height / 3,
      child: Padding(
        padding: cardPadding,
        child: Container(
          //with background image or not?
          decoration: Provider.of<CardPrefs>(context, listen: false)
                  .cardPrefs
                  .imageEnabled
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  image: DecorationImage(
                      fit: BoxFit.cover,

                      //This is the original - now using consts
                      image: AssetImage("assets/images/${name.img}.jpg")),
                  // image: assetImage),
                  // image:AssetImage("assets/images/1.jpg"))
                )
              : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              // gradient: LinearGradient(
              //   begin: Alignment.bottomRight,
              //   colors: [
              //     Colors.black.withOpacity(.9),
              //     Colors.black.withOpacity(.3)
              //   ],
              // ),
            ),

            //Card text
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: isLandscape && _isPhone
                  // Landscape on phone version
                  ? Column(
                      children: [
                        Expanded(flex: 6, child: SizedBox(height: 10)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: wolofNameFront(name)),
                            verticalDivider,
                            Expanded(child: arabicNameFront(name)),
                            verticalDivider,
                            Expanded(
                              child: wolofalNameFront(name),
                            ),
                          ],
                        ),
                        Expanded(
                          flex: 7,
                          child: CardIconBar(name, player),
                        ),
                      ],
                    )

                  //Portrait/phone version
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
                                child: arabicNameFront(name))),
                        Divider(
                          thickness: 2,
                        ),
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: wolofalNameFront(name)),
                            )),
                        Divider(
                          thickness: 2,
                        ),
                        Expanded(
                            flex: 2,
                            child: Align(
                                alignment: Alignment.center,
                                child: wolofNameFront(name))),
                        Expanded(
                          child: CardIconBar(name, player),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
