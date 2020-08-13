import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

import '../providers/card_prefs.dart';
import '../providers/names.dart';

//audio player tutorial:
//https://fluttercentral.com/Articles/Post/1234/How_to_play_an_audio_file_in_flutter

class NameCards extends StatefulWidget {
  NameCards({
    Key key,
  }) : super(key: key);

  @override
  _NameCardsState createState() => _NameCardsState();
}

class _NameCardsState extends State<NameCards>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  // bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
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
  }

  bool containsLastPageCheck(namesCollection, lastPageViewed) {
    for (var name in namesCollection) {
      if (name.id == (lastPageViewed + 1).toString()) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print('NameCards build method');

    final divineNames = Provider.of<DivineNames>(context);
    final cardPrefs = Provider.of<CardPrefs>(context, listen: false);
    final namesToShow = cardPrefs.cardPrefs.showFavs
        ? divineNames.favoriteNames
        : divineNames.names;

    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    bool containsLastPage =
        containsLastPageCheck(namesToShow, divineNames.lastPageViewed);

    return Center(
      child: Stack(
        children: [
          Container(
            height: (mediaQuery.size.height),
            child: PageView.builder(
                //Controls from card preferences the card flow direction
                reverse: cardPrefs.cardPrefs.textDirection,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: PageController(
                  initialPage:
                      containsLastPage ? divineNames.lastPageViewed : 0,
                  viewportFraction: 1,
                  keepPage: true,
                ),
                onPageChanged: (index) {
                  //Here we want the user to be able to come back to the name they were on even if they
                  //switch temporarily to favorites - so save lastpage viewed only when not viewing favs
                  if (!cardPrefs.cardPrefs.showFavs) {
                    divineNames.saveLastNameViewed(index);
                  }
                },
                itemCount: namesToShow.length,
                itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                      value: namesToShow[i],
                      child: Transform(
                        alignment: FractionalOffset.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateY(pi * _animation.value)
                          // I want it to go from .9 to 1.0
                          // So start at 1 - .1
                          ..scale(.9 + (.1 * _animation.value),
                              .9 + (.1 * _animation.value)),
                        child: GestureDetector(
                          onTap: () {
                            if (_animationStatus == AnimationStatus.dismissed) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                            print('in onTap');

                            divineNames.flipCard();
                          },
                          child: _animation.value <= 0.5
                              ? imageCard(
                                  namesToShow[i],
                                  context,
                                )
                              : textCard(
                                  namesToShow[i],
                                  context,
                                ),
                        ),
                      ),
                    )),
          ),
          //Media Player
          Positioned(
            width: 40,
            height: 40,
            top: isLandscape
                ? mediaQuery.size.height - 40 - mediaQuery.padding.bottom
                : mediaQuery.size.height - 80,
            left: isLandscape
                ? mediaQuery.size.width - 50 - mediaQuery.padding.right
                : mediaQuery.size.width - 55,
            child: Material(
              color:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              child: IconButton(
                  icon: Icon(Icons.play_arrow,
                      color: Theme.of(context)
                          .floatingActionButtonTheme
                          .foregroundColor),
                  onPressed: () {
                    print('clicked media player');
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

Widget imageCard(names, context) {
  print('imageCard build for id: ' + names.id);

  final cardPrefs = Provider.of<CardPrefs>(context, listen: false).cardPrefs;

  const _fontSize = 75.0;
  const _vertFontScaleFactor = 800;
  final mediaQuery = MediaQuery.of(context);
  final isLandscape = mediaQuery.orientation == Orientation.landscape;
  return Container(
    decoration: cardPrefs.imageEnabled
        ? BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/${names.img}.jpg"),
            ),
          )
        : null,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          colors: [Colors.black.withOpacity(.9), Colors.black.withOpacity(.3)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: isLandscape
            ? Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 20,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          names.wolofName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Harmattan",
                            color: Colors.white,
                            fontSize: _fontSize *
                                (mediaQuery.size.width / _vertFontScaleFactor),
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Theme.of(context).primaryColor,
                        thickness: 3,
                        width: 100,
                      ),

                      Text(
                        names.arabicName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Harmattan",
                          fontSize: _fontSize *
                              (mediaQuery.size.width / _vertFontScaleFactor),
                          // fontWeight: FontWeight.bold,
                        ),
                      ),

                      VerticalDivider(
                        color: Theme.of(context).primaryColor,
                        thickness: 3,
                        width: 100,
                      ),
                      // SizedBox(
                      //   width: 100,
                      // ),
                      Expanded(
                        child: Text(
                          names.wolofalName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Harmattan",
                            fontSize: _fontSize *
                                (mediaQuery.size.width / _vertFontScaleFactor),
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Favorite Button - in landscape
                  FavIconButton(context),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 20,
                    ),
                  ),
                  Text(
                    names.arabicName,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Harmattan",
                      fontSize: _fontSize,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                    thickness: 3,
                  ),
                  Text(
                    names.wolofalName,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Harmattan",
                      fontSize: _fontSize,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                    thickness: 3,
                  ),
                  Text(
                    names.wolofName,
                    style: TextStyle(
                      fontFamily: "Lato",
                      color: Colors.white,
                      fontSize: _fontSize * .75,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  FavIconButton(context)
                ],
              ),
      ),
    ),
  );
}

class FavIconButton extends StatefulWidget {
  final BuildContext context;
  FavIconButton(this.context);

  @override
  _FavIconButtonState createState() => _FavIconButtonState();
}

class _FavIconButtonState extends State<FavIconButton> {
  @override
  Widget build(BuildContext context) {
    final isFav = Provider.of<DivineName>(context).isFav;
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              print('clicked fav');
              // setState(() {
              Provider.of<DivineName>(context, listen: false)
                  .toggleFavoriteStatus();
              // });
            },
          ),
        ],
      ),
    );
  }
}

