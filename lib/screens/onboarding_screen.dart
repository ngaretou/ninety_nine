// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import './cards_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/theme.dart';
import '../providers/card_prefs.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding-screen';
  OnboardingScreen({Key? key}) : super(key: key);

  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _totalPages = 4;
  late PageController _pageController;
  int _currentPage = 0;
  late MediaQueryData mediaQuery;
  late bool isPhone;
  late bool isLandscape;
  late EdgeInsets cardPadding;
  late int _value;

  @override
  void didChangeDependencies() {
    mediaQuery = MediaQuery.of(context);
    isPhone = (mediaQuery.size.width + mediaQuery.size.height) <= 1400;
    isLandscape =
        (mediaQuery.orientation == Orientation.landscape) ? true : false;

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
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: isPhone ? 1 : 540 / mediaQuery.size.width,
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  TextStyle introStyle = TextStyle(
      fontFamily: 'Lato',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
        behavior: MyCustomScrollBehavior().copyWith(scrollbars: false),
        child: Center(
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  NotificationListener(
                      onNotification: ((dynamic notification) {
                        // print(notification.toString());
                        if (notification is OverscrollNotification) {
                          // print('in OverscrollNotification true');
                          //negative overscroll is scrolling past first page in the wrong direction - if positive it's past the last page
                          if (notification.overscroll > 0)
                            Navigator.of(context)
                                .popAndPushNamed(CardsScreen.routeName);
                        }
                        return true;
                      }),
                      child: PageView(
                        //Small note here on the physics - this must be ClampingScrollPhysics on iOS to
                        //get the "if you're on the last page of introduction go to main app" function.
                        //otherwise iOS doesn't throw OverscrollNotification.
                        //https://github.com/flutter/flutter/issues/17649
                        physics: ClampingScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          _currentPage = page;
                          setState(() {});
                        },
                        children: <Widget>[
                          _buildPageContent(
                              isShowImageOnTop: false,
                              bgimage: 'assets/images/1.jpg',
                              // image: null,
                              body: AppLocalizations.of(context).introPage1,
                              color: Color(0xFFFF7252)),
                          _buildPageContent(
                              isShowImageOnTop: true,
                              bgimage: 'assets/images/2.jpg',
                              body: AppLocalizations.of(context).introPage2,
                              color: Color(0xFFFFA131)),
                          _buildFormattedPageContent(
                              bgimage: 'assets/images/13.jpg',
                              body: _page3Body(),
                              color: Color(0xFF3C60FF)),
                          _buildFormattedPageContent(
                              bgimage: 'assets/images/4.jpg',
                              body: _page4Body(),
                              color: Color(0xFFFF7252)),
                        ],
                      )),
                  Positioned(
                    width: (mediaQuery.size.width *
                            _pageController.viewportFraction) -
                        (cardPadding.left * 3),
                    bottom: cardPadding.bottom,
                    // left: (mediaQuery.size.width -
                    //     (mediaQuery.size.width *
                    //         _pageController.viewportFraction)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: (mediaQuery.size.width *
                                  _pageController.viewportFraction) -
                              (cardPadding.left * 3),
                          child: Row(
                            children: [
                              Container(
                                child: Row(children: [
                                  for (int i = 0; i < _totalPages; i++)
                                    i == _currentPage
                                        ? _buildPageIndicator(true)
                                        : _buildPageIndicator(false)
                                ]),
                              ),
                              Spacer(),
                              languageChooser(),
                              Spacer(),
                              if (_currentPage != _totalPages - 1)
                                InkWell(
                                  onTap: () {
                                    _pageController.animateToPage(3,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.linear);
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 60,
                                    // height: Platform.isIOS ? 70 : 60,
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppLocalizations.of(context).skip,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20),
                                    ),
                                  ),
                                ),
                              if (_currentPage == _totalPages - 1)
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .popAndPushNamed(CardsScreen.routeName);
                                    //If you get this far, you've seen the onboarding, so don't show again
                                    Provider.of<CardPrefs>(context,
                                            listen: false)
                                        .savePref('showOnboarding', false);
                                  },
                                  child: Container(
                                    height: 60,
                                    // height: Platform.isIOS ? 70 : 60,
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppLocalizations.of(context).start,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget languageChooser() {
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);

    // bool? firstRun =
    //     Provider.of<CardPrefs>(context, listen: false).cardPrefs.showOnboarding;
    String? chosenLang =
        Provider.of<ThemeModel>(context, listen: false).userLocale.toString();
    // if (firstRun == true) {
    //   _value = 1;
    // } else {
    switch (chosenLang) {
      case "fr_CH":
        {
          _value = 1;
          break;
        }
      case "fr":
        {
          _value = 2;
          break;
        }
      case "en":
        {
          _value = 3;
          break;
        }
    }
    // }

    TextStyle chooserStyle = TextStyle(color: Colors.black87);

    return Container(
      padding: EdgeInsets.only(left: 10),
      width: 105,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
            dropdownColor: Colors.white,
            value: _value,
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Text("Wolof", style: chooserStyle),
                  color: Colors.white,
                ),
                value: 1,
              ),
              DropdownMenuItem(
                child: Text("Français", style: chooserStyle),
                value: 2,
              ),
              DropdownMenuItem(
                child: Text("English", style: chooserStyle),
                value: 3,
              ),
            ],
            onChanged: (dynamic value) {
              //no need to setState here as the provider is calling the rebuild with notifyListeners();,
              //although I'm sad to say I don't know where the listen:true is located
              switch (value) {
                case 1:
                  {
                    themeProvider.setLocale('fr_CH');
                    break;
                  }
                case 2:
                  {
                    themeProvider.setLocale('fr');
                    break;
                  }
                case 3:
                  {
                    themeProvider.setLocale('en');
                    break;
                  }
              }
            }),
      ),
    );
  }

  Widget _buildPageContent(
      {required String bgimage,
      // String image,
      String? body,
      Color? color,
      required isShowImageOnTop}) {
    return Padding(
      padding: cardPadding,
      child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(bgimage),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(.9),
                  Colors.black.withOpacity(.4)
                ],
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!isShowImageOnTop)
                  Column(
                    children: [
                      Center(
                          // child: Image.asset(image),
                          ),
                      SizedBox(height: 50),
                      Container(
                        child: Text(
                          body!,
                          textAlign: TextAlign.center,
                          style: introStyle,
                        ),
                      ),
                    ],
                  ),
                if (isShowImageOnTop)
                  Column(
                    children: [
                      Text(body!,
                          textAlign: TextAlign.center, style: introStyle),
                      SizedBox(height: 50),
                      Center(
                          // child: Image.asset(image),
                          ),
                    ],
                  )
              ],
            ),
          )),
    );
  }

  Widget _buildFormattedPageContent(
      {required String bgimage,
      // String image,
      required Widget body,
      Color? color}) {
    return Padding(
      padding: cardPadding,
      child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(bgimage),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(.9),
                  Colors.black.withOpacity(.4)
                ],
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[body],
            ),
          )),
    );
  }

  Widget _page3Body() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${AppLocalizations.of(context).introPage3a} \n\n',
            style: introStyle,
          ),
          TextSpan(
              text: AppLocalizations.of(context).introPage3b,
              style: introStyle.copyWith(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: introStyle.fontSize! + 4,
              )),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _page4Body() {
    Widget instructionRow(icon, String instruction) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.black54,
              ),
              child: Icon(icon, color: Colors.white),
              width: 40,
              height: 40,
              alignment: Alignment.center,
            ),
            SizedBox(width: 20),
            Expanded(child: Text(instruction, style: introStyle))
          ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).introPage4a,
            style: introStyle, textAlign: TextAlign.left),
        SizedBox(height: 20),
        instructionRow(
            Icons.play_arrow, AppLocalizations.of(context).introPage4b),
        SizedBox(height: 10),
        instructionRow(Icons.share, AppLocalizations.of(context).introPage4c),
        SizedBox(height: 10),
        instructionRow(
            Icons.favorite_border, AppLocalizations.of(context).introPage4d)
      ],
    );
  }

  Widget _buildPageIndicator(bool isCurrentPage) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      height: isCurrentPage ? 18.0 : 10.0,
      width: isCurrentPage ? 18.0 : 10.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
