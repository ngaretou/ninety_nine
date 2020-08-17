import 'dart:io';

import 'package:flutter/material.dart';

import './cards_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding-screen';
  OnboardingScreen({Key key}) : super(key: key);

  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _totalPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  Widget languageChooser() {
    return SimpleDialog(title: Text("Lakk/Langue/Language"), children: [
      FlatButton(
          child: Text("Wolof"),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      FlatButton(
          child: Text("French"),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      FlatButton(
          child: Text("English"),
          onPressed: () {
            Navigator.of(context).pop();
          }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    languageChooser();
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            PageView(
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
                    body:
                        'Browse the menu and order directly from the application.',
                    color: Color(0xFFFF7252)),
                _buildPageContent(
                    isShowImageOnTop: true,
                    bgimage: 'assets/images/2.jpg',
                    body:
                        'Your order will be immediately collected and sent by our courier ',
                    color: Color(0xFFFFA131)),
                _buildPageContent(
                    isShowImageOnTop: false,
                    bgimage: 'assets/images/3.jpg',
                    body: 'Pick up delivery at your door and enjoy groceries',
                    color: Color(0xFF3C60FF))
              ],
            ),
            Positioned(
              bottom: 40,
              left: MediaQuery.of(context).size.width * .05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * .9,
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
                        if (_currentPage != 2)
                          InkWell(
                            onTap: () {
                              _pageController.animateToPage(2,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.linear);
                              setState(() {});
                            },
                            child: Container(
                              height: Platform.isIOS ? 70 : 60,
                              alignment: Alignment.center,
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                        if (_currentPage == 2)
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .popAndPushNamed(CardsScreen.routeName);
                            },
                            child: Container(
                              height: Platform.isIOS ? 70 : 60,
                              alignment: Alignment.center,
                              child: Text(
                                'Start',
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
    );
  }

  Widget _buildPageContent(
      {String bgimage,
      // String image,
      String body,
      Color color,
      isShowImageOnTop}) {
    return Container(
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
                Colors.black.withOpacity(.3)
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
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          height: 1.6,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ],
                ),
              if (isShowImageOnTop)
                Column(
                  children: [
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          height: 1.6,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    SizedBox(height: 50),
                    Center(
                        // child: Image.asset(image),
                        ),
                  ],
                )
            ],
          ),
        ));
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
