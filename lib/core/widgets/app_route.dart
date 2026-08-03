import 'package:flutter/material.dart';

Route<T> appRoute<T>(Widget page, {required bool animate}) {
  return PageRouteBuilder<T>(
    transitionDuration: animate
        ? const Duration(milliseconds: 280)
        : Duration.zero,
    reverseTransitionDuration: animate
        ? const Duration(milliseconds: 280)
        : Duration.zero,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}
