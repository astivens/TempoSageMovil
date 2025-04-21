import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const Duration fastest = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 750);

  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeInOutQuart;

  // Page Transitions
  static PageRouteBuilder<T> pageTransition<T>({
    required Widget page,
    Curve curve = defaultCurve,
    Duration duration = normal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  // Stagger Animation Intervals
  static Interval getStaggeredInterval(
    int index, {
    int itemCount = 1,
    double startInterval = 0.0,
    double endInterval = 1.0,
  }) {
    final intervalGap = (endInterval - startInterval) / itemCount;
    return Interval(
      startInterval + (index * intervalGap),
      startInterval + ((index + 1) * intervalGap),
      curve: defaultCurve,
    );
  }
}
