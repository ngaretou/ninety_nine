import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/names.dart';
import '../widgets/play_button.dart';

class CardIconBar extends StatefulWidget {
  final DivineName name;
  final AudioPlayer player;

  CardIconBar(
    this.name,
    this.player,
  );

  @override
  _CardIconBarState createState() => _CardIconBarState();
}

class _CardIconBarState extends State<CardIconBar> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    String rsTextToShare = 'Yàlla mooy ' +
        widget.name.wolofName +
        ' :\r\n' +
        widget.name.wolofVerse +
        '\r\n'
            " -- " +
        widget.name.wolofVerseRef +
        '\r\n\r\nhttp://sng.al/99';

    audioShare() async {
      // unpack the mp3s into Uint8Lists...
      Uint8List arbyte =
          (await rootBundle.load('assets/audio/arnames/${widget.name.id}.mp3'))
              .buffer
              .asUint8List();
      Uint8List wobyte =
          (await rootBundle.load('assets/audio/wonames/${widget.name.id}.mp3'))
              .buffer
              .asUint8List();
      Uint8List versebyte =
          (await rootBundle.load('assets/audio/verses/${widget.name.id}.mp3'))
              .buffer
              .asUint8List();

      // now join them all up - this is all you have to do to get them into one file!
      List<int> audioaslist = arbyte + wobyte + versebyte;

      if (kIsWeb) {
        // https://github.com/fluttercommunity/plus_plugins/issues/1643
        // if web we download it for the user to then do something with
        // get the file in memory as an XFile
        XFile audiofile = XFile.fromData(
          Uint8List.fromList(audioaslist),
          mimeType: 'audio/mpeg',
        );
        await audiofile.saveTo('tur.mp3');
      } else {
        // but in other cases on ios and android native sharing we can do something nicer.
        try {
          final dir = await getTemporaryDirectory();

          File file =
              await File('${dir.path}/tur.mp3').writeAsBytes(audioaslist);

          // Share. Some apps can handle sharing both text and audio, some not.
          await Share.shareXFiles(
            [XFile(file.path)],
            text: rsTextToShare,
            sharePositionOrigin:
                Rect.fromLTWH(0, 0, size.width, size.height * .33),
          );

          //clean up the temp file
          file.delete();
        } catch (e) {
          // if there's a problem, just share the roman script. More can be done here.
          print(e);
          debugPrint(e.toString());
          debugPrint('problem sharing audio file, sharing text only');

          await Share.share(
            rsTextToShare,
            sharePositionOrigin:
                Rect.fromLTWH(0, 0, size.width, size.height / 2),
          );
        }
      }
    }

    textShare(String shareText) async {
      if (!kIsWeb) {
        Share.share(
          shareText,
          sharePositionOrigin:
              Rect.fromLTWH(0, 0, size.width, size.height * .33),
        );
      } else {
        String url = "mailto:?subject=99&body=$shareText";

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      }
    }

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
                PlayButton(id: widget.name.id, player: widget.player),

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
                            AppLocalizations.of(context)!.sharingTitle,
                          ),
                          content:
                              Text(AppLocalizations.of(context)!.sharingMsg),
                          actions: [
                            TextButton(
                                child: Text(AppLocalizations.of(context)!
                                    .audioForSharing),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  audioShare();
                                }),
                            TextButton(
                                child: Text("Wolof"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  textShare(rsTextToShare);
                                }),
                            TextButton(
                                child: Text(" وࣷلࣷفَلْ ",
                                    style: TextStyle(
                                        fontFamily: "Harmattan",
                                        fontSize: 22,
                                        height: .5)),
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  String rtlText = ' يࣵلَّ مࣷويْ' +
                                      " " +
                                      widget.name.wolofalName +
                                      ": \r\n" +
                                      widget.name.wolofalVerse +
                                      "\r\n -- " +
                                      widget.name.wolofalVerseRef +
                                      '\r\n\r\nhttp://sng.al/99';

                                  textShare(rtlText);
                                }),
                            TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
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
