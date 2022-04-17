import 'package:flutter/material.dart';

class Fade extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  Fade(this.page, {this.duration})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration ?? Duration(milliseconds: 100),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween(begin: 1.0, end: 1.0).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          },
        );
}
