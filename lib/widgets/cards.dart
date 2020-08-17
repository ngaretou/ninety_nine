import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import '../providers/card_prefs.dart';
import '../providers/names.dart';
import '../widgets/play_button.dart';

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

  static const _fontSize = 75.0;
  static const _vertFontScaleFactor = 800;

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

  //Widgets

  Widget arabicNameFront(mediaQuery, names) {
    return Text(
      names.arabicName,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontFamily: "Harmattan",
        fontSize: mediaQuery.orientation == Orientation.landscape
            ? _fontSize * (mediaQuery.size.width / _vertFontScaleFactor)
            : _fontSize,
      ),
    );
  }

  Widget wolofalNameFront(mediaQuery, names) {
    return Text(
      names.wolofalName,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontFamily: "Harmattan",
        fontSize: mediaQuery.orientation == Orientation.landscape
            ? _fontSize * (mediaQuery.size.width / _vertFontScaleFactor)
            : _fontSize,
      ),
    );
  }

  Widget wolofNameFront(mediaQuery, names) {
    return Text(
      names.wolofName,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: "Harmattan",
        color: Colors.white,
        fontSize: mediaQuery.orientation == Orientation.landscape
            ? _fontSize * (mediaQuery.size.width / _vertFontScaleFactor)
            : _fontSize,
      ),
    );
  }

  Widget positionedBox(context, name) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.black54,
            ),
            height: 50,
            width: 300,
            margin: EdgeInsets.only(bottom: 40),
            child: cardIcons(context, name)),
      ),
    );
  }

  Widget cardIcons(context, name) {
    print('top of cardIcons');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        //Favorite
        IconButton(
          icon: Icon(
            name.isFav ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: () {
            Provider.of<DivineNames>(context, listen: false)
                .toggleFavoriteStatus(name.id);
          },
        ),
        //Media Player

        Player(name.id),

        IconButton(
          icon: Icon(
            Icons.share,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Sharing"),
                  content: Text("Choose which you'd like to share:"),
                  actions: [
                    FlatButton(
                        child: Text("Wolof"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Share.share('Yàlla mooy ' +
                              name.wolofName +
                              ":  " +
                              name.wolofVerse +
                              " -- " +
                              name.wolofVerseRef);
                        }),
                    FlatButton(
                        child: Text("وࣷلࣷفَلْ",
                            style: TextStyle(
                                fontFamily: "Harmattan", fontSize: 22)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Share.share(' يࣵلَّ مࣷويْ' +
                              name.wolofalName +
                              ":  " +
                              name.wolofalVerse +
                              " -- " +
                              name.wolofalVerseRef);
                        }),
                    FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ],
                );
              },
            );
          },
        ),
        // ),
      ],
    );
  }

  Widget imageCard(name, context) {
    print('imageCard build for id: ' + name.id);

    final cardPrefs = Provider.of<CardPrefs>(context, listen: false).cardPrefs;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Container(
      //with background image or not?
      decoration: cardPrefs.imageEnabled
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
              ? Column(
                  children: [
                    Expanded(
                      child: SizedBox(width: 20),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: wolofNameFront(mediaQuery, name)),
                        VerticalDivider(
                            color: Theme.of(context).primaryColor,
                            thickness: 3,
                            width: 100),
                        arabicNameFront(mediaQuery, name),
                        VerticalDivider(
                            color: Theme.of(context).primaryColor,
                            thickness: 3,
                            width: 100),
                        Expanded(
                          child: wolofalNameFront(mediaQuery, name),
                        ),
                      ],
                    ),
                    //Favorite Button - in landscape
                    cardIcons(context, name),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: SizedBox(width: 20)),
                    arabicNameFront(mediaQuery, name),
                    Divider(
                        color: Theme.of(context).primaryColor, thickness: 3),
                    wolofalNameFront(mediaQuery, name),
                    Divider(
                        color: Theme.of(context).primaryColor, thickness: 3),
                    wolofNameFront(mediaQuery, name),
                    Expanded(
                      child: cardIcons(context, name),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget textRS(input, double fontReduction) {
    return Text(
      input,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontFamily: "Charis",
        fontSize: 30 - fontReduction,
        // fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget textAS(input, double fontReduction) {
    return Text(
      input,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontFamily: "Harmattan",
        fontSize: 40 - fontReduction,
      ),
    );
  }

  Widget textCard(name, context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final cardPrefs = Provider.of<CardPrefs>(context, listen: false).cardPrefs;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                Colors.black.withOpacity(.3),
                Colors.black.withOpacity(.0)
              ]),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/white-bg-2.jpg")),
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
                padding:
                    isLandscape ? EdgeInsets.all(50.0) : EdgeInsets.all(20.0),
                child: ListView(
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
                              Expanded(child: textRS(name.wolofName, 0)),
                              VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                thickness: 3,
                              ),
                              Expanded(
                                child: textAS(name.wolofalName, 0),
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
                                    textAS(name.wolofalVerse, 0.0),
                                    textAS(name.wolofalVerseRef, 10.0)
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
                                    textRS(name.wolofVerse, 0.0),
                                    textRS(name.wolofVerseRef, 10.0),
                                  ],
                                )
                              : SizedBox(width: 20),
                          SizedBox(height: 60),
                          FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Click here to read more ',
                                    style: TextStyle(color: Colors.black)),
                                Icon(Icons.arrow_forward, color: Colors.black),
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
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          positionedBox(context, name),
        ],
      ),
    );
  }

//Main build
  @override
  Widget build(BuildContext context) {
    print('NameCards build method');

    final divineNames = Provider.of<DivineNames>(context);

    final cardPrefs = Provider.of<CardPrefs>(context, listen: false);
    //If you get this far, you've seen the onboarding, so don't show again
    cardPrefs.savePref('showOnboarding', false);
    final namesToShow = cardPrefs.cardPrefs.showFavs
        ? divineNames.favoriteNames
        : divineNames.names ?? divineNames.names;

    final mediaQuery = MediaQuery.of(context);
    // final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Center(
        child: Stack(children: [
      Container(
        height: (mediaQuery.size.height),
        child: PageView.builder(
            //Controls from card preferences the card flow direction
            reverse: cardPrefs.cardPrefs.textDirection,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: PageController(
              initialPage:
                  cardPrefs.cardPrefs.showFavs ? 0 : divineNames.lastPageViewed,
              viewportFraction: 1,
              keepPage: true,
            ),
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
                      },
                      child: _animation.value <= 0.5
                          ? imageCard(namesToShow[i], context)
                          : textCard(namesToShow[i], context),
                    ),
                  ),
                )),
      )
    ]));
    //Media Player
  }
}
