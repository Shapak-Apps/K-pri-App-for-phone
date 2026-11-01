import 'package:flutter/painting.dart';

/// The phone's text size times the app's "Font size" setting. The phone's
/// scaler is used as it is, so Android 14+ nonlinear font scaling (big text
/// grows less than small text) still works.
class AppTextScaler extends TextScaler {
  const AppTextScaler(this.system, this.factor);

  final TextScaler system;
  final double factor;

  @override
  double scale(double fontSize) => system.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => system.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is AppTextScaler &&
      other.system == system &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(system, factor);
}
