import 'package:flutter/material.dart';

/// Clé de navigation globale permettant d'ouvrir un écran depuis un contexte
/// sans `BuildContext`, notamment le callback de tap sur une notification.
class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get _navigator => navigatorKey.currentState;

  static void push(Widget screen) {
    _navigator?.push(MaterialPageRoute(builder: (_) => screen));
  }
}
