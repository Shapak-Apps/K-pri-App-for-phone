import 'package:flutter/material.dart';

import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Frosted-glass container used by every settings section.
class GlassSection extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final String title;
  final IconData icon;
  final List<Widget> children;
  const GlassSection({
    super.key,
    required this.c,
    required this.isDark,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.90),
                  Colors.white.withValues(alpha: 0.70),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.95),
                      c.accentDeep.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.display(
                  size: 15,
                  color: c.text,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

/// Row with icon, title and a flag+value chip (language pickers).
class PickerTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String flag;
  final VoidCallback onTap;
  const PickerTile({
    super.key,
    required this.c,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor.withValues(alpha: 0.25),
                      iconColor.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: c.accent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: c.faint, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient-icon action row (export / import tiles).
class GradientActionTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;
  const GradientActionTile({
    super.key,
    required this.c,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.faint, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row tile for the "About" section (privacy / terms / licenses / …).
class AboutTile extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final VoidCallback onTap;
  const AboutTile({
    super.key,
    required this.c,
    required this.isDark,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Icon(Icons.arrow_outward_rounded, color: c.faint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bold sub-caption inside the "Look" section.
class AccentLabel extends StatelessWidget {
  final AppColors c;
  final String label;
  const AccentLabel({super.key, required this.c, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: c.text,
        fontWeight: FontWeight.w800,
        fontSize: 14,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// History / favorites counter panel.
class StatsPanel extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final int history;
  final int favorites;
  const StatsPanel({
    super.key,
    required this.c,
    required this.isDark,
    required this.history,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.settings.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.accent.withValues(alpha: 0.18),
            c.accentDeep.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.accent.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              c: c,
              icon: Icons.history_rounded,
              gradient: const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              count: history,
              label: l10n.t('history'),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: c.line.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _StatCell(
              c: c,
              icon: Icons.star_rounded,
              gradient: const [Color(0xFFF59E0B), Color(0xFFEC4899)],
              count: favorites,
              label: l10n.t('favorites'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final List<Color> gradient;
  final int count;
  final String label;
  const _StatCell({
    required this.c,
    required this.icon,
    required this.gradient,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: AppTheme.display(
            size: 20,
            color: c.text,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.caption(color: c.faint, size: 11)),
      ],
    );
  }
}

/// Gradient logo + version footer at the bottom of the list.
class VersionFooter extends StatelessWidget {
  final AppColors c;
  final String versionLabel;
  const VersionFooter({super.key, required this.c, required this.versionLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accent.withValues(alpha: 0.08),
            c.accent.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accent.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [c.text, c.accent]).createShader(bounds),
            child: Text(
              'Köpri',
              style: AppTheme.logo(size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$versionLabel 1.0.2',
            style: AppTheme.caption(color: c.faint, size: 11),
          ),
        ],
      ),
    );
  }
}
