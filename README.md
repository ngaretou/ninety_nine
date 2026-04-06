# Ninety-Nine

An app to display the ninety-nine names in multiple languages/scripts with associated verses. 
* Flip card format
* Highly customizable interface
* Multilingual menus
* Flutter framework

Landing page at http://sng.al/99

1.0.1:
Fixed: 
- 'Wolofal' in both display verses spots - corrected to Wolofal/Wolof

1.0.2
- Added Wolofal menus and display text

1.0.4
- Added Arabic menus and display text


Todo:
- 'copy' in addition to 'share'
- audio share - the arnames are not in the same mp3 encoding - 96 kbps 44.1khz mono

## Web release
>>increment build number in pubspec.yaml
```
rm -rf build/web
flutter build web 
cd build/web
HASH=$( (cat main.dart.js; date +%s) | sha256sum | cut -c1-8 )
mv main.dart.js main.dart.$HASH.js
sed -i .bak "s/main.dart.js/main.dart.$HASH.js/g" flutter_bootstrap.js 
rm flutter_bootstrap.js.bak 
cd ../..
```