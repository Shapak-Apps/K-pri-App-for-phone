import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color bg, bgSoft, surface, surfaceHi, line;
  final Color text, sub, faint;
  final Color accent, accentHi, accentDeep, warn;

  const AppColors({
    required this.bg,
    required this.bgSoft,
    required this.surface,
    required this.surfaceHi,
    required this.line,
    required this.text,
    required this.sub,
    required this.faint,
    required this.accent,
    required this.accentHi,
    required this.accentDeep,
    required this.warn,
  });

  static const dark = AppColors(
    bg: Color(0xFF0E1116),
    bgSoft: Color(0xFF14181F),
    surface: Color(0xFF1A1F27),
    surfaceHi: Color(0xFF222831),
    line: Color(0xFF2A313C),
    text: Color(0xFFE6EDF3),
    sub: Color(0xFF9AA4B2),
    faint: Color(0xFF5C6675),
    accent: Color(0xFF5B8DEF),
    accentHi: Color(0xFF82ACFF),
    accentDeep: Color(0xFF3F6FD1),
    warn: Color(0xFFE5736B),
  );

  static const light = AppColors(
    bg: Color(0xFFFFFFFF),
    bgSoft: Color(0xFFF4F6F9),
    surface: Color(0xFFFFFFFF),
    surfaceHi: Color(0xFFEEF1F6),
    line: Color(0xFFDCE1E9),
    text: Color(0xFF1B212B),
    sub: Color(0xFF5B6573),
    faint: Color(0xFF98A1AE),
    accent: Color(0xFF3B6FE0),
    accentHi: Color(0xFF2A5BC8),
    accentDeep: Color(0xFF2451B8),
    warn: Color(0xFFD6453C),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? bgSoft,
    Color? surface,
    Color? surfaceHi,
    Color? line,
    Color? text,
    Color? sub,
    Color? faint,
    Color? accent,
    Color? accentHi,
    Color? accentDeep,
    Color? warn,
  }) => AppColors(
    bg: bg ?? this.bg,
    bgSoft: bgSoft ?? this.bgSoft,
    surface: surface ?? this.surface,
    surfaceHi: surfaceHi ?? this.surfaceHi,
    line: line ?? this.line,
    text: text ?? this.text,
    sub: sub ?? this.sub,
    faint: faint ?? this.faint,
    accent: accent ?? this.accent,
    accentHi: accentHi ?? this.accentHi,
    accentDeep: accentDeep ?? this.accentDeep,
    warn: warn ?? this.warn,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bgSoft: Color.lerp(bgSoft, other.bgSoft, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHi: Color.lerp(surfaceHi, other.surfaceHi, t)!,
      line: Color.lerp(line, other.line, t)!,
      text: Color.lerp(text, other.text, t)!,
      sub: Color.lerp(sub, other.sub, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHi: Color.lerp(accentHi, other.accentHi, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}

class AccentSet {
  final String name;
  final Color dAccent, dHi, dDeep;
  final Color lAccent, lHi, lDeep;
  const AccentSet(
    this.name,
    this.dAccent,
    this.dHi,
    this.dDeep,
    this.lAccent,
    this.lHi,
    this.lDeep,
  );
}

const accents = <AccentSet>[
  AccentSet(
    'Ocean',
    Color(0xFF3DA9FC),
    Color(0xFF7FD0FF),
    Color(0xFF1E6FD0),
    Color(0xFF1E8FE0),
    Color(0xFF0E6FC0),
    Color(0xFF1668B8),
  ),
  AccentSet(
    'Violet',
    Color(0xFF9B7BFF),
    Color(0xFFC2AEFF),
    Color(0xFF6A4FD0),
    Color(0xFF7C5CE0),
    Color(0xFF5A3FC0),
    Color(0xFF4A30B0),
  ),
  AccentSet(
    'Emerald',
    Color(0xFF34D399),
    Color(0xFF7BE7BE),
    Color(0xFF159E6E),
    Color(0xFF10A86F),
    Color(0xFF0C8457),
    Color(0xFF0A6B47),
  ),
  AccentSet(
    'Amber',
    Color(0xFFFB923C),
    Color(0xFFFDBA74),
    Color(0xFFD9690E),
    Color(0xFFE07B1A),
    Color(0xFFC2620C),
    Color(0xFFA64F08),
  ),
  AccentSet(
    'Rose',
    Color(0xFFFB7185),
    Color(0xFFFDA4B4),
    Color(0xFFD13D57),
    Color(0xFFE0455F),
    Color(0xFFC22E48),
    Color(0xFFA6243C),
  ),
  AccentSet(
    'Teal',
    Color(0xFF2DD4BF),
    Color(0xFF74E6D6),
    Color(0xFF0E9E8C),
    Color(0xFF12A894),
    Color(0xFF0E8576),
    Color(0xFF0B6B5F),
  ),
  AccentSet(
    'Cyan',
    Color(0xFF22D3EE),
    Color(0xFF67E8F9),
    Color(0xFF0891B2),
    Color(0xFF0891B2),
    Color(0xFF0E7490),
    Color(0xFF155E75),
  ),
  AccentSet(
    'Pink',
    Color(0xFFEC4899),
    Color(0xFFF9A8D4),
    Color(0xFFBE185D),
    Color(0xFFDB2777),
    Color(0xFFBE185D),
    Color(0xFF9D174D),
  ),
  AccentSet(
    'Lime',
    Color(0xFFA3E635),
    Color(0xFFD9F99D),
    Color(0xFF65A30D),
    Color(0xFF65A30D),
    Color(0xFF4D7C0F),
    Color(0xFF3F6212),
  ),
  AccentSet(
    'Indigo',
    Color(0xFF818CF8),
    Color(0xFFC7D2FE),
    Color(0xFF4F46E5),
    Color(0xFF4F46E5),
    Color(0xFF4338CA),
    Color(0xFF3730A3),
  ),
];

AppColors applyAccent(AppColors base, int index, bool isDark) {
  if (index <= 0 || index >= accents.length) return base;
  final a = accents[index];
  return base.copyWith(
    accent: isDark ? a.dAccent : a.lAccent,
    accentHi: isDark ? a.dHi : a.lHi,
    accentDeep: isDark ? a.dDeep : a.lDeep,
  );
}
