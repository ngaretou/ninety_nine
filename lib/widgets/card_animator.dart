import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fps.dart';
import '../providers/card_prefs.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_audio/just_audio.dart';

class CardAnimator extends StatefulWidget {
  final Widget cardFront;
  final Widget cardBack;
  final MediaQueryData mediaQuery;
  final bool isPhone;
  final AudioPlayer player;

  CardAnimator({
    Key? key,
    required this.cardFront,
    required this.cardBack,
    required this.mediaQuery,
    required this.isPhone,
    required this.player,
  }) : super(key: key);

  @override
  State<CardAnimator> createState() => _CardAnimatorState();
}

class _CardAnimatorState extends State<CardAnimator>
    //This has to do with the animation and teh vsync:this, required under AnimationController(s)
    with
        SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  late Widget widgetToBuild;
  late bool _showFirst = true;

  int fpsDangerZone = 0;
  int fpsWorking = 0;

  @override
  void initState() {
    // print('CardAnimator initState');
    // _showFirst = true;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
        //other good curve here is easeInOutBack
        //https://api.flutter.dev/flutter/animation/Curves-class.html
        parent: _animationController,
        curve: Curves.ease)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });

    //If already on low power setting, don't bother checking;
    //Also if user has one time chosen a power setting and knows where it is, don't check anymore
    CardPrefList cardPrefs =
        Provider.of<CardPrefs>(context, listen: false).cardPrefs;

    if (cardPrefs.shouldTestDevicePerformance) {
      print('starting fps test');
      Fps.instance!.start();

      Fps.instance!.addFpsCallback((fpsInfo) {
        // print(fpsInfo);
        // Note below format of fpsInfo object
        // FpsInfo fpsInfo = FpsInfo(fps, totalCount, droppedCount, drawFramesCount);

        //If the reported fps is under 10 fps, not good. Add one observation to danger list, otherwise add one to good list
        (fpsInfo.fps < 10) ? fpsDangerZone++ : fpsWorking++;

        //If we've observed 10 bad fps settings:
        if (fpsDangerZone > 10) enableLightAnimation();
        //If we've observed 15 reports of good working order:
        if (fpsWorking > 15) disableFpsMonitoring();
      });
    }

    super.initState();
  }

  Future<void> enableLightAnimation() async {
    print('FPS consistently low: ask to enableLightAnimation');
    Fps.instance!.stop();
    //Set the preference
    Provider.of<CardPrefs>(context, listen: false).savePref('lowPower', true);
    Provider.of<CardPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    setState(() {});

    //Give the user a message and a chance to cancel
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 5),
      content: Text(
        AppLocalizations.of(context).lowPowerModeMessage,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      action: SnackBarAction(
          label: AppLocalizations.of(context).cancel,
          onPressed: () {
            //undo the lowPower setting
            Provider.of<CardPrefs>(context, listen: false)
                .savePref('lowPower', false);
            setState(() {});
          }),
    ));
  }

  Future<void> disableFpsMonitoring() async {
    print('FPS consistently good: disable monitoring');
    Provider.of<CardPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    Fps.instance!.stop();
  }

  @override
  void dispose() {
    widget.player.dispose();
    _animationController.dispose();

    Fps.instance!.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('CardAnimator build');
    //These transforms have to be in the build as they calculate with the animation
    final Matrix4 phoneTransform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(pi * _animation.value)
        // I want it to go from .9 to 1.0
        // So start at 1 - .1
        // ..scale(.9 + (.1 * _animation.value), .9 + (.1 * _animation.value))
        ;

    // ignore: unused_local_variable
    final Matrix4 tabletTransform = Matrix4.identity()
          ..setEntry(3, 2, 0.0005)
          ..rotateY(pi * _animation.value)
        // I want it to go from .9 to 1.0
        // So start at 1 - .1
        // ..scale(.75 + (.1 * _animation.value), .75 + (.1 * _animation.value))
        ;

    Widget highPowerAnimation() {
      return AnimatedBuilder(
        animation: _animationController,
        child: _animation.value <= 0.5
            ? widget.cardFront
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: widget.cardBack),
        builder: (BuildContext context, Widget? child) => Transform(
          alignment: FractionalOffset.center,
          // transform: (widget.isPhone) ? phoneTransform : tabletTransform,
          transform: phoneTransform,
          child: GestureDetector(
            onTap: () {
              if (_animationStatus == AnimationStatus.dismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            child: child,
          ),
        ),
      );
    }

    Widget lowPowerAnimation() {
      return Container(
        height: widget.mediaQuery.size.height,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showFirst = !_showFirst;
            });
          },
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 500),
            firstChild: widget.cardFront,
            secondChild: widget.cardBack,
            crossFadeState: _showFirst
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          ),
        ),
      );
    }

    Provider.of<CardPrefs>(context, listen: false).cardPrefs.lowPower
        ? widgetToBuild = lowPowerAnimation()
        : widgetToBuild = highPowerAnimation();

    return widgetToBuild;
  }
}
