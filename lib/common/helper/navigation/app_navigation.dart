import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigator {
  /// Navigates to a named route.
  static void push(BuildContext context, String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  /// Replaces the current route with a named route.
  static void pushReplacement(BuildContext context, String route, {Object? extra}) {
    context.pushReplacement(route, extra: extra);
  }

  /// Pushes a named route and removes all previous routes.
  static void pushAndRemove(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  /// Navigates with a fade transition to a named route.
  /// Note: go_router handles transitions via route configuration.
  /// This method simply navigates to the route.
  static void fadePush(BuildContext context, String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  /// Pops the current route.
  static void pop(BuildContext context, [dynamic result]) {
    context.pop(result);
  }
}
