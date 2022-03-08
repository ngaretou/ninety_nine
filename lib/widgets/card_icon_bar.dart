import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/names.dart';

import '../widgets/play_button.dart';

class CardIconBar extends StatefulWidget {
  final DivineName name;
  final BuildContext context;

  CardIconBar(
    this.name,
    this.context,
  );

  @override
  _CardIconBarState createState() => _CardIconBarState();
}

class _CardIconBarState extends State<CardIconBar> {
  @override
  Widget build(BuildContext context) {
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
            // padding: EdgeInsets.only(bottom: 40),
            //This was a problem when on a small screen in landscape, 320 high -
            //to check on larger screens
            // margin: EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Favorite
                IconButton(
                  icon: Icon(
                    widget.name.isFav ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Provider.of<DivineNames>(context, listen: false)
                        .toggleFavoriteStatus(widget.name.id);
                    setState(() {});
                  },
                ),
                //Media Player

                PlayButton(id: widget.name.id),

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
                          title: Text(
                            AppLocalizations.of(context).sharingTitle,
                          ),
                          content:
                              Text(AppLocalizations.of(context).sharingMsg),
                          actions: [
                            TextButton(
                                child: Text("Wolof"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Share.share('Yàlla mooy ' +
                                      widget.name.wolofName +
                                      ":  " +
                                      widget.name.wolofVerse +
                                      " -- " +
                                      widget.name.wolofVerseRef);
                                }),
                            TextButton(
                                child: Text("وࣷلࣷفَلْ",
                                    style: TextStyle(
                                        fontFamily: "Harmattan", fontSize: 22)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Share.share(' يࣵلَّ مࣷويْ' +
                                      widget.name.wolofalName +
                                      ":  " +
                                      widget.name.wolofalVerse +
                                      " -- " +
                                      widget.name.wolofalVerseRef);
                                }),
                            TextButton(
                                child: Text(
                                  AppLocalizations.of(context).cancel,
                                ),
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
            )),
      ),
    );
  }
}
