import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Grid of accent-color dots bound to settings.accentIndex.
class AccentPicker extends StatelessWidget {
  final AppColors c;
  final int index;
  final ValueChanged<int> on;
  const AccentPicker({
    super.key,
    required this.c,
    required this.index,
    required this.on,
  });

  @override
  Widget build(BuildContext context) {
    const perRow = 5;
    final rows = <Widget>[];
    for (var start = 0; start < accents.length; start += perRow) {
      final end = (start + perRow) > accents.length
          ? accents.length
          : start + perRow;
      final dots = <Widget>[
        for (var i = start; i < end; i++) Expanded(child: _accentDot(i)),
      ];
      for (var i = end; i < start + perRow; i++) {
        dots.add(const Expanded(child: SizedBox.shrink()));
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 14));
      rows.add(Row(children: dots));
    }
    return Column(children: rows);
  }

  Widget _accentDot(int i) => GestureDetector(
    onTap: () => on(i),
    child: Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accents[i].dAccent,
              accents[i].dAccent.withValues(alpha: 0.75),
            ],
          ),
          border: Border.all(
            color: index == i ? c.text : Colors.transparent,
            width: 3,
          ),
          boxShadow: index == i
              ? [
                  BoxShadow(
                    color: accents[i].dAccent.withValues(alpha: 0.65),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: accents[i].dAccent.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: index == i
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    ),
  );
}

/// Light / Dark / Auto segmented switcher.
class ThemeSwitcher extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  const ThemeSwitcher({
    super.key,
    required this.c,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <(ThemeMode, IconData, String)>[
      (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'Auto'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: value == o.$1
                        ? LinearGradient(
                            colors: [
                              c.accent.withValues(alpha: 0.95),
                              c.accentDeep.withValues(alpha: 0.95),
                            ],
                          )
                        : null,
                    boxShadow: value == o.$1
                        ? [
                            BoxShadow(
                              color: c.accent.withValues(alpha: 0.40),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        o.$2,
                        color: value == o.$1 ? Colors.white : c.sub,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        o.$3,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: value == o.$1 ? Colors.white : c.sub,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interface language switcher (flags).
class LanguagePicker extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final AppLang value;
  final ValueChanged<AppLang> onChanged;
  const LanguagePicker({
    super.key,
    required this.c,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          for (final lang in AppLang.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: value == lang
                        ? LinearGradient(
                            colors: [
                              c.accent.withValues(alpha: 0.95),
                              c.accentDeep.withValues(alpha: 0.95),
                            ],
                          )
                        : null,
                    boxShadow: value == lang
                        ? [
                            BoxShadow(
                              color: c.accent.withValues(alpha: 0.40),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        lang.title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: value == lang ? Colors.white : c.sub,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
