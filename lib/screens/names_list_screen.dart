import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:ui' as ui;
import '../providers/card_prefs.dart';
import '../providers/names.dart';
import '../l10n/app_localizations.dart'; // the new Flutter 3.x localization method
import 'cards_screen.dart';

class NamesList extends StatelessWidget {
  static const routeName = 'names-list-screen';

  const NamesList({super.key});

  @override
  Widget build(BuildContext context) {
    final names = Provider.of<DivineNames>(context, listen: false);

    TextStyle asStyle = TextStyle(
      // height: 1.3,
      color: Theme.of(context).textTheme.titleLarge!.color,
      fontFamily: "Harmattan",
      fontSize: 32,
    );

    TextStyle rsStyle = TextStyle(
      // height: 1.3,
      color: Theme.of(context).textTheme.titleLarge!.color,
      fontFamily: "Lato",
      fontSize: 22,
    );

    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;

    double mediaQueryWidth = MediaQuery.of(context).size.width;

    String insertSpaces(String name) {
      String nameToReturn = name;

      if (kIsWeb) nameToReturn = '$name ';

      return nameToReturn;
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.listView)),
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      //If the width of the screen is greater or equal to 500
      //show the wide view
      body: Directionality(
        textDirection: .ltr,
        child: ScrollConfiguration(
          //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
          behavior: MyCustomScrollBehavior().copyWith(scrollbars: false),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: SizedBox(
                width: mediaQueryWidth >= 730 ? 730 : mediaQueryWidth,
                child: ScrollablePositionedList.builder(
                  itemCount: names.names.length,
                  itemBuilder: (ctx, i) => GestureDetector(
                    child: Card(
                      elevation: 5,

                      // color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                names.names[i].wolofName,
                                style: rsStyle,
                                textDirection: ltrText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  insertSpaces(names.names[i].wolofalName),
                                  style: asStyle,
                                  textDirection: rtlText,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                names.names[i].arabicName,
                                style: asStyle,
                                textDirection: rtlText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      debugPrint('tapped');
                      //Resets to show all cards rather than favs
                      Provider.of<CardPrefs>(
                        context,
                        listen: false,
                      ).savePref('showFavs', false);
                      //This is a hacky marker that shows the app we should navigate -
                      //This is trickier than it sounds as the build gets triggered with all the animation
                      Provider.of<DivineNames>(
                        context,
                        listen: false,
                      ).moveToName = true;
                      //Closes this screen and sends index of the chosen name up the tree
                      Navigator.of(context).pop(i);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
