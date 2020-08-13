import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
// import 'dart:async';

import '../providers/card_prefs.dart';
import '../providers/names.dart';

//audio player tutorial:
//https://fluttercentral.com/Articles/Post/1234/How_to_play_an_audio_file_in_flutter

class NameCards extends StatefulWidget {
  NameCards({Key key}) : super(key: key);

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
        vsync: this, duration: Duration(milliseconds: 1500));
    // _animation = Tween(end: 1.0, begin: 0.0).animate(_animationController)
    //   ..addListener(() {
    //     setState(() {});
    //   })
    //   ..addStatusListener((status) {
    //     _animationStatus = status;
    //   });
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

  @override
  Widget build(BuildContext context) {
    print('NameCards build method');

    final divineNames = Provider.of<DivineNames>(context, listen: false);

    final mediaQuery = MediaQuery.of(context);
    // final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Center(
      child: Stack(
        children: [
          Container(
            height: (mediaQuery.size.height),
            child:
                // FutureBuilder(
                //   future: divineNames.getLastNameViewed(),
                //   builder: (ctx, snapshot) => snapshot.connectionState !=
                //           ConnectionState.done
                //       ? Center(child: CircularProgressIndicator())
                //       :
                PageView.builder(
              reverse: Provider.of<CardPrefs>(context, listen: false)
                  .cardPrefs
                  .textDirection,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: PageController(
                  initialPage: divineNames.lastPageViewed,
                  viewportFraction: 1,
                  keepPage: true),
              onPageChanged: (index) => divineNames.saveLastNameViewed(index),
              itemCount: divineNames.names.length,
              itemBuilder: (ctx, i) {
                return Transform(
                  alignment: FractionalOffset.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(pi * _animation.value)
                    // I want it to go from .9 to 1.0
                    // So start at 1 - .1
                    ..scale(.9 + (.1 * _animation.value),
                        .9 + (.1 * _animation.value)),
                  // ..scale(_animation.value + .5, _animation.value + .5),

                  child: GestureDetector(
                    onTap: () {
                      if (_animationStatus == AnimationStatus.dismissed) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                      print('in on tpap');

                      divineNames.flipCard();
                    },
                    child: _animation.value <= 0.5
                        ? imageCard(
                            "millet",
                            divineNames.names[i],
                            context,
                          )
                        : textCard(
                            divineNames.names[i],
                            context,
                          ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            width: 56,
            height: 56,
            top: mediaQuery.size.height - 72,
            left: mediaQuery.size.width - 72,
            child: AnimatedOpacity(
              opacity: divineNames.showMediaPlayer ? 1.0 : 0.0 ?? 1.0,
              duration: Duration(milliseconds: 2000),
              curve: Curves.linear,
              child: Material(
                  color: Theme.of(context)
                      .floatingActionButtonTheme
                      .backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                  child: IconButton(
                      icon: Icon(Icons.play_arrow,
                          color: Theme.of(context)
                              .floatingActionButtonTheme
                              .foregroundColor),
                      onPressed: () {})),
            ),
          ),
        ],
      ),
    );
  }

//   void _insertOverlay(BuildContext context, show) {
//     print('_insertOverlay');

//     return Overlay.of(context).insert(
//       OverlayEntry(builder: (context) {
//         final size = MediaQuery.of(context).size;

//         return Positioned(
//           width: 56,
//           height: 56,
//           top: size.height - 72,
//           left: size.width - 72,
//           child: AnimatedOpacity(
//             opacity: show ? 1.0 : 0.0,
//             duration: Duration(milliseconds: 2000),
//             curve: Curves.linear,
//             child: Material(
//                 color: Theme.of(context).primaryColor,
//                 borderRadius: BorderRadius.circular(30),
//                 child:
//                     IconButton(icon: Icon(Icons.play_arrow), onPressed: () {})),
//           ),
//           // GestureDetector(
//           //   onTap: () {},
//           //   child: Container(
//           //     decoration: BoxDecoration(
//           //         shape: BoxShape.circle, color: Colors.redAccent),
//           //   ),
//           // ),
//         );
//       }),
//     );
//   }
}

Widget imageCard(image, names, context) {
  print('imageCard build');
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
            ? Row(
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
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                ],
              ),
      ),
    ),
  );
}

Widget textCard(names, context) {
  // final mediaQuery = MediaQuery.of(context);
  // final isLandscape = mediaQuery.orientation == Orientation.landscape;
  final cardPrefs = Provider.of<CardPrefs>(context, listen: false).cardPrefs;
  return Transform(
    alignment: Alignment.center,
    transform: Matrix4.rotationY(pi),
    child: Container(
      // height: mediaQuery.size.height * .9,
      // width: mediaQuery.size.width * .9,
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
          padding: EdgeInsets.all(20.0),
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
