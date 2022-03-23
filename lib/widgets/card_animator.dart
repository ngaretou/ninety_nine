import 'dart:math';
import 'package:flutter/material.dart';

class CardAnimator extends StatefulWidget {
  final Widget cardFront;
  final Widget cardBack;
  final MediaQueryData mediaQuery;
  final bool isPhone;
  const CardAnimator(
      {Key? key,
      required this.cardFront,
      required this.cardBack,
      required this.mediaQuery,
      required this.isPhone})
      : super(key: key);

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

  @override
  void initState() {
    print('CardAnimator initState');

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

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('CardAnimator build');
    //These transforms have to be in the build as they calculate with the animation
    final Matrix4 phoneTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.002)
      ..rotateY(pi * _animation.value)
      // I want it to go from .9 to 1.0
      // So start at 1 - .1
      ..scale(.9 + (.1 * _animation.value), .9 + (.1 * _animation.value));

    final Matrix4 tabletTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.0005)
      ..rotateY(pi * _animation.value)
      // I want it to go from .9 to 1.0
      // So start at 1 - .1
      ..scale(.75 + (.1 * _animation.value), .75 + (.1 * _animation.value));

    return AnimatedBuilder(
      animation: _animationController,
      child: _animation.value <= 0.5 ? widget.cardFront : widget.cardBack,
      builder: (BuildContext context, Widget? child) => Transform(
        alignment: FractionalOffset.center,
        transform: (widget.isPhone) ? phoneTransform : tabletTransform,
        child: GestureDetector(
          onTap: () {
            if (_animationStatus == AnimationStatus.dismissed) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }

            // print('in onTap');
          },
          child: child,
        ),
      ),
    );
  }
}
