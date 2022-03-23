import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/card_prefs.dart';
import '../providers/names.dart';
import '../providers/fps.dart';

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

class NameCards extends StatefulWidget {
  final int? goToPage;
  final bool newSession;

  NameCards({Key? key, required this.goToPage, this.newSession = true})
      : super(key: key);

  @override
  _NameCardsState createState() => _NameCardsState();
}

class _NameCardsState extends State<NameCards>
    //This has to do with the animation and teh vsync:this, required under AnimationController(s)
    with
        SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  PageController _pageController = PageController();
  bool? rightToLeft;
  int fpsDangerZone = 0;
  int fpsWorking = 0;

  late DivineNames divineNames;
  late CardPrefs cardPrefs;
  late List<DivineName> namesToShow;

  late MediaQueryData mediaQuery;
  late bool _isPhone;

  @override
  void initState() {
    print('NameCards initState');

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

    // Fps.instance!.start();
    // Fps.instance!.addFpsCallback((fpsInfo) {
    //   // print(widget.goToPage.toString() + " " + fpsInfo.toString());
    //   // FpsInfo fpsInfo = FpsInfo(fps, totalCount, droppedCount, drawFramesCount);
    //   ((fpsInfo.drawFramesCount * 2) < fpsInfo.droppedFramesCount)
    //       ? fpsDangerZone++
    //       : fpsWorking++;

    //   if (fpsDangerZone > 5) enableLightAnimation();
    //   if (fpsWorking > 15) disableFpsMonitoring();
    // });

    divineNames = Provider.of<DivineNames>(context, listen: false);

    cardPrefs = Provider.of<CardPrefs>(context, listen: false);

    //If you are just looking at favs or if you are looking at all names.
    //The initial page should be the last viewed page, which gets stored on each
    // page turn. But, if it's favs, start at the first one (index 0). Then when you go back to
    // viewing all, go back to last viewed page.
    namesToShow =
        Provider.of<CardPrefs>(context, listen: false).cardPrefs.showFavs
            ? divineNames.favoriteNames
            : divineNames.names;

    super.initState();
  }

  Future<void> enableLightAnimation() async {
    Fps.instance!.removeFpsCallback((fpsInfo) {});
    print('FPS consistently low: ask to enableLightAnimation');

    // showDialog(context: context, builder: builder);
    //Snackbar?
  }

  Future<void> disableFpsMonitoring() async {
    Fps.instance!.removeFpsCallback((fpsInfo) {});
    print('FPS consistently good: disable monitoring');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    Fps.instance!.stop();
    super.dispose();
  }

  //This whole page is mainly to set up and provide a framework for the animation in a stateful widget,
  //then the stateless widgets are the CardFront and CardBack.
  @override
  Widget build(BuildContext context) {
    print('NameCards build method');

    //These transforms have to be in teh build as they calculate with the animation
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

    //page controller is initialized here and initialPage given
    _pageController = PageController(
      initialPage:
          Provider.of<CardPrefs>(context, listen: false).cardPrefs.showFavs
              ? 0
              : Provider.of<DivineNames>(context, listen: false).lastNameViewed,
      viewportFraction: 1,
      keepPage: false,
    );

    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    mediaQuery = MediaQuery.of(context);
    _isPhone = (mediaQuery.size.width + mediaQuery.size.height) <= 1400;

    //This is for when the user chooses a name from List View. The index is passed back up to cards scren then back down here.
    //This only happens after the page is initialized.
    if (divineNames.moveToName == true) {
      _pageController.animateToPage(widget.goToPage!,
          duration: Duration(milliseconds: 700), curve: Curves.ease);
      //reset the session so this only triggers once
      divineNames.moveToName = false;
    }

    // ignore: unused_element
    Widget animatedBuilderVersion(i) {
      return AnimatedBuilder(
          animation: _animationController,
          // child: new CardFront(namesToShow[i], mediaQuery),
          child: _animation.value <= 0.5
              ? CardFront(namesToShow[i], mediaQuery)
              : CardBack(namesToShow[i], _isPhone),
          builder: (BuildContext context, Widget? child) {
            return Transform(
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
                child: child,
              ),
            );
          });
    }

    // ignore: unused_element
    Widget nonAnimatedBuilderVersion(i) {
      return Transform(
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
              ? CardFront(namesToShow[i], mediaQuery)
              : CardBack(namesToShow[i], _isPhone),
        ),
      );
    }

    return ScrollConfiguration(
      //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
      behavior: MyCustomScrollBehavior().copyWith(scrollbars: false),
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Stack(children: [
            Container(
              height: (mediaQuery.size.height),
              child: PageView.builder(
                  //Controls the card flow direction - LTR or RTL - from card preferences; it is a bool, so note true = RTL.
                  reverse: Provider.of<CardPrefs>(context, listen: false)
                      .cardPrefs
                      .textDirection,
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
                    final cardBack = CardBack(namesToShow[i], _isPhone);

                    return ChangeNotifierProvider.value(
                      value: namesToShow[i],
                      child: AnimatedBuilder(
                        animation: _animationController,
                        child: _animation.value <= 0.5 ? cardFront : cardBack,
                        builder: (BuildContext context, Widget? child) =>
                            Transform(
                          alignment: FractionalOffset.center,
                          transform:
                              (_isPhone) ? phoneTransform : tabletTransform,
                          child: GestureDetector(
                            onTap: () {
                              if (_pageController.page == i) {
                                if (_animationStatus ==
                                    AnimationStatus.dismissed) {
                                  _animationController.forward();
                                } else {
                                  _animationController.reverse();
                                }
                              }

                              // print('in onTap');
                            },
                            child: child,
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ]),
        ),
      ),
    );
    //Media Player
  }
}
