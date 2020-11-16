import 'package:flutter/material.dart';
// import 'package:ninety_nine/screens/cards_screen.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'dart:math';
import 'dart:ui' as ui;
import '../providers/card_prefs.dart';
import '../providers/names.dart';
import '../locale/app_localization.dart';

class NamesList extends StatelessWidget {
  static const routeName = 'names-list-screen';
  @override
  Widget build(BuildContext context) {
    final names = Provider.of<DivineNames>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    //Make sure you're showing all, not favorites
    TextStyle _asStyle = TextStyle(
        // height: 1.3,
        color: Theme.of(context).textTheme.headline6.color,
        fontFamily: "Harmattan",
        fontSize: 32);

    TextStyle _rsStyle = TextStyle(
        // height: 1.3,
        color: Theme.of(context).textTheme.headline6.color,
        fontFamily: "Lato",
        fontSize: 22);
    ui.TextDirection _rtlText = ui.TextDirection.rtl;
    ui.TextDirection _ltrText = ui.TextDirection.ltr;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'List View',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        //If the width of the screen is greater or equal to 500
        //show the wide view
        body: Padding(
          padding: mediaQuery.size.width >= 730
              ? EdgeInsets.symmetric(horizontal: 50)
              : EdgeInsets.symmetric(horizontal: 10),
          child: ScrollablePositionedList.builder(
            itemCount: names.names.length,
            itemBuilder: (ctx, i) => GestureDetector(
              child: Card(
                elevation: 5,
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(names.names[i].wolofName,
                              style: _rsStyle, textDirection: _ltrText)),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(names.names[i].wolofalName,
                              style: _asStyle, textDirection: _rtlText),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(names.names[i].arabicName,
                            style: _asStyle, textDirection: _rtlText),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                //Resets to show all cards rather than favs
                Provider.of<CardPrefs>(context, listen: false)
                    .savePref('showFavs', false);
                //Closes this screen and sends index of the chosen name up the tree
                Navigator.of(context).pop(i);
              },
            ),
          ),
        ));
  }
}
