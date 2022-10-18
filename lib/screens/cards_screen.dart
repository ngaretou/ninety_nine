import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/names.dart';
import '../providers/card_prefs.dart';

import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/fps.dart';

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

  //count of these two events - a danger zone event is less than the given fps rate - a fpsWorking event is when the callback reports a good frame rate.
  int fpsDangerZone = 0;
  int fpsWorking = 0;

  @override
  void initState() {
    CardPrefList cardPrefs =
        Provider.of<CardPrefs>(context, listen: false).cardPrefs;

    goToPage = Provider.of<DivineNames>(context, listen: false).lastNameViewed;
    initializeSession();

    //If already on low power setting, don't bother checking;
    //Also if user has one time chosen a power setting and knows where it is, don't check anymore

    // enableFpsMonitoring(); //for testing; always turns on fps monitoring

    if (kIsWeb) {
      disableFpsMonitoring();
    } else {
      if (cardPrefs.shouldTestDevicePerformance) enableFpsMonitoring();
    }

    super.initState();
  }

  Future<void> enableFpsMonitoring() async {
    print('starting fps test');
    Fps.instance!.start();

    Fps.instance!.addFpsCallback((fpsInfo) {
      // print(fpsInfo);
      // Note below format of fpsInfo object
      // FpsInfo fpsInfo = FpsInfo(fps, totalCount, droppedCount, drawFramesCount);

      //If the reported fps is under 10 fps, not good. Add one observation to danger list, otherwise add one to good list
      (fpsInfo.fps < 10) ? fpsDangerZone++ : fpsWorking++;

      //If we've observed 10 bad fps settings:
      if (fpsDangerZone > 5) enableLightAnimation();
      //If we've observed 15 reports of good working order:
      if (fpsWorking > 15) disableFpsMonitoring();
    });
  }

  Future<void> disableFpsMonitoring() async {
    print('FPS consistently good: disable monitoring');
    Provider.of<CardPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    Fps.instance!.stop();
  }

  Future<void> enableLightAnimation() async {
    print('FPS consistently low: ask to enableLightAnimation');
    Fps.instance!.stop();
    //Set the preference
    Provider.of<CardPrefs>(context, listen: false).savePref('lowPower', true);
    Provider.of<CardPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    setState(() {});

    //Give the user a message and a chance to cancel
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 8),
      content: Text(
        AppLocalizations.of(context).lowPowerModeMessage,
        style: TextStyle(fontSize: 18),
      ),
      action: SnackBarAction(
          //for some reason the action color is not contrasting enough by default
          textColor: Theme.of(context).colorScheme.background,
          label: AppLocalizations.of(context).cancel,
          onPressed: () {
            //undo the lowPower setting
            Provider.of<CardPrefs>(context, listen: false)
                .savePref('lowPower', false);
            setState(() {});
          }),
    ));
  }

  Future<void> initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }

  // Future<void> initializePage() async {
  //   try {
  //     goToPage =
  //         Provider.of<DivineNames>(context, listen: false).lastNameViewed;
  //   } catch (e) {
  //     print('error caught - lastNameViewed not initialized');
  //     goToPage = 1;
  //   }
  // }

  @override
  void dispose() {
    Fps.instance!.stop();
    super.dispose();
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
                  //The response from Settings Screen is only in case of the user selecting a name in List View.
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
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,

      //Open to the requested name
      body: NameCards(goToPage: goToPage),
    );
  }
}

/*
Name Cards PageViewBuilder
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
  late bool isLandscape;

  @override
  void didChangeDependencies() {
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    mediaQuery = MediaQuery.of(context);
    print('${mediaQuery.size.width} x ${mediaQuery.size.height}');

    isPhone = (mediaQuery.size.width + mediaQuery.size.height) <= 1400;
    isLandscape =
        (mediaQuery.orientation == Orientation.landscape) ? true : false;
    divineNames = Provider.of<DivineNames>(context, listen: false);

    //page controller is initialized here and initialPage given
    _pageController = PageController(
      initialPage:
          Provider.of<CardPrefs>(context, listen: false).cardPrefs.showFavs
              ? 0
              : Provider.of<DivineNames>(context, listen: false).lastNameViewed,
      viewportFraction: isPhone ? 1 : 540 / mediaQuery.size.width,
      // viewportFraction: isPhone ? 1 : 540 / mediaQuery.size.width,
      //540 = 400 min card width + 70 on each side padding
      keepPage: false,
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mediaQuery = MediaQuery.of(context);
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

    //This is for when the user chooses a name from List View. The index is passed back up to cards scren then back down here.
    //This only happens after the page is initialized.
    if (divineNames.moveToName == true) {
      _pageController.animateToPage(widget.goToPage!,
          duration: Duration(milliseconds: 700), curve: Curves.ease);
      //reset the session so this only triggers once
      divineNames.moveToName = false;
    }

    late EdgeInsets cardPadding;

    if (isPhone) {
      cardPadding = EdgeInsets.all(20);
    } else {
      if (mediaQuery.size.height < 900) {
        cardPadding = EdgeInsets.symmetric(
          horizontal: 70,
          vertical: 70,
          // vertical: isLandscape ? 70 : (mediaQuery.size.height - 700) / 2,
        );
      } else {
        cardPadding = EdgeInsets.symmetric(
          horizontal: 70,
          vertical: (mediaQuery.size.height - 760) / 2,
          // vertical: isLandscape ? 70 : (mediaQuery.size.height - 700) / 2,
        );
      }
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
                itemBuilder: (ctx, i) =>
                    CardPage(namesToShow[i], isPhone, mediaQuery, cardPadding)),
          ),
        ),
      ),
    );
  }
}

class CardPage extends StatefulWidget {
  final DivineName name;
  final bool isPhone;
  final MediaQueryData mediaQuery;
  final EdgeInsets cardPadding;

  const CardPage(this.name, this.isPhone, this.mediaQuery, this.cardPadding,
      {Key? key})
      : super(key: key);

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  late AudioPlayer player;

  @override
  void initState() {
    player = AudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    // print('disposing');
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {
      // print(event);
    }, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    final cardFront =
        CardFront(widget.name, player, widget.mediaQuery, widget.cardPadding);
    final cardBack =
        CardBack(widget.name, player, widget.mediaQuery, widget.cardPadding);

    // The animation in this app is pretty heavy, so to lighten the load we pass in pre-built elements so they are not rebuilt with each tick of the animation - kind of takes away from the flow of logic for the developer
    return CardAnimator(
      cardFront: cardFront,
      cardBack: cardBack,
      mediaQuery: widget.mediaQuery,
      isPhone: widget.isPhone,
      player: player,
    );
  }
}