Widget textCard(names, context) {
  final isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;
  final cardPrefs = Provider.of<CardPrefs>(context, listen: false).cardPrefs;
  return Transform(
    alignment: Alignment.center,
    transform: Matrix4.rotationY(pi),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(20.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/white-bg-2.jpg"),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(.3),
              Colors.black.withOpacity(.0)
            ],
          ),
        ),
        child: Padding(
          padding: isLandscape ? EdgeInsets.all(50.0) : EdgeInsets.all(20.0),
          child:
              // isLandscape
              // ?
              // // To do landscape version
              // Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [],
              //   )
              // :
              ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Name Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            names.wolofName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Harmattan",
                              fontSize: 30,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: Theme.of(context).primaryColor,
                          thickness: 3,
                        ),
                        Expanded(
                          child: Text(
                            names.wolofalName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Harmattan",
                              fontSize: 40,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    //Wolofal verse section
                    cardPrefs.wolofalVerseEnabled
                        ? Column(
                            children: [
                              Divider(
                                color: Theme.of(context).primaryColor,
                                thickness: 3,
                              ),
                              Text(
                                names.wolofalVerse,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: "Harmattan",
                                  fontSize: 40,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                names.wolofalVerseRef,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: "Harmattan",
                                  fontSize: 30,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(width: 20),
                    //Wolof verse section
                    cardPrefs.wolofVerseEnabled
                        ? Column(
                            children: [
                              Divider(
                                color: Theme.of(context).primaryColor,
                                thickness: 3,
                              ),
                              Text(
                                names.wolofVerse,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Harmattan",
                                  fontSize: 30,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                names.wolofVerseRef,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  color: Colors.black,
                                  fontSize: 20,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(width: 20),
                    SizedBox(height: 60),
                    FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Click here to read more   ',
                              style: TextStyle(color: Colors.black)),
                          Icon(Icons.play_circle_outline, color: Colors.black),
                        ],
                      ),
                      onPressed: () async {
                        const url = 'https://sng.al/chrono';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
