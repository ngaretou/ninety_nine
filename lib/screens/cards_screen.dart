import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../providers/names.dart';
import '../providers/theme.dart';
import './settings_screen.dart';
import '../widgets/cards.dart';

class CardsScreen extends StatefulWidget {
  static const routeName = '/cards-screen';

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int? goToPage;

  @override
  void initState() {
    goToPage = Provider.of<DivineNames>(context, listen: false).lastNameViewed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Brightness _userThemeBrightness =
        Provider.of<ThemeModel>(context, listen: false).userTheme!.brightness;
    Brightness statusBarBrightness = _userThemeBrightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;

    print('card_screen build');
    return AnnotatedRegion<SystemUiOverlayStyle>(
      //Set the brightness for status bar icons and color for status bar
      //If this is not set, the status bar will use the style applied from another route.
      //https://www.woolha.com/tutorials/flutter-set-status-bar-color-brightness-and-transparency
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000), // = transparent for all
        statusBarBrightness: _userThemeBrightness, //iOS bar brightness
        statusBarIconBrightness:
            statusBarBrightness, //Android icon color - so flipped for contrast
      ),
      child: Scaffold(
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
      ),
    );
  }
}
