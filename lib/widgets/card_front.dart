import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/card_prefs.dart';
import '../providers/names.dart';

import '../widgets/card_icon_bar.dart';

class CardFront extends StatelessWidget {
  final DivineName name;
  final MediaQueryData mediaQuery;

  const CardFront(this.name, this.mediaQuery, {Key? key}) : super(key: key);

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

/*
The ParentDataWidget Expanded(flex: 1) wants to apply ParentData of type FlexParentData to a RenderObject, which has been set up to accept ParentData of incompatible type ParentData.

Usually, this means that the Expanded widget has the wrong ancestor RenderObjectWidget. Typically, Expanded widgets are placed directly inside Flex widgets.
The offending Expanded is currently placed inside a FittedBox widget.

*/
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
              height: 1,
              fontFamily: "Harmattan",
              color: Colors.white,
              fontSize: adaptiveFontSize,
            ),
            textDirection: ltrText),
      );
    }

    EdgeInsets cardFrontPadding =
        _isPhone ? EdgeInsets.all(20) : EdgeInsets.all(70);

    Widget verticalDivider = Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Container(
            height: 150,
            width: 2,
            color: Theme.of(context).colorScheme.outline));

    return Container(
      //This is important as it dictates the outer boundaries for what follows
      height: mediaQuery.size.height,
      child: Padding(
        padding: cardFrontPadding,
        child: Container(
          //with background image or not?
          decoration: Provider.of<CardPrefs>(context, listen: false)
                  .cardPrefs
                  .imageEnabled
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
                  // Landscape/tablet version
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
                        Expanded(flex: 7, child: CardIconBar(name, context)),
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
                        Expanded(child: CardIconBar(name, context)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
