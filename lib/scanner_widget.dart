import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

class ImageScannerAnimation extends AnimatedWidget {
  final bool stopped;
  final double width;

  ImageScannerAnimation(this.stopped, this.width,
      {Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    final scorePosition = (animation.value * 440) + 16;

    Color color1 = Color.fromARGB(84, 211, 222, 211);
    Color color2 = Color.fromARGB(0, 187, 215, 187);

    if (animation.status == AnimationStatus.reverse) {
      color1 = Color.fromARGB(0, 187, 215, 187);
      color2 = Color.fromARGB(84, 211, 222, 211);
    }

    return new Positioned(
        bottom: scorePosition,
        child: new Opacity(
            opacity: (stopped) ? 0.0 : 1.0,
            child: Container(
              height: 60.0,
              width: width,
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 0.9],
                colors: [color1, color2],
              )),
            )));
  }
}
