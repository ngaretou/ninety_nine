import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/names.dart';
import '../providers/card_prefs.dart';

import './settings_screen.dart';

import '../widgets/card_animator.dart';
import '../widgets/card_front.dart';
import '../widgets/card_back.dart';

//To adapt to new Flutter 2.8 behavior that does not allow mice to drag - which is our desired behavior here
class MyCustomScrollBehavior extends ScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

// CardsScreen framework - Scaffold etc
class CardsScreen extends StatefulWidget {
  static const routeName = '/cards-screen';

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int goToPage = 1;

  @override
  void initState() {
    //initially set here but
    initializePage();
    super.initState();
  }

  Future<void> initializePage() async {
    try {
      goToPage =
          Provider.of<DivineNames>(context, listen: false).lastNameViewed;
    } catch (e) {
      print('error caught');
      goToPage = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('card_screen build');
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
              onPressed: () {
                // Scaffold.of(context).openEndDrawer();
                Navigator.of(context)
                    //Here settings screen is opened.
                    .pushNamed(SettingsScreen.routeName)
                    //The response from Settigns Screen is only in case of the user selecting a name in List View.
                    //See the settings screen and the list view screen for the chain of commands here.
                    .then((value) {
                  if (value != null) {
                    setState(() {
                      goToPage = value as int;
                    });
                  } else {
                    setState(() {});
                  }
                });
              },
              child: Icon(Icons.menu),
              mini: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,

      //Open to the requested name
      body: NameCards(goToPage: goToPage),
    );
  }
}

/*
Name Cards PageViewBuilder - the 
 */
class NameCards extends StatefulWidget {
  final int? goToPage;
  final bool newSession;
  const NameCards({Key? key, required this.goToPage, this.newSession = true})
      : super(key: key);
  @override
  State<NameCards> createState() => _NameCardsState();
}

class _NameCardsState extends State<NameCards> {
  PageController _pageController = PageController();
  bool? rightToLeft;
  late DivineNames divineNames;
  late CardPrefs cardPrefs;
  late List<DivineName> namesToShow;

  late MediaQueryData mediaQuery;
  late bool isPhone;

  @override
  void initState() {
    print('NameCards initState');

    divineNames = Provider.of<DivineNames>(context, listen: false);

    //page controller is initialized here and initialPage given
    _pageController = PageController(
      initialPage:
          Provider.of<CardPrefs>(context, listen: false).cardPrefs.showFavs
              ? 0
              : Provider.of<DivineNames>(context, listen: false).lastNameViewed,
      viewportFraction: 1,
      keepPage: false,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Name Cards PageViewBuilder');

    //We need to get this in the build so it updates when rebuilding on setState
    cardPrefs = Provider.of<CardPrefs>(context, listen: false);

    //If you are just looking at favs or if you are looking at all names.
    //The initial page should be the last viewed page, which gets stored on each
    // page turn. But, if it's favs, start at the first one (index 0). Then when you go back to
    // viewing all, go back to last viewed page.
    namesToShow =
        Provider.of<CardPrefs>(context, listen: false).cardPrefs.showFavs
            ? divineNames.favoriteNames
            : divineNames.names;

    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    mediaQuery = MediaQuery.of(context);
    isPhone = (mediaQuery.size.width + mediaQuery.size.height) <= 1400;

    //This is for when the user chooses a name from List View. The index is passed back up to cards scren then back down here.
    //This only happens after the page is initialized.
    if (divineNames.moveToName == true) {
      _pageController.animateToPage(widget.goToPage!,
          duration: Duration(milliseconds: 700), curve: Curves.ease);
      //reset the session so this only triggers once
      divineNames.moveToName = false;
    }

    return ScrollConfiguration(
      //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
      behavior: MyCustomScrollBehavior().copyWith(scrollbars: false),
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Container(
            height: (mediaQuery.size.height),
            child: PageView.builder(
                //Controls the card flow direction - LTR or RTL - from card preferences; it is a bool, so note true = RTL.
                reverse: cardPrefs.cardPrefs.textDirection,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                onPageChanged: (index) {
                  //Here we want the user to be able to come back to the name they were on even if they
                  //switch temporarily to favorites - so save lastpage viewed only when not viewing favs
                  divineNames.saveLastNameViewed(index);

                  // This flips the cards on swipe back to the picture side
                  // if (_animationStatus != AnimationStatus.dismissed) {
                  //   _animationController.reverse();
                  // }
                },
                itemCount: namesToShow.length,
                itemBuilder: (ctx, i) {
                  final cardFront = CardFront(namesToShow[i], mediaQuery);
                  final cardBack = CardBack(namesToShow[i], mediaQuery);

                  return CardAnimator(
                    cardFront: cardFront,
                    cardBack: cardBack,
                    mediaQuery: mediaQuery,
                    isPhone: isPhone,
                  );
                }),
          ),
        ),
      ),
    );
  }
}
