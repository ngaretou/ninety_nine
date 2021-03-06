import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/animation.dart';

import '../providers/card_prefs.dart';
import '../providers/names.dart';

import '../widgets/card_front.dart';
import '../widgets/card_back.dart';

class NameCards extends StatefulWidget {
  //This goToPage is only in case of a name chosen in list view. It is passed up from list view page and then back down here.
  final int goToPage;

  NameCards({Key key, @required this.goToPage}) : super(key: key);

  @override
  _NameCardsState createState() => _NameCardsState();
}

class _NameCardsState extends State<NameCards>
    with SingleTickerProviderStateMixin {
  bool initialized;

  AnimationController _animationController;
  Animation<double> _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  PageController _pageController;
  @override
  void initState() {
    print('NameCards initState');
    super.initState();
    initialized = false;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
        //other good curve here is easeInOutBack
        //https://api.flutter.dev/flutter/animation/Curves-class.html
        parent: _animationController,
        curve: Curves.ease)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
    //page controller is initialized here and initialPage given
    _pageController = PageController(
      initialPage:
          Provider.of<CardPrefs>(context, listen: false).cardPrefs.showFavs
              ? 0
              : Provider.of<DivineNames>(context, listen: false).lastPageViewed,
      viewportFraction: 1,
      keepPage: false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  //This whole page is mainly to set up and provide a framework for the animation in a stateful widget,
  //then the stateless widgets are the CardFront and CardBack.
  @override
  Widget build(BuildContext context) {
    print('NameCards build method');

    final divineNames = Provider.of<DivineNames>(context);

    final cardPrefs = Provider.of<CardPrefs>(context, listen: false);
    //If you get this far, you've seen the onboarding, so don't show again
    cardPrefs.savePref('showOnboarding', false);
    //If you are just looking at favs or if you are looking at all names
    final namesToShow = cardPrefs.cardPrefs.showFavs
        ? divineNames.favoriteNames
        : divineNames.names ?? divineNames.names;

    final mediaQuery = MediaQuery.of(context);
    // final isLandscape = mediaQuery.orientation == Orientation.landscape;

    //The initial page should be the last viewed page, which gets stored on each
    // page turn. But, if it's favs, start at the first one (index 0). Then when you go back to
    // viewing all, go back to last viewed page.

    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024

    final bool _isPhone = (MediaQuery.of(context).size.width +
            MediaQuery.of(context).size.height) <=
        1400;
    // print(_isPhone);
    // print(
    //     MediaQuery.of(context).size.width + MediaQuery.of(context).size.height);
    // print(MediaQuery.of(context).size.width);
    // print(MediaQuery.of(context).size.height);

    final Matrix4 phoneTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.002)
      ..rotateY(pi * _animation.value)
      // I want it to go from .9 to 1.0
      // So start at 1 - .1
      ..scale(.9 + (.1 * _animation.value), .9 + (.1 * _animation.value));

    final Matrix4 tabletTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.0005)
      ..rotateY(pi * _animation.value)
      // I want it to go from .9 to 1.0
      // So start at 1 - .1
      ..scale(.75 + (.1 * _animation.value), .75 + (.1 * _animation.value));

//This is for when the user chooses a name from List View. The index is passed back up to cards scren then back down here.
//This only happens after the page is initialized.

    if (initialized) {
      // _pageController.jumpToPage(widget.goToPage);
      _pageController.animateToPage(widget.goToPage,
          duration: Duration(milliseconds: 700), curve: Curves.ease);
    }
    initialized = true;

    return Center(
        child: Stack(children: [
      Container(
        height: (mediaQuery.size.height),
        child: PageView.builder(
            //Controls from card preferences the card flow direction
            reverse: cardPrefs.cardPrefs.textDirection,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            onPageChanged: (index) {
              //Here we want the user to be able to come back to the name they were on even if they
              //switch temporarily to favorites - so save lastpage viewed only when not viewing favs
              if (!cardPrefs.cardPrefs.showFavs) {
                divineNames.saveLastNameViewed(index);
              }
              if (_animationStatus != AnimationStatus.dismissed) {
                _animationController.reverse();
              }
            },
            itemCount: namesToShow.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                // key: _listKey,
                value: namesToShow[i],
                child: Transform(
                  alignment: FractionalOffset.center,
                  transform: (_isPhone) ? phoneTransform : tabletTransform,
                  child: GestureDetector(
                    onTap: () {
                      if (_pageController.page == i) {
                        if (_animationStatus == AnimationStatus.dismissed) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
                      }

                      // print('in onTap');
                    },
                    child: _animation.value <= 0.5
                        ? CardFront(namesToShow[i], context)
                        : CardBack(namesToShow[i], context),
                  ),
                ))),
      )
    ]));
    //Media Player
  }
}
