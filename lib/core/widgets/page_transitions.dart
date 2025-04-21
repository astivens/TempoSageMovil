import 'package:flutter/material.dart';
import '../constants/app_animations.dart';

class MobilePageTransition extends StatelessWidget {
  final Widget child;
  final bool isPopup;

  const MobilePageTransition({
    super.key,
    required this.child,
    this.isPopup = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: AppAnimations.normal,
      curve: AppAnimations.smoothCurve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            0.0,
            isPopup ? 50.0 * (1.0 - value) : 0.0,
          ),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

Route<T> createMobilePageRoute<T>({
  required Widget page,
  bool isPopup = false,
  bool fullscreenDialog = false,
}) {
  return PageRouteBuilder<T>(
    fullscreenDialog: fullscreenDialog,
    pageBuilder: (context, animation, secondaryAnimation) {
      return MobilePageTransition(
        isPopup: isPopup,
        child: page,
      );
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = isPopup ? const Offset(0.0, 0.3) : const Offset(0.05, 0.0);
      var end = Offset.zero;
      var curve = AppAnimations.smoothCurve;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      var fadeAnimation = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: curve,
        ),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: AppAnimations.normal,
    reverseTransitionDuration: AppAnimations.fast,
  );
}
