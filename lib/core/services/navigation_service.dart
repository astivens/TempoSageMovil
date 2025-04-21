import 'package:flutter/material.dart';

class NavigationService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get navigator => navigatorKey.currentState!;

  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> replaceTo<T>(String routeName, {Object? arguments}) {
    return navigator.pushReplacementNamed(routeName, arguments: arguments);
  }

  static void goBack<T>([T? result]) {
    return navigator.pop(result);
  }
}
