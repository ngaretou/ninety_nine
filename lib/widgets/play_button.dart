import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class PlayButton extends StatefulWidget {
  final String id;

  PlayButton({Key? key, required this.id}) : super(key: key);

  @override
  PlayButtonState createState() => PlayButtonState();
}

class PlayButtonState extends State<PlayButton> with WidgetsBindingObserver {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initializeSession();
  }

  Future _initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

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
      await _player.setAudioSource(
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

    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  Future<void> gracefulStop() async {
    print('gracefulStop');
    for (var i = 10; i >= 0; i--) {
      _player.setVolume(i / 10);
      await Future.delayed(Duration(milliseconds: 100));
    }
    _player.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _player.dispose();
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
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (playing != true) {
          return IconButton(
              icon: Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                _player.play();
              });
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
              icon: Icon(Icons.pause, color: Colors.white),
              onPressed: () {
                _player.pause();
              });
        } else {
          return IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () {
              print('in the else');
              _player.seek(Duration.zero);
            },
          );
        }
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';

// class Player extends StatefulWidget {
//   final String file;

//   Player(this.file);
//   @override
//   _PlayerState createState() => _PlayerState();
// }

// class _PlayerState extends State<Player> {
//   static AudioCache cache = AudioCache();
//   late AudioPlayer player;

//   bool isPlaying = false;
//   bool isPaused = false;

//   void playHandler() async {
//     if (isPlaying) {
//       player.stop();
//     } else {
//       player = await cache.play('audio/${widget.file}.m4a');
//       player.onPlayerCompletion.listen((_) {
//         player.stop();
//         setState(() {
//           if (isPaused) {
//             isPlaying = false;
//             isPaused = false;
//           } else {
//             isPlaying = !isPlaying;
//           }
//         });
//       });
//     }

//     setState(() {
//       if (isPaused) {
//         isPlaying = false;
//         isPaused = false;
//       } else {
//         isPlaying = !isPlaying;
//       }
//     });
//   }

//   void pauseHandler() {
//     if (isPaused && isPlaying) {
//       player.resume();
//     } else {
//       player.pause();
//     }
//     setState(() {
//       isPaused = !isPaused;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Icon(
//         isPlaying ? Icons.pause : Icons.play_arrow,
//         color: Colors.white,
//       ),
//       onPressed: () {
//         playHandler();
//       },
//     );
//   }
// }
