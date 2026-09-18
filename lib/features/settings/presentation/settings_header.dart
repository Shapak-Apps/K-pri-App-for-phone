import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Parallax header of the settings screen: gradient blobs plus a
/// shrinking title that cross-fades while the list scrolls.
class SettingsHeader extends StatelessWidget {
  final AppColors c;
  final bool isDark;
  final String title;
  const SettingsHeader({
    super.key,
    required this.c,
    required this.isDark,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = this.isDark;
    return SliverAppBar(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      pinned: true,
      expandedHeight: 180,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          final range = settings == null
              ? 1.0
              : (settings.maxExtent - settings.minExtent);
          final double t = settings == null || range <= 0
              ? 1.0
              : ((settings.currentExtent - settings.minExtent) / range).clamp(
                  0.0,
                  1.0,
                );
          final double topPad = MediaQuery.of(context).padding.top;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              c.accent.withValues(alpha: 0.18),
                              c.accentDeep.withValues(alpha: 0.08),
                              c.bg,
                            ]
                          : [c.accent.withValues(alpha: 0.14), c.bgSoft, c.bg],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.accent.withValues(alpha: 0.45),
                        c.accent.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.accentHi.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: topPad + 8,
                child: Opacity(
                  opacity: 0.35 + 0.65 * t,
                  child: Container(
                    width: 44 + 28 * t,
                    height: 44 + 28 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.accent.withValues(alpha: 0.95),
                          c.accentDeep.withValues(alpha: 0.95),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 80,
                bottom: 18,
                child: Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - t)),
                    child: Text(
                      title,
                      style: AppTheme.display(size: 22, color: c.text).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 56,
                right: 70,
                top: topPad + (kToolbarHeight - 22) / 2,
                child: Opacity(
                  opacity: 1 - t,
                  child: Text(
                    title,
                    style: AppTheme.display(size: 17, color: c.text).copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
