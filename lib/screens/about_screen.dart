import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about-screen';

  TextSpan urlGo(String text, String url, linkTheme) {
    return TextSpan(
        text: text,
        style: TextStyle(color: linkTheme),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          });
  }

  @override
  Widget build(BuildContext context) {
    Color linkTheme = Theme.of(context).buttonColor;
    TextStyle defaultStyle = Theme.of(context).textTheme.bodyText2;
    return Scaffold(
        appBar: AppBar(
          title: Text('About'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: RichText(
                text: TextSpan(
                  style: defaultStyle,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'About and Copyright\n\n',
                        style: Theme.of(context).textTheme.headline6),

                    TextSpan(text: 'Wolof 99 names app (c) 2020 SIM.\n\n'),
                    TextSpan(
                        text:
                            'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\nKàddug Yàlla gi © 2010, 2020 Les Assemblées Evangéliques du Senegal et La Mission Baptiste du Sénégal.\n\n'),
                    urlGo(
                        '-- CC-BY-NC-ND license\n\n',
                        'https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode',
                        linkTheme),
                    urlGo('-- KYG license statement\n\n',
                        'http://sng.al/copyright', linkTheme),
                    urlGo('-- Wolof Bible online\n\n', 'http://biblewolof.com',
                        linkTheme),
                    // urlGo(),

                    //  TextSpan(''),
                    //  TextSpan(
                    //     'Nam dignissim, ligula ut rhoncus viverra, velit tortor pretium massa, in interdum sapien arcu vitae nunc. Morbi accumsan lorem felis, sed condimentum est ullamcorper at. Sed vel rhoncus risus. Nullam nisl massa, congue non pellentesque eu, venenatis a mauris. Sed lorem lorem, molestie id aliquam sed, rhoncus et mauris. Nullam et rhoncus augue. Suspendisse potenti. Donec ultrices orci vel est porta maximus. Pellentesque tristique posuere erat, et tempor felis scelerisque sit amet. Pellentesque vel efficitur velit.'),
                    //  TextSpan('Photo credits:'),
                    //  TextSpan(
                    //     '<span>Photo by <a href="https://unsplash.com/@zoltantasi?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopy TextSpan">Zoltan Tasi</a> on <a href="https://unsplash.com/photos/SHLOAAUEEQ8?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
                    // TextSpan(
                    //     '<span>Photo by <a href="https://unsplash.com/@adrienolichon?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Adrien Olichon</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
                    // TextSpan(
                    //     '<span>Photo by <a href="https://unsplash.com/@kocreated?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Mike Ko</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
                    // TextSpan(
                    //     '<span>Photo by <a href="https://unsplash.com/@augustinewong?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Augustine Wong</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
                    // TextSpan(
                    //     '<span>Photo by <a href="https://unsplash.com/@anniespratt?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Annie Spratt</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'),
                    TextSpan(
                        text: 'Licenses:\n\n',
                        style: Theme.of(context).textTheme.headline6),

                    TextSpan(text: 'MIT Licensed software included:\n\n'),
                    urlGo(
                        'audioplayers, Copyright (c) 2017 Luan Nico,\n\n',
                        'https://github.com/luanpotter/audioplayers',
                        linkTheme),
                    urlGo('provider, Copyright (c) 2019 Remi Rousselet\n\n',
                        'https://github.com/rrousselGit/provider', linkTheme),

                    TextSpan(
                        text:
                            'MIT License:\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n'),
                    TextSpan(text: 'BSD Licensed software included:\n\n'),
                    urlGo('provider, Copyright (c) 2019 Remi Rousselet\n\n',
                        'https://github.com/rrousselGit/provider', linkTheme),
                    urlGo(
                        'shared_preferences, Copyright 2017 The Chromium Authors. All rights reserved.\n\n',
                        'https://github.com/flutter/plugins/tree/master/packages/shared_preferences',
                        linkTheme),
                    urlGo(
                        'url_launcher, Copyright 2017 The Chromium Authors. All rights reserved.\n\n',
                        'https://github.com/flutter/plugins/blob/master/packages/url_launcher',
                        linkTheme),
                    urlGo('flutter, ', 'https://github.com/flutter/flutter/',
                        linkTheme),
                    urlGo('and share,', 'https://github.com/flutter/plugins/',
                        linkTheme),
                    TextSpan(
                        text:
                            'Copyright 2014, 2017, the Flutter project authors. All rights reserved.\n\n'),

                    TextSpan(
                        text:
                            'Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n\n- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n\n- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n\n- Neither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n\n'),

                    TextSpan(
                        text: 'Thanks:\n\n',
                        style: Theme.of(context).textTheme.headline6),
                    urlGo(
                        'Thanks to Damion Davy for the onboarding code.\n\n',
                        'https://github.com/drdDavi/onboarding_flutter',
                        linkTheme),
                    urlGo('Thanks to Oliver Gomes for several great ideas.\n\n',
                        'https://github.com/oliver-gomes/', linkTheme),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
