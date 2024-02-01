import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cards_screen.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about-screen';
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //This builds the html sections below
    Widget htmlSection(String url) {
      //This is where we grab the HTML from the asset folder
      Future<String?> fetchHtmlSection(String url) async {
        String htmlSection =
            await DefaultAssetBundle.of(context).loadString(url);
        return htmlSection;
      }

      return FutureBuilder(
        future: fetchHtmlSection(url),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            //this is actually where the business happens; HTML just takes the data and renders it
            : Html(
                data: snapshot.data.toString(),
                onLinkTap: (String? url, Map<String, String> attributes,
                    element) async {
                  if (url != null) {
                    await canLaunchUrl(Uri.parse(url))
                        ? await launchUrl(Uri.parse(url))
                        : throw 'Could not launch $url';
                  }
                }),
      );
    }

    double mediaQueryWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsAbout,
        ),
      ),
      body: ScrollConfiguration(
          //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
          behavior: MyCustomScrollBehavior().copyWith(scrollbars: false),
          child: Center(
              child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Center(
                    child: Container(
                      width: mediaQueryWidth >= 730 ? 730 : mediaQueryWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 10),
                        child: ListView(
                          // physics: ClampingScrollPhysics(),
                          children: [
                            ExpansionTile(
                              tilePadding: EdgeInsets.only(left: 8),
                              title: Text('99',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              initiallyExpanded: true,
                              children: [
                                htmlSection("assets/html/about.html"),
                              ],
                            ),
                            ExpansionTile(
                              tilePadding: EdgeInsets.only(left: 8),
                              title: Text('Remerciements',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              initiallyExpanded: true,
                              children: [
                                htmlSection("assets/html/thanks.html"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )))),
    );
  }
}
