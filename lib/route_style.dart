import 'package:flutter/material.dart';

/// 渐隐
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

/// 缩放
class Scale extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  Scale(this.page, {this.duration})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration ?? Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeIn,
                )),
                child: child,
              ),
            );
          },
        );
}
