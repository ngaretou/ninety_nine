import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class PlayButton extends StatefulWidget {
  final String id;
  final AudioPlayer player;

  PlayButton({Key? key, required this.id, required this.player})
      : super(key: key);

  @override
  PlayButtonState createState() => PlayButtonState();
}

class PlayButtonState extends State<PlayButton> with WidgetsBindingObserver {
  late bool _initialized;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _initialized = false;
    super.initState();
  }

  Future _initializeSession() async {
    _initialized = true;
    print('loading local audio ' + widget.id.toString());
    List<AudioSource> _source = [];

    // Future<bool> assetCheck(String path) async {
    //   try {
    //     //rootBundle.load gives an error if the file does not exist, and that gives you false
    //     ByteData bytes = await rootBundle.load(path);
    //     return true;
    //   } catch (e) {
    //     return false;
    //   }
    // }

    Future<void> checkAndAddAudioSource(String path) async {
      late bool fileExists;
      try {
        //rootBundle.load gives an error if the file does not exist, and that gives you false
        // ignore: unused_local_variable
        ByteData bytes = await rootBundle.load('assets/audio/$path');
        fileExists = true;
      } catch (e) {
        fileExists = false;
      }

      if (fileExists)
        _source.add(AudioSource.uri(Uri.parse("asset:///assets/audio/$path")));
    }

    await checkAndAddAudioSource("arnames/${widget.id}.mp3");
    await checkAndAddAudioSource("wonames/${widget.id}.mp3");
    await checkAndAddAudioSource("verses/${widget.id}.mp3");

    //Load audio
    try {
      await widget.player.setAudioSource(
        ConcatenatingAudioSource(
          // Start loading next item just before reaching it.
          useLazyPreparation: true, // default
          // Customise the shuffle algorithm.
          shuffleOrder: DefaultShuffleOrder(), // default
          // Specify the items in the playlist.

          children: _source,
        ),
        // Playback will be prepared to start from track1.mp3
        initialIndex: 0, // default
        // Playback will be prepared to start from position zero.
        initialPosition: Duration.zero, // default
      );
    } catch (e) {
      print('an error occurred loading audio: ' + e.toString());
    }

    widget.player.playbackEventStream.listen((event) {},
        // Listen to errors during playback.
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    return _source.length != 0 ? true : false;
  }

  Future<void> gracefulStop() async {
    print('gracefulStop');
    for (var i = 10; i >= 0; i--) {
      widget.player.setVolume(i / 10);
      await Future.delayed(Duration(milliseconds: 100));
    }
    widget.player.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //If the user presses home then the audio will stop gracefully
    if (state == AppLifecycleState.paused) {
      gracefulStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('play button build');

    return StreamBuilder<PlayerState>(
      stream: widget.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (playing != true) {
          return IconButton(
              icon: Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () async {
                bool shouldPlay = false;
                if (!_initialized) {
                  shouldPlay = await _initializeSession();
                }

                if (shouldPlay || _initialized) {
                  widget.player.setVolume(1);
                  widget.player.play();
                }
              });
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: Icon(Icons.pause, color: Colors.white),
            onPressed: () async {
              widget.player.pause();
            },
          );
        } else {
          return IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () => widget.player.seek(Duration.zero),
          );
          // else if (processingState != ProcessingState.completed) {
          //   return IconButton(
          //       icon: Icon(Icons.pause, color: Colors.white),
          //       onPressed: () {
          //         widget.player.pause();
          //       });
          // } else  {
          //   widget.player.seek(Duration(seconds: 0), index: 0);
          //   return IconButton(
          //     icon: Icon(Icons.play_arrow, color: Colors.white),
          //     onPressed: () {
          //       print('in the else');
          //       //on done, go back to the beginning of the playlist
          //     });

        }
      },
    );
  }
}
