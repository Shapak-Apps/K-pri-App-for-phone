import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData dark({double fontScale = 1, int accent = 0}) =>
      _build(Brightness.dark, fontScale, accent);
  static ThemeData light({double fontScale = 1, int accent = 0}) =>
      _build(Brightness.light, fontScale, accent);

  static ThemeData _build(Brightness b, double fontScale, int accent) {
    var pal = b == Brightness.dark ? AppColors.dark : AppColors.light;
    pal = applyAccent(pal, accent, b == Brightness.dark);
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: pal.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pal.accent,
        brightness: b,
        surface: pal.surface,
      ),
    );
    final tt = GoogleFonts.manropeTextTheme(
      base.textTheme,
    ).apply(bodyColor: pal.text, displayColor: pal.text);
    return base.copyWith(textTheme: tt, extensions: [pal]);
  }

  static TextStyle display({double size = 28, Color? color}) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.1,
        letterSpacing: 0.5,
      );

  static TextStyle caption({Color? color, double size = 12}) =>
      TextStyle(fontSize: size, color: color, fontWeight: FontWeight.w600);

  static TextStyle label({Color? color, double size = 11}) => TextStyle(
    fontSize: size,
    color: color,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
  static TextStyle logo({double size = 24, Color? color}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
        height: 1.0,
      );
}
