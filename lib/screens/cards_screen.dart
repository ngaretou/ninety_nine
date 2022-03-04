import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/names.dart';
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
      //goToPage only comes into play when a name is chosen from List View
      body: NameCards(goToPage: goToPage),
    );
  }
}
