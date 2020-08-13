import 'package:flutter/material.dart';
// import 'package:ninety_nine/providers/theme.dart';
import 'package:provider/provider.dart';
// import 'package:flippable_box/flippable_box.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';

// import '../locale/app_localization.dart';

import '../providers/names.dart';
// import '../providers/card_prefs.dart';
import 'settings_screen.dart';
import '../widgets/cards.dart';

class CardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('card_screen build');

    final divineNames = Provider.of<DivineNames>(context, listen: false);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(SettingsScreen.routeName);
        },
        child: Icon(Icons.menu),
        mini: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      body: FutureBuilder(
        future: divineNames.getDivineNames(),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : NameCards(),
      ),
    );
  }
}
